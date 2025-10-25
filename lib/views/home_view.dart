import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../cubits/service/service_cubit.dart';
import '../cubits/service/service_state.dart';
import '../widgets/service_card.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

/// Home screen showing list of service requests
/// Main dashboard for workshop users
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load service requests when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AuthCubit>();
      final serviceCubit = context.read<ServiceCubit>();

      final user = authCubit.currentUser;
      if (user != null) {
        serviceCubit.loadWorkshopRequests(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: _selectedIndex == 0 ? _buildHomeContent() : _buildOtherTab(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: _buildSearchBar(),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) => CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ],
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConstants.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.location_on, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      readOnly: true,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: 'ابحث عن عميل برقم الهاتف...',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: const Icon(Icons.filter_list, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
    );
  }

  Widget _buildHomeContent() {
    return BlocConsumer<ServiceCubit, ServiceState>(
      listener: (context, state) {
        // Show success/error messages
        if (state is ServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is ServiceOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            if (state is ServiceLoaded) _buildFilterChips(state),
            Expanded(
              child: state is ServiceLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is ServiceLoaded
                  ? state.requests.isEmpty
                        ? _buildEmptyState()
                        : _buildServiceList(state.requests)
                  : _buildEmptyState(),
            ),
            _buildAddClientButton(),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips(ServiceLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          _buildFilterChip(
            'آخر 90 يوم (${state.requests.length})',
            state.currentFilter == ServiceFilter.recent90Days,
            () => _setFilter(ServiceFilter.recent90Days),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'الحاليين(${state.requests.length})',
            state.currentFilter == ServiceFilter.current,
            () => _setFilter(ServiceFilter.current),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppConstants.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.access_time,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _setFilter(ServiceFilter filter) {
    final authCubit = context.read<AuthCubit>();
    final serviceCubit = context.read<ServiceCubit>();

    final user = authCubit.currentUser;
    if (user != null) {
      serviceCubit.setFilter(filter, user.uid);
    }
  }

  Widget _buildServiceList(List requests) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ServiceCard(request: request),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات حالياً',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildAddClientButton() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: CustomButton(
        text: 'أضافة عميل',
        icon: Icons.add,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createRequest),
      ),
    );
  }

  Widget _buildOtherTab() {
    return Center(
      child: Text(
        'قريباً...',
        style: TextStyle(fontSize: 24, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'فواتيري',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'الصيانة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        ],
      ),
    );
  }
}

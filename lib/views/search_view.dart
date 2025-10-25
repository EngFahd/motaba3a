import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/service/service_cubit.dart';
import '../cubits/auth/auth_cubit.dart';
import '../models/service_request_model.dart';
import '../utils/constants.dart';

/// Search screen for finding clients by phone number
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  List<ServiceRequestModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: '+966 123123...',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        suffixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        if (value.length >= 3) {
          _performSearch(value);
        } else {
          setState(() => _searchResults = []);
        }
      },
    );
  }

  Future<void> _performSearch(String phoneNumber) async {
    setState(() => _isSearching = true);

    final authCubit = context.read<AuthCubit>();
    final serviceCubit = context.read<ServiceCubit>();

    final user = authCubit.currentUser;
    if (user != null) {
      final results = await serviceCubit.searchClients(user.uid, phoneNumber);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && _searchController.text.length >= 3) {
      return const Center(
        child: Text(
          'لا توجد نتائج',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'ابحث عن عميل بإدخال رقم الجوال',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return _buildSearchResultItem(result);
        },
      ),
    );
  }

  Widget _buildSearchResultItem(ServiceRequestModel request) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context, request),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'طلب',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                request.clientName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request.clientPhone,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

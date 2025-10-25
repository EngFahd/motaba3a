import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/service/service_cubit.dart';
import '../cubits/service/service_state.dart';
import '../cubits/auth/auth_cubit.dart';
import '../models/service_request_model.dart';
import '../models/vehicle_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

/// Create new service request screen
/// Form to add a new client and their service request
class CreateRequestView extends StatefulWidget {
  const CreateRequestView({super.key});

  @override
  State<CreateRequestView> createState() => _CreateRequestViewState();
}

class _CreateRequestViewState extends State<CreateRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _priceController = TextEditingController(text: '100');

  DateTime _entryDate = DateTime.now();
  DateTime _exitDate = DateTime.now().add(const Duration(days: 5));
  final List<String> _selectedServices = ['تغيير زيت'];

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceCubit, ServiceState>(
      listener: (context, state) {
        // Handle success
        if (state is ServiceOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }

        // Handle error
        if (state is ServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ServiceLoading;

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          appBar: _buildAppBar(),
          body: LoadingOverlay(
            isLoading: isLoading,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildVehicleCard(),
                    _buildFormCard(),
                    _buildSubmitButton(context, isLoading),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'انشاء طلب\nسياره العميل',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '>> صيانة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _vehicleMakeController.text.isEmpty
                    ? 'لاند كروزر فورشفر 2016'
                    : '${_vehicleMakeController.text} ${_vehicleModelController.text}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedServices.join('، '),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              size: 30,
              color: AppConstants.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTextField('اسم العميل', _clientNameController, 'محمد جمال'),
          const SizedBox(height: 16),
          _buildTextField(
            'رقم الجوال',
            _clientPhoneController,
            '+966052345678',
            validator: Validators.phoneNumber,
          ),
          const SizedBox(height: 16),
          _buildTextField('ماركة السيارة', _vehicleMakeController, 'تويوتا'),
          const SizedBox(height: 16),
          _buildTextField(
            'موديل السيارة',
            _vehicleModelController,
            'لاند كروزر',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'سنة الصنع',
            _vehicleYearController,
            '2016',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          const Text(
            'الوقت و التاريخ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDateField('موعد الخروج', _exitDate, false)),
              const SizedBox(width: 12),
              Expanded(child: _buildDateField('موعد الدخول', _entryDate, true)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'نوع الاصلاح',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildServiceTypeSelector(),
          const SizedBox(height: 24),
          const Text(
            'السعر',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPriceField(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          keyboardType: keyboardType,
          validator: validator ?? (v) => Validators.required(v, label),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(date, isRequired),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                Text(
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(DateTime currentDate, bool isEntry) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isEntry) {
          _entryDate = picked;
        } else {
          _exitDate = picked;
        }
      });
    }
  }

  Widget _buildServiceTypeSelector() {
    return Column(
      children: [
        ..._selectedServices.map(
          (service) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppConstants.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: _showAddServiceDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.add, size: 32)),
          ),
        ),
      ],
    );
  }

  void _showAddServiceDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة خدمة', textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: 'اسم الخدمة'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _selectedServices.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      validator: Validators.number,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryBlue,
      ),
      decoration: const InputDecoration(
        suffixText: 'ر.س',
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: CustomButton(
        text: 'أرسال الطلب',
        icon: Icons.send,
        isLoading: isLoading,
        onPressed: () => _handleSubmit(context),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();
    final serviceCubit = context.read<ServiceCubit>();

    final user = authCubit.currentUser;
    if (user == null) return;

    final request = ServiceRequestModel(
      id: '',
      workshopId: user.uid,
      clientId: '',
      clientName: _clientNameController.text.trim(),
      clientPhone: _clientPhoneController.text.trim(),
      vehicle: VehicleModel(
        make: _vehicleMakeController.text.trim(),
        model: _vehicleModelController.text.trim(),
        year: int.tryParse(_vehicleYearController.text),
      ),
      serviceTypes: _selectedServices,
      price: double.parse(_priceController.text),
      entryDate: _entryDate,
      exitDate: _exitDate,
      status: ServiceStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await serviceCubit.createServiceRequest(request);
  }
}

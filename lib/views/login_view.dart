import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

/// Login and registration view
/// Allows users to sign in or create new account
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _workshopNameController = TextEditingController();
  final _unifiedNumberController = TextEditingController();

  bool _isNewUser = false;
  bool _isWorkshop = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _workshopNameController.dispose();
    _unifiedNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Handle navigation when authenticated
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }

        // Show error message
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: LoadingOverlay(
            isLoading: isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildTitle(),
                      const SizedBox(height: 16),
                      _buildSubtitle(),
                      const SizedBox(height: 32),
                      _buildUserTypeToggle(),
                      const SizedBox(height: 32),
                      _buildFormFields(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(context, isLoading),
                      const SizedBox(height: 24),
                      if (!_isNewUser) _buildCreateAccountLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppConstants.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.location_on, size: 50, color: Colors.white),
    );
  }

  Widget _buildTitle() {
    return Text(
      _isNewUser
          ? 'هلا والله! أنشئ حسابك\nوخلنا نبدأ الرحلة سوا 🚀'
          : 'حياك الله يا الغالي،\nالتطبيق بانتظارك ✨',
      textAlign: TextAlign.center,
      style: AppConstants.headingStyle,
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'قم بتسجيل الدخول عن طريق رقم الجوال أو الإيميل',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: Colors.grey),
    );
  }

  Widget _buildUserTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton('ورشة', _isWorkshop),
        const SizedBox(width: 8),
        _buildToggleButton('مستخدم', !_isWorkshop),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _isWorkshop = text == 'ورشة'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryBlue : Colors.transparent,
          border: Border.all(color: AppConstants.primaryBlue, width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppConstants.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        if (_isNewUser) ...[
          if (_isWorkshop)
            CustomTextField(
              label: 'اسم الورشة',
              hint: 'ورشة السيارات',
              controller: _workshopNameController,
              validator: (val) => Validators.required(val, 'اسم الورشة'),
            ),
          if (!_isWorkshop)
            CustomTextField(
              label: 'الاسم',
              hint: 'محمد',
              controller: _nameController,
              validator: (val) => Validators.required(val, 'الاسم'),
            ),
          const SizedBox(height: 16),
          if (_isWorkshop)
            CustomTextField(
              label: 'الرقم الموحد',
              hint: '11111111',
              controller: _unifiedNumberController,
              validator: (val) => Validators.required(val, 'الرقم الموحد'),
            ),
          if (_isWorkshop) const SizedBox(height: 16),
        ],
        CustomTextField(
          label: _isNewUser ? 'البريد الإلكتروني' : 'رقم الجوال أو البريد',
          hint: _isNewUser ? 'example@email.com' : '+966052345678',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        if (_isNewUser) ...[
          CustomTextField(
            label: 'رقم الجوال',
            hint: '+966052345678',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: Validators.phoneNumber,
          ),
          const SizedBox(height: 16),
        ],
        CustomTextField(
          label: 'كلمة السر',
          hint: '••••••••',
          isPassword: true,
          controller: _passwordController,
          validator: Validators.password,
        ),
        if (_isNewUser) ...[
          const SizedBox(height: 16),
          CustomTextField(
            label: 'تأكيد كلمة السر',
            hint: '••••••••',
            isPassword: true,
            controller: _confirmPasswordController,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'كلمة السر غير متطابقة';
              }
              return null;
            },
          ),
        ],
        if (!_isNewUser) ...[
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'نسيت كلمة السر؟',
              style: TextStyle(color: AppConstants.primaryBlue, fontSize: 14),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return CustomButton(
      text: _isNewUser ? 'إنشاء حساب' : 'تسجيل الدخول',
      icon: _isNewUser ? Icons.person_add : Icons.login,
      isLoading: isLoading,
      onPressed: () => _handleSubmit(context),
    );
  }

  Widget _buildCreateAccountLink() {
    return InkWell(
      onTap: () => setState(() => _isNewUser = true),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(text: 'ليس لديك حساب؟ '),
            TextSpan(
              text: 'أنشئ حساب الآن',
              style: TextStyle(
                color: AppConstants.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();

    if (_isNewUser) {
      await authCubit.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _isWorkshop
            ? _workshopNameController.text.trim()
            : _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        userType: _isWorkshop ? UserType.workshop : UserType.client,
        workshopName: _isWorkshop ? _workshopNameController.text.trim() : null,
        unifiedNumber: _isWorkshop
            ? _unifiedNumberController.text.trim()
            : null,
      );

      if (mounted && authCubit.state is AuthAuthenticated) {
        _showSuccessDialog();
      }
    } else {
      await authCubit.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تم تأكيد هويتك بنجاح',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'إبدأ الآن بتنظيم عملك، ومتابعة الأداء وتحسين خدماتك من خلال أدواتنا المخصصة لإدارة الصيانة بإحترافية.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.verified_user,
                  size: 80,
                  color: AppConstants.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'الدخول للتطبيق',
              icon: Icons.arrow_back,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}

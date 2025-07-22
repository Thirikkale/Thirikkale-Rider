import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/authenctication/screens/photo_verification_screen.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/sign_navigation_button_row.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';
import 'package:thirikkale_rider/widgets/common/custom_input_field_label.dart';

class NameRegistrationScreen extends StatefulWidget {
  const NameRegistrationScreen({super.key});

  @override
  State<NameRegistrationScreen> createState() => _NameRegistrationScreenState();
}

class _NameRegistrationScreenState extends State<NameRegistrationScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);

    // Pre-populate fields if names already exist in provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.firstName != null && authProvider.firstName != 'Rider') {
      _firstNameController.text = authProvider.firstName!;
    }
    if (authProvider.lastName != null && authProvider.lastName != 'User') {
      _lastNameController.text = authProvider.lastName!;
    }
    _validateForm();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _firstNameController.text.trim().isNotEmpty &&
          _lastNameController.text.trim().isNotEmpty;
    });
  }

  void _completeProfile() async {
    if (!_isFormValid) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    // Store name in provider first
    authProvider.setUserName(firstName, lastName);

    if (!mounted) return;

    // Complete the profile with names using the new API endpoint
    final success = await authProvider.completeRiderProfile(
      firstName: firstName,
      lastName: lastName,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to photo verification
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Name registration completed.',
      );
      _navigateToPhotoVerification();
    } else {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Profile completion failed. Please try again.',
      );
    }
  }

  void _navigateToPhotoVerification() {
    // Registration successful, navigate to next step
    Navigator.of(context).push(
      NoAnimationPageRoute(
        builder: (context) => const PhotoVerificationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/images/primary_logo.png',
          height: 32.0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is your name?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Let us know how to properly address you.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            CustomInputFieldLabel(
              label: "First Name",
              controller: _firstNameController,
            ),
            const SizedBox(height: 16),
            CustomInputFieldLabel(
              label: "Last Name",
              controller: _lastNameController,
            ),
            const Spacer(),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SignNavigationButtonRow(
                  onBack: () => Navigator.pop(context),
                  onNext: _isFormValid ? _completeProfile : null,
                  nextEnabled: _isFormValid,
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

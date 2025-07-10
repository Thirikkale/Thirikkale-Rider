import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
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

  void _navigateToPhotoVerification() {
    // Send details to backend also store the name in your AuthProvider here
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // authProvider.setUserName(_firstNameController.text, _lastNameController.text);

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
      body: SafeArea(
        child: Padding(
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
              CustomInputFieldLabel(label: "First Name", controller: _firstNameController,),
              const SizedBox(height: 16),
              CustomInputFieldLabel(label: "Last Name", controller: _lastNameController,),
              const Spacer(),
              SignNavigationButtonRow(
                onBack: () => Navigator.pop(context),
                onNext: _isFormValid ? _navigateToPhotoVerification : null,
                nextEnabled: _isFormValid,
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

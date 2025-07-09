import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';

/// Demo screen showing the complete signup flow
/// This demonstrates how to use the AuthProvider for the full rider signup process
class SignupFlowDemo extends StatefulWidget {
  const SignupFlowDemo({super.key});

  @override
  State<SignupFlowDemo> createState() => _SignupFlowDemoState();
}

class _SignupFlowDemoState extends State<SignupFlowDemo> {
  final _phoneController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Step 1: Send OTP
  void _sendOTP() async {
    final phoneNumber = '+94${_phoneController.text}';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId, resendToken) {
        SnackbarHelper.showSuccessSnackBar(context, "OTP sent successfully!");
      },
      onVerificationFailed: (error) {
        SnackbarHelper.showErrorSnackBar(context, error.message ?? "Failed to send OTP");
      },
    );
  }

  // Step 2: Verify OTP
  void _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOTP(otp);
    if (success) {
      // OTP verified, now check if user exists
      final userExists = await authProvider.checkUserExists();
      
      if (userExists) {
        SnackbarHelper.showSuccessSnackBar(context, "Welcome back! You're logged in.");
      } else {
        SnackbarHelper.showInfoSnackBar(context, "OTP verified! Please complete registration.");
      }
    } else {
      SnackbarHelper.showErrorSnackBar(
        context, 
        authProvider.errorMessage ?? "Invalid OTP",
      );
    }
  }

  // Step 3: Register User
  void _registerUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.registerUser(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() 
          : null,
    );

    if (success) {
      SnackbarHelper.showSuccessSnackBar(
        context, 
        "Registration successful! Welcome to Thirikkale!",
      );
    } else {
      SnackbarHelper.showErrorSnackBar(
        context, 
        authProvider.errorMessage ?? "Registration failed",
      );
    }
  }

  // Step 4: Update Profile (Optional)
  void _updateProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() 
          : null,
    );

    if (success) {
      SnackbarHelper.showSuccessSnackBar(context, "Profile updated successfully!");
    } else {
      SnackbarHelper.showErrorSnackBar(
        context, 
        authProvider.errorMessage ?? "Profile update failed",
      );
    }
  }

  // Logout
  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    SnackbarHelper.showInfoSnackBar(context, "Logged out successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Flow Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Auth State Display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auth State: ${authProvider.authState.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (authProvider.verifiedPhoneNumber != null)
                        Text('Phone: ${authProvider.verifiedPhoneNumber}'),
                      if (authProvider.currentUser != null) ...[
                        Text('Name: ${authProvider.currentUser!.fullName}'),
                        Text('User ID: ${authProvider.currentUser!.userId}'),
                      ],
                      if (authProvider.errorMessage != null)
                        Text(
                          'Error: ${authProvider.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Step 1: Phone Number Entry
                if (authProvider.authState == AuthState.initial) ...[
                  const Text(
                    'Step 1: Enter Phone Number',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (without +94)',
                      border: OutlineInputBorder(),
                      prefixText: '+94 ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _sendOTP,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Send OTP'),
                  ),
                ],

                // Step 2: OTP Verification
                if (authProvider.needsOTPVerification) ...[
                  const Text(
                    'Step 2: Enter OTP Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _otpControllers.map((controller) {
                      return SizedBox(
                        width: 40,
                        child: TextField(
                          controller: controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _verifyOTP,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Verify OTP'),
                  ),
                ],

                // Step 3: Registration (if user doesn't exist)
                if (authProvider.needsRegistration) ...[
                  const Text(
                    'Step 3: Complete Registration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _registerUser,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
                  ),
                ],

                // Step 4: Logged In State
                if (authProvider.isLoggedIn) ...[
                  const Text(
                    '✅ Successfully Logged In!',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, ${authProvider.currentUser!.fullName}!'),
                        Text('Phone: ${authProvider.currentUser!.phoneNumber}'),
                        if (authProvider.currentUser!.email != null)
                          Text('Email: ${authProvider.currentUser!.email}'),
                        Text('Total Rides: ${authProvider.currentUser!.totalRides}'),
                        Text('Member Since: ${authProvider.currentUser!.createdAt?.toLocal().toString().split(' ')[0] ?? 'Unknown'}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _updateProfile,
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Update Profile'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ],

                // Loading indicator
                if (authProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 32),
                
                // Helper Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Helper Actions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              authProvider.clearError();
                            },
                            child: const Text('Clear Error'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              authProvider.resetToPhoneEntry();
                            },
                            child: const Text('Reset to Start'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

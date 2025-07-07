import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Mock emergency contacts data
  final List<Map<String, String>> _emergencyContacts = [
    {
      'name': 'Sophia Carter',
      'phone': '+94 77 123 4567',
      'relationship': 'Sister',
    },
    {
      'name': 'Ethan Bennett',
      'phone': '+94 77 890 1234',
      'relationship': 'Brother',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: 'Emergency Contacts',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add a contact',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter contact name',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              hintText: 'Enter phone number',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Your contacts',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    ..._emergencyContacts.map((contact) => _buildContactTile(contact)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addContact();
                  }
                },
                child: const Text('Add Contact'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(Map<String, String> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Text(
              contact['name']!.substring(0, 1).toUpperCase(),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name']!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact['phone']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editContact(contact),
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _addContact() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      setState(() {
        _emergencyContacts.add({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'relationship': 'Contact',
        });
      });
      
      _nameController.clear();
      _phoneController.clear();
      
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Emergency contact added successfully!',
      );
    }
  }

  void _editContact(Map<String, String> contact) {
    // Handle edit contact
    print('Edit contact: ${contact['name']}');
  }
}

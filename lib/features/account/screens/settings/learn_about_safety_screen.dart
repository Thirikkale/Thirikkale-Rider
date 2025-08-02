import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class LearnAboutSafetyScreen extends StatelessWidget {
  const LearnAboutSafetyScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I share my trip status?',
      'answer': 'You can share your trip status with trusted contacts from the Safety Features screen or during your ride.'
    },
    {
      'question': 'What happens when I press the SOS button?',
      'answer': 'Pressing SOS will immediately call your emergency contacts and share your location.'
    },
    {
      'question': 'How is my data kept safe?',
      'answer': 'We use industry-standard encryption and never share your personal data without your consent.'
    },
    {
      'question': 'Can I disable auto call emergency?',
      'answer': 'Yes, you can toggle this feature in the Safety Features settings.'
    },
    {
      'question': 'Who are my emergency contacts?',
      'answer': 'You can set and manage your emergency contacts in your account settings.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: 'Learn About Safety',
        showBackButton: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
        itemCount: faqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.subtleGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq['question']!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  faq['answer']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
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

import 'package:flutter/material.dart';
import 'package:myalien/app/theme/app_colors.dart';

/// Modal bottom sheet displaying Terms of Service or Privacy Policy.
class TermsAndPrivacySheet extends StatelessWidget {
  const TermsAndPrivacySheet({
    required this.isPrivacyPolicy,
    super.key,
  });

  final bool isPrivacyPolicy;

  static Future<void> show(
    BuildContext context, {
    bool isPrivacyPolicy = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TermsAndPrivacySheet(isPrivacyPolicy: isPrivacyPolicy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isPrivacyPolicy ? 'Privacy Policy' : 'Terms of Service';
    final subtitle = isPrivacyPolicy
        ? 'How MyAlien protects your personal data & privacy'
        : 'Rules & safety standards for the MyAlien community';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPrivacyPolicy
                        ? Icons.privacy_tip_outlined
                        : Icons.description_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),

            // Content Sections
            Expanded(
              child: SingleChildScrollView(
                child: isPrivacyPolicy
                    ? _buildPrivacyPolicyContent()
                    : _buildTermsOfServiceContent(),
              ),
            ),

            const SizedBox(height: 16),
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'I Understand & Close',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsOfServiceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          number: '1',
          title: 'Age Eligibility & Community Purpose',
          body:
              'MyAlien is strictly intended for individuals aged 18 and older. '
              'The platform connects companions for verified in-person and digital '
              'hangouts, networking, hobbies, and social interactions in public venues.',
        ),
        _buildSection(
          number: '2',
          title: 'Code of Conduct & Mutual Respect',
          body:
              'Users must treat companions with dignity and respect. Any form of '
              'harassment, intimidation, inappropriate physical conduct, or solicitation '
              'will result in immediate account termination and permanent blacklisting.',
        ),
        _buildSection(
          number: '3',
          title: 'Public Venues & Safety First',
          body:
              'All scheduled hangouts must take place in verified public locations '
              '(such as cafes, restaurants, art galleries, and parks). Private residence '
              'meetups are prohibited during initial hangouts.',
        ),
        _buildSection(
          number: '4',
          title: 'Coins & Booking Transactions',
          body:
              'All bookings must be processed via official in-app Coin reservations. '
              'Direct cash payments or offline transactions outside the platform '
              'are not supported and violate our safety guarantee.',
        ),
        _buildSection(
          number: '5',
          title: 'Cancellation & Rescheduling Policy',
          body:
              'Hangout reservations can be cancelled with full coin refunds up to 2 hours '
              'before the scheduled start time. Late cancellations or no-shows may incur '
              'standard cancellation deductions.',
        ),
      ],
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          number: '1',
          title: 'Information We Collect',
          body:
              'We collect your mobile phone number for OTP verification, your profile '
              'name, photos you choose to upload, and city-level location to discover nearby '
              'companions. We never access private SMS messages or contacts without consent.',
        ),
        _buildSection(
          number: '2',
          title: 'How Your Data Is Used',
          body:
              'Your profile details are shown to verified users on MyAlien to facilitate '
              'discovery and bookings. Your real mobile phone number is always masked and '
              'never shared with other users.',
        ),
        _buildSection(
          number: '3',
          title: 'Location & GPS Privacy',
          body:
              'Approximate city/neighbourhood information is used for distance matching. '
              'Your precise real-time GPS coordinates are never broadcasted or displayed '
              'publicly on your profile.',
        ),
        _buildSection(
          number: '4',
          title: 'In-App Messaging & Confidentiality',
          body:
              'Direct chat messages between you and your companions are encrypted in transit. '
              'Automated safety checks protect against fraud, spam, and harmful content.',
        ),
        _buildSection(
          number: '5',
          title: 'Data Deletion & Account Rights',
          body:
              'You have full ownership of your data. You may request account deletion, photo '
              'removals, or profile updates at any time via Settings or our support team.',
        ),
      ],
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/theme_manager.dart';

class PrivacyAndDataScreen extends StatefulWidget {
  const PrivacyAndDataScreen({super.key});

  @override
  State<PrivacyAndDataScreen> createState() => _PrivacyAndDataScreenState();
}

class _PrivacyAndDataScreenState extends State<PrivacyAndDataScreen> {
  late ThemeManager theme;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    theme = ThemeManager();
  }

  @override
  void didChangeDependencies() {
    _loadTheme();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        title: const Text('PRIVACY & DATA'),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Privacy Policy', [
              'We respect your privacy and are committed to protecting your personal data.',
              'All user data is encrypted and stored securely using Firebase.',
              'We do not share your information with third parties without consent.',
              'You have the right to access, modify, or delete your data.',
            ]),
            const SizedBox(height: 20),
            _buildSection('Data Collection', [
              '• Fitness activity data (steps, workouts, sessions)',
              '• User profile information (name, avatar)',
              '• Achievement and streak data',
              '• Device information and app usage statistics',
              '• Location data (only when explicitly enabled)',
            ]),
            const SizedBox(height: 20),
            _buildSection('Data Security', [
              'End-to-end encryption for sensitive data',
              'Regular security audits and updates',
              'Compliance with GDPR and data protection regulations',
              'Secure authentication using Firebase Auth',
              'Data retention policies: 30 days inactive = auto-purge',
            ]),
            const SizedBox(height: 20),
            _buildSection('Your Rights', [
              '✓ Right to access your data',
              '✓ Right to rectify inaccurate data',
              '✓ Right to erasure ("right to be forgotten")',
              '✓ Right to restrict processing',
              '✓ Right to data portability',
              '✓ Right to object to processing',
            ]),
            const SizedBox(height: 20),
            _buildSection('Contact Us', [
              'For privacy concerns or data requests:',
              'Email: privacy@stride.app',
              'Support: support@stride.app',
              'Response time: Within 48 hours',
            ]),
            const SizedBox(height: 20),
            _buildButton('I UNDERSTAND & ACCEPT', () {
              Navigator.pop(context);
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: theme.textColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.8),
            border: Border.all(
              color: theme.accentColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.subText,
                        height: 1.6,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  late ThemeManager theme;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    theme = ThemeManager();
  }

  @override
  void didChangeDependencies() {
    _loadTheme();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        title: const Text('TERMS OF SERVICE'),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTerm('1. Acceptance of Terms', 
              'By using Stride, you agree to comply with these terms and conditions. '
              'If you do not agree, please discontinue using the app immediately.'
            ),
            _buildTerm('2. User Eligibility',
              'You must be at least 13 years old to use this app. Users under 18 need parental consent. '
              'You are responsible for all activities under your account.'
            ),
            _buildTerm('3. Intellectual Property',
              'All content, features, and functionality are owned by Stride, including but not limited to: '
              'text, graphics, logos, icons, images, audio, video, and software code. '
              'Unauthorized use is prohibited.'
            ),
            _buildTerm('4. User Conduct',
              'You agree not to: Use the app for illegal purposes, Harass or abuse other users, '
              'Distribute malware, Attempt to gain unauthorized access, Spam or send unsolicited content.'
            ),
            _buildTerm('5. Fitness Disclaimer',
              'Stride is a fitness tracking app, not medical advice. Consult a healthcare professional before '
              'starting any fitness program. We are not liable for injuries or health issues related to app usage.'
            ),
            _buildTerm('6. Account Termination',
              'We reserve the right to suspend or terminate accounts that violate these terms without notice. '
              'Data associated with terminated accounts will be retained for 30 days before permanent deletion.'
            ),
            _buildTerm('7. Limitation of Liability',
              'Stride is provided "as-is" without warranties. We are not responsible for data loss, service interruptions, '
              'or indirect damages. Your liability is limited to amounts paid for the app.'
            ),
            _buildTerm('8. Changes to Terms',
              'We may update these terms at any time. Continued use of the app after updates constitutes acceptance. '
              'Check this page regularly for changes.'
            ),
            _buildTerm('9. Governing Law',
              'These terms are governed by the laws of the jurisdiction in which Stride is provided. '
              'Any disputes will be resolved in applicable courts.'
            ),
            _buildTerm('10. Contact',
              'For terms inquiries: legal@stride.app\n'
              'Last Updated: January 2026'
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTerm(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: theme.textColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.8),
              border: Border.all(
                color: theme.accentColor.withOpacity(0.15),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 12,
                color: theme.subText,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataServicesScreen extends StatefulWidget {
  const DataServicesScreen({super.key});

  @override
  State<DataServicesScreen> createState() => _DataServicesScreenState();
}

class _DataServicesScreenState extends State<DataServicesScreen> {
  late ThemeManager theme;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    theme = ThemeManager();
  }

  @override
  void didChangeDependencies() {
    _loadTheme();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        title: const Text('DATA SERVICES'),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceCard(
              icon: '📊',
              title: 'Analytics & Insights',
              description: 'Real-time tracking of your fitness metrics, progress analytics, '
                'and personalized insights based on your activity patterns.',
              features: [
                'Daily activity reports',
                'Weekly progress summaries',
                'Performance trends',
                'Goal tracking',
              ],
            ),
            const SizedBox(height: 16),
            _buildServiceCard(
              icon: '☁️',
              title: 'Cloud Sync',
              description: 'Automatic synchronization of your data across all devices. '
                'Your data is securely backed up to Firebase.',
              features: [
                'Multi-device sync',
                'Automatic backups',
                'Real-time updates',
                'Offline access',
              ],
            ),
            const SizedBox(height: 16),
            _buildServiceCard(
              icon: '🔔',
              title: 'Notifications',
              description: 'Smart notification system to keep you engaged and motivated.',
              features: [
                'Streak reminders',
                'Achievement alerts',
                'Scheduled notifications',
                'Custom sound alerts',
              ],
            ),
            const SizedBox(height: 16),
            _buildServiceCard(
              icon: '🎯',
              title: 'Social Features',
              description: 'Connect with friends, share achievements, and compete on leaderboards.',
              features: [
                'Friend requests',
                'Activity sharing',
                'Leaderboards',
                'Challenge invites',
              ],
            ),
            const SizedBox(height: 16),
            _buildServiceCard(
              icon: '🔐',
              title: 'Security Services',
              description: 'Enterprise-grade security for your fitness data and personal information.',
              features: [
                'End-to-end encryption',
                '2FA support',
                'Session management',
                'Activity logs',
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String icon,
    required String title,
    required String description,
    required List<String> features,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.8),
        border: Border.all(
          color: theme.accentColor.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: theme.textColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: theme.subText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: features
                .map(
                  (feature) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withOpacity(0.1),
                      border: Border.all(
                        color: theme.accentColor.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.accentColor,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

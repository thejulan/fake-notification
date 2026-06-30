import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fake Notification Privacy Policy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your privacy is extremely important to us. Fake Notification is designed from the ground up to respect your data and privacy.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              '1. Data Collection & Storage',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fake Notification is a completely offline, local-only application. We do not collect, transmit, share, or store any of your personal information, notification content, or app usage data on external servers. All variations, presets, and notification texts are saved strictly on your local device storage using SharedPreferences.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              '2. Permissions Requested',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'In order to function properly, this app requires the following permissions:\n\n'
              '• Notification Permission (POST_NOTIFICATIONS): Required to display the spoofed notifications on your device.\n'
              '• Query All Packages (QUERY_ALL_PACKAGES): Required strictly to fetch and display the list of installed applications and their icons on your device, allowing you to select which app to spoof.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              '3. Third-Party Services',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This application contains absolutely no third-party analytics, tracking scripts, or advertisement SDKs. Your activities inside the app remain entirely private.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              '4. Changes to This Policy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We may update our Privacy Policy from time to time. However, our core commitment to keeping this app 100% offline and local will never change.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('I Understand'),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

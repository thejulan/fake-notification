import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info & Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.info(PhosphorIconsStyle.duotone),
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fake Notification',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Version 1.0.0'),
                  const SizedBox(height: 24),
                  const Text(
                    'This app is designed to help you create realistic notifications for harmless pranks or getting out of awkward situations. Please use responsibly.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: PhosphorIcon(PhosphorIcons.githubLogo()),
            title: const Text('Source Code'),
            trailing: PhosphorIcon(PhosphorIcons.caretRight()),
            onTap: () {
              launchUrl(Uri.parse('https://github.com/fake-notification'), mode: LaunchMode.externalApplication);
            },
          ),
          ListTile(
            leading: PhosphorIcon(PhosphorIcons.shieldCheck()),
            title: const Text('Privacy Policy'),
            trailing: PhosphorIcon(PhosphorIcons.caretRight()),
            onTap: () {
              Navigator.pushNamed(context, '/privacy');
            },
          ),
          ListTile(
            leading: PhosphorIcon(PhosphorIcons.bug()),
            title: const Text('Report Bug / Request Feature'),
            trailing: PhosphorIcon(PhosphorIcons.caretRight()),
            onTap: () {
              launchUrl(Uri.parse('https://github.com/fake-notification/issues/new'), mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }
}

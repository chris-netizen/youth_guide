// settings_page.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  String? version;

  @override
  void initState() {
    getVersion();
    super.initState();
  }

  void getVersion() async {
    version = await getAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.themeMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Theme Mode
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: currentTheme,
              onChanged: (mode) => themeProvider.setTheme(mode!),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),

          const Divider(),

          // Placeholder for font size
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: const Text('Small / Medium / Large'),
            onTap: () {}, // TODO: Implement font size selection
          ),

          // Placeholder for daily notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Daily Devotional Reminder'),
            value: true,
            onChanged: (value) {
              // TODO: Implement notification toggle logic
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Devotional App',
                applicationVersion: version,
                children: const [
                  Text('Stay inspired with daily devotional content.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

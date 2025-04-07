// settings_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:youth_guide/screens/speech/speech.dart';
import 'package:youth_guide/service/database/versions.dart';
import 'package:youth_guide/service/providers/bible_provider.dart';
import 'package:youth_guide/service/providers/font_provider.dart';
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
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Appearance',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
          ),

          // Theme Mode
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(
              'Theme Mode',
              style: GoogleFonts.merriweather(fontSize: fontSize),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: currentTheme,
              onChanged: (mode) => themeProvider.setTheme(mode!),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(
                    'System',
                    style: GoogleFonts.merriweather(fontSize: fontSize),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(
                    'Light',
                    style: GoogleFonts.merriweather(fontSize: fontSize),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(
                    'Dark',
                    style: GoogleFonts.merriweather(fontSize: fontSize),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Placeholder for font size
          Consumer<FontSizeProvider>(
            builder: (context, fontSizeProvider, _) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: Text(
                      'Font Size',
                      style: GoogleFonts.merriweather(fontSize: fontSize),
                    ),
                    subtitle: Slider(
                      value: fontSizeProvider.fontSize,
                      min: 12.0,
                      max: 20.0,
                      divisions: 4,
                      label: fontSizeProvider.fontSize.toStringAsFixed(0),
                      onChanged: (value) => fontSizeProvider.setFontSize(value),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset Font Size',
                      onPressed: () => fontSizeProvider.resetFontSize(),
                    ),
                  ),
                ],
              );
            },
          ),

          Consumer<LocalBibleProvider>(
            builder: (context, bibleVersionProvider, _) {
              return ListTile(
                leading: const Icon(Icons.book),
                title: Text(
                  'Bible Version',
                  style: GoogleFonts.merriweather(fontSize: fontSize),
                ),
                trailing: DropdownButton<String>(
                  value: bibleVersionProvider.selectedVersion,
                  onChanged: (newVersion) {
                    if (newVersion != null) {
                      bibleVersionProvider.setVersion(newVersion);
                    }
                  },
                  items:
                      [
                        AppVersions.kjv.name,
                        AppVersions.niv.name,
                        AppVersions.nkjv.name,
                        AppVersions.nlt.name,
                      ].map((version) {
                        return DropdownMenuItem(
                          value: version,
                          child: Text(
                            version,
                            style: GoogleFonts.merriweather(fontSize: fontSize),
                          ),
                        );
                      }).toList(),
                ),
              );
            },
          ),

          // Placeholder for daily notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: Text(
              'Daily Devotional Reminder',
              style: GoogleFonts.merriweather(fontSize: fontSize),
            ),
            value: true,
            onChanged: (value) {
              // TODO: Implement notification toggle logic
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: Text(
              'Directorate of Evangelism',
              style: GoogleFonts.merriweather(fontSize: fontSize),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppForeward()),
              );
            },
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(
              'About',
              style: GoogleFonts.merriweather(fontSize: fontSize),
            ),
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

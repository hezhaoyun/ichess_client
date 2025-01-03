import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../game/config_manager.dart';

class LanguageSettingsPage extends StatelessWidget {
  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Русский', 'code': 'ru'},
    {'name': 'Deutsch', 'code': 'de'},
    {'name': 'Español', 'code': 'es'},
    {'name': 'Français', 'code': 'fr'},
    {'name': 'Italiano', 'code': 'it'},
    {'name': 'Polski', 'code': 'pl'},
    {'name': 'हिन्दी', 'code': 'hi'},
    {'name': 'العربية', 'code': 'ar'},
    {'name': '中文', 'code': 'zh'},
    {'name': '한국어', 'code': 'ko'},
    {'name': '日本語', 'code': 'ja'},
  ];

  LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.language),
          title: Text(languages[index]['name']!),
          onTap: () => _changeLanguage(context, languages[index]['code']!),
        ),
      ),
    );
  }

  Future<void> _changeLanguage(BuildContext context, String languageCode) async {
    final appConfigManager = Provider.of<ConfigManager>(context, listen: false);
    await appConfigManager.setLanguage(languageCode);
    if (context.mounted) Navigator.of(context).pop();
  }
}

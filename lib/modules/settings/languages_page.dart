import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ichess/model/config_manager.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../model/theme_manager.dart';

final List<Map<String, dynamic>> languages = [
  {
    'name': 'English',
    'code': 'en',
    'countries': ['gb', 'us', 'au', 'ca', 'nz', 'ie', 'za', 'in', 'ph', 'sg']
  },
  {
    'name': 'Русский',
    'code': 'ru',
    'countries': ['ru', 'by', 'kz', 'kg', 'md', 'tj', 'uz', 'am']
  },
  {
    'name': 'Deutsch',
    'code': 'de',
    'countries': ['de', 'at', 'ch', 'li', 'lu', 'be']
  },
  {
    'name': 'Español',
    'code': 'es',
    'countries': [
      'es',
      'mx',
      'ar',
      'co',
      'pe',
      've',
      'cl',
      'ec',
      'gt',
      'cu',
      'bo',
      'do',
      'hn',
      'py',
      'sv',
      'ni',
      'cr',
      'pa',
      'uy'
    ]
  },
  {
    'name': 'Français',
    'code': 'fr',
    'countries': ['fr', 'ca', 'be', 'ch', 'lu', 'mc', 'sn', 'ci', 'mg', 'cm', 'dj', 'ml', 'ne', 'bf', 'tg']
  },
  {
    'name': 'Italiano',
    'code': 'it',
    'countries': ['it', 'ch', 'sm', 'va', 'mt']
  },
  {
    'name': 'Polski',
    'code': 'pl',
    'countries': ['pl']
  },
  {
    'name': 'हिन्दी',
    'code': 'hi',
    'countries': ['in', 'fj', 'mu', 'gy', 'sr', 'tt']
  },
  {
    'name': 'العربية',
    'code': 'ar',
    'countries': [
      'sa',
      'eg',
      'ae',
      'dz',
      'bh',
      'td',
      'km',
      'dj',
      'er',
      'iq',
      'jo',
      'kw',
      'lb',
      'ly',
      'mr',
      'ma',
      'om',
      'ps',
      'qa',
      'so',
      'sd',
      'sy',
      'tn',
      'ye'
    ]
  },
  {
    'name': '中文',
    'code': 'zh',
    'countries': ['cn', 'tw', 'hk', 'mo', 'sg', 'my']
  },
  {
    'name': '한국어',
    'code': 'ko',
    'countries': ['kr', 'kp']
  },
  {
    'name': '日本語',
    'code': 'ja',
    'countries': ['jp']
  },
];

String getLanguageName(String code) {
  return languages.firstWhere((language) => language['code'] == code)['name'] ?? '';
}

class LanguagesPage extends ConsumerWidget {
  const LanguagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeManagerProvider);
    final language = ref.watch(configManagerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.language)),
      body: ListView.separated(
        itemCount: languages.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(languages[index]['code']!, style: const TextStyle(color: Colors.white)),
          ),
          title: Text(languages[index]['name']!),
          subtitle: Wrap(
            spacing: 4,
            children: languages[index]['countries']!.map<Widget>((countryCode) {
              return Text(
                getFlagEmoji(countryCode),
                style: const TextStyle(fontSize: 24),
              );
            }).toList(),
          ),
          trailing: Icon(
            Icons.check_circle,
            color: languages[index]['code'] == language ? theme.primaryColor : Colors.transparent,
          ),
          onTap: () => _changeLanguage(context, ref, languages[index]['code']!),
        ),
      ),
    );
  }

  String getFlagEmoji(String countryCode) {
    if (countryCode.toUpperCase() == 'TW') {
      // iOS 使用替代符号，其他平台尝试使用原始符号
      if (Platform.isIOS || Platform.isMacOS) return '🏴';
      return '🇹🇼';
    }

    // 常规国家代码处理
    return countryCode.toUpperCase().replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
        );
  }

  Future<void> _changeLanguage(BuildContext context, WidgetRef ref, String languageCode) async {
    final configManager = ref.read(configManagerProvider.notifier);
    await configManager.setLanguage(languageCode);
    if (context.mounted) Navigator.of(context).pop();
  }
}

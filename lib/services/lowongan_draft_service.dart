import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LowonganDraftService {
  static const _key = 'mitra_lowongan_drafts';

  static Future<List<Map<String, dynamic>>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_key) ?? const <String>[];
    return raw
        .map(jsonDecode)
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }

  static Future<void> save(Map<String, dynamic> draft) async {
    final preferences = await SharedPreferences.getInstance();
    final drafts = preferences.getStringList(_key) ?? <String>[];
    drafts.insert(0, jsonEncode(draft));
    await preferences.setStringList(_key, drafts);
  }

  static Future<void> deleteAt(int index) async {
    final preferences = await SharedPreferences.getInstance();
    final drafts = preferences.getStringList(_key) ?? <String>[];
    if (index < 0 || index >= drafts.length) return;
    drafts.removeAt(index);
    await preferences.setStringList(_key, drafts);
  }
}

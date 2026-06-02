import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPronunciationStore {
  static const _key = 'user_pronunciations'; // word -> file path

  Future<String> newRecordingPath(String word) async {
    final dir = await _pronunciationDir();
    final safe = word.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final fileName = '${safe}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return p.join(dir.path, fileName);
  }

  Future<Directory> _pronunciationDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'pronunciations'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> savePathForWord(String word, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _loadMap(prefs);
    map[word.toLowerCase()] = filePath;
    await prefs.setString(_key, jsonEncode(map));
  }

  Future<String?> getPathForWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _loadMap(prefs);
    final path = map[word.toLowerCase()];
    if (path == null) return null;
    if (!await File(path).exists()) return null;
    return path;
  }

  Future<void> deleteForWord(String word) async {
    final path = await getPathForWord(word);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    final prefs = await SharedPreferences.getInstance();
    final map = await _loadMap(prefs);
    map.remove(word.toLowerCase());
    await prefs.setString(_key, jsonEncode(map));
  }

  Future<Map<String, String>> _loadMap(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
}

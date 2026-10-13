import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/personnel_model.dart';

class StorageService {
  static const String _personnelKey = 'personnel_data';
  static const String _legacyPersonnelListKey = 'personnel_list';

  Future<void> savePersonnelData(Map<String, dynamic> jsonData) async {
    PersonnelFile.fromJson(jsonData);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_personnelKey, jsonEncode(jsonData));
    await prefs.remove(_legacyPersonnelListKey);
  }

  Future<PersonnelFile?> getPersonnelFile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_personnelKey);
    if (jsonString == null) return null;
    return PersonnelFile.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<List<PersonnelModel>?> getPersonnelList() async {
    return (await getPersonnelFile())?.getPersonnelList();
  }

  Future<bool> hasPersonnelData() async {
    try {
      return await getPersonnelFile() != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_personnelKey);
    await prefs.remove(_legacyPersonnelListKey);
  }
}

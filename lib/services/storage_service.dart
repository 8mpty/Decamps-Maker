import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/personnel_model.dart';

class StorageService {
  static const String _personnelKey = 'personnel_data';
  static const String _selectedRotaKey = 'selected_rota';
  static const String _legacyPersonnelListKey = 'personnel_list';
  static const String _hideDateFormatKey = 'hide_inc_date_format';
  static const String _hideScKey = 'hide_sc';

  Future<void> savePersonnelData(Map<String, dynamic> jsonData) async {
    final personnelFile = PersonnelFile.fromJson(jsonData);
    if (personnelFile.getPersonnelList().isEmpty) {
      throw const FormatException(
        'No personnel found. Expected a "personnel" map containing a '
        'recognised category such as "CFS", "Firefighters" or "Alpha".',
      );
    }

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

  Future<String?> getSelectedRota() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedRotaKey);
  }

  Future<void> saveSelectedRota(String rota) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedRotaKey, rota);
  }

  Future<bool> getHideDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hideDateFormatKey) ?? false;
  }

  Future<void> saveHideDateFormat(bool hide) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideDateFormatKey, hide);
  }

  Future<bool> getHideSc() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hideScKey) ?? false;
  }

  Future<void> saveHideSc(bool hide) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideScKey, hide);
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
    await prefs.remove(_selectedRotaKey);
    await prefs.remove(_legacyPersonnelListKey);
    await prefs.remove(_hideDateFormatKey);
    await prefs.remove(_hideScKey);
  }
}

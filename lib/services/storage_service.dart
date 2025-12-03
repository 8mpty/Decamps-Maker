import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/personnel_model.dart';

class StorageService {
  static const String _personnelKey = 'personnel_data';
  static const String _personnelListKey = 'personnel_list';

  Future<void> savePersonnelData(Map<String, dynamic> jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_personnelKey, jsonEncode(jsonData));
    
    final personnelFile = PersonnelFile.fromJson(jsonData);
    final personnelList = personnelFile.getPersonnelList();
    final listJson = personnelList.map((person) => {
      'name': person.name,
      'fullRank': person.fullRank,
      'hp': person.hp,
      'rankAbbreviation': person.rankAbbreviation,
      'category': person.category,
    }).toList();
    
    await prefs.setString(_personnelListKey, jsonEncode(listJson));
  }

  Future<List<PersonnelModel>?> getPersonnelList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_personnelListKey);
    
    if (jsonString == null) return null;
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => PersonnelModel(
      name: item['name'] as String,
      fullRank: item['fullRank'] as String,
      hp: item['hp'] as String?,
      rankAbbreviation: item['rankAbbreviation'] as String,
      category: item['category'] as String,
    )).toList();
  }

  Future<bool> hasPersonnelData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_personnelListKey);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_personnelKey);
    await prefs.remove(_personnelListKey);
  }
}
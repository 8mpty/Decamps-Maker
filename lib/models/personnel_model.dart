class PersonnelModel {
  final String name;
  final String fullRank;
  final String? hp;
  final String rankAbbreviation;
  final String category;

  PersonnelModel({
    required this.name,
    required this.fullRank,
    this.hp,
    required this.rankAbbreviation,
    required this.category,
  });

  @override
  String toString() {
    return '$rankAbbreviation $name ${hp != null ? '- $hp' : ''}';
  }
}

class PersonnelFile {
  final int rota;
  final String organization;
  final Map<String, dynamic> personnelData;

  PersonnelFile({
    required this.rota,
    required this.organization,
    required this.personnelData,
  });

  factory PersonnelFile.fromJson(Map<String, dynamic> json) {
    return PersonnelFile(
      rota: json['rota'] as int,
      organization: json['organization'] as String,
      personnelData: json['personnel'] as Map<String, dynamic>,
    );
  }

  List<PersonnelModel> getPersonnelList() {
    final List<PersonnelModel> personnel = [];
    
    if (personnelData['CFS'] != null) {
      final cfsData = personnelData['CFS'] as Map<String, dynamic>;
      cfsData.forEach((rankAbbreviation, data) {
        final personnelData = data as Map<String, dynamic>;
        personnel.add(PersonnelModel(
          name: personnelData['name'] as String,
          fullRank: personnelData['full_rank'] as String,
          hp: personnelData['hp'] as String?,
          rankAbbreviation: rankAbbreviation,
          category: 'CFS',
        ));
      });
    }
    
    if (personnelData['Firefighters'] != null) {
      final firefightersData = personnelData['Firefighters'] as Map<String, dynamic>;
      firefightersData.forEach((rankAbbreviation, data) {
        final personnelList = data as List<dynamic>;
        for (var person in personnelList) {
          final personnelData = person as Map<String, dynamic>;
          personnel.add(PersonnelModel(
            name: personnelData['name'] as String,
            fullRank: personnelData['full_rank'] as String,
            hp: personnelData['hp'] as String?,
            rankAbbreviation: rankAbbreviation,
            category: 'Firefighters',
          ));
        }
      });
    }
    
    return personnel;
  }
}
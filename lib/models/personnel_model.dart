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
  static const Set<String> _includedCategories = {'CFS', 'Firefighters'};
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
    personnelData.forEach((category, categoryData) {
      if (!_includedCategories.contains(category)) return;
      if (categoryData is! Map<String, dynamic>) return;
      categoryData.forEach((rankAbbreviation, data) {
        personnel.addAll(_parseRankGroup(
          category: category,
          rankAbbreviation: rankAbbreviation,
          data: data,
        ));
      });
    });

    return personnel;
  }

  static List<PersonnelModel> _parseRankGroup({
    required String category,
    required String rankAbbreviation,
    required dynamic data,
  }) {
    final Iterable<dynamic> persons =
        data is List<dynamic> ? data : <dynamic>[data];

    return persons.map((person) {
      final personData = person as Map<String, dynamic>;
      return PersonnelModel(
        name: personData['name'] as String,
        fullRank: personData['full_rank'] as String,
        hp: personData['hp'] as String?,
        rankAbbreviation: rankAbbreviation,
        category: category,
      );
    }).toList();
  }
}
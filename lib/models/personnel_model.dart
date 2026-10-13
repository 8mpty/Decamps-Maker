class PersonnelModel {
  final String name;
  final String fullRank;
  final String? hp;
  final String rankAbbreviation;
  final String category;
  final String? rota;

  PersonnelModel({
    required this.name,
    required this.fullRank,
    this.hp,
    required this.rankAbbreviation,
    required this.category,
    this.rota,
  });

  @override
  String toString() {
    return '$rankAbbreviation $name ${hp != null ? '- $hp' : ''}';
  }
}

class PersonnelFile {
  static const Set<String> _includedCategories = {'CFS', 'Firefighters', 'Alpha'};
  final int? rota;
  final String organization;
  final Map<String, dynamic> personnelData;

  PersonnelFile({
    required this.rota,
    required this.organization,
    required this.personnelData,
  });

  factory PersonnelFile.fromJson(Map<String, dynamic> json) {
    return PersonnelFile(
      rota: json['rota'] as int?,
      organization: json['organization'] as String,
      personnelData: json['personnel'] as Map<String, dynamic>,
    );
  }

  List<String> getRotas() {
    final rotas = <String>[];
    for (final person in _parseAll()) {
      final rota = person.rota;
      if (rota != null && !rotas.contains(rota)) {
        rotas.add(rota);
      }
    }
    return rotas;
  }

  List<PersonnelModel> getPersonnelList({String? rota}) {
    final personnel = _parseAll();
    if (rota == null) return personnel;
    return personnel
        .where((person) => person.rota == null || person.rota == rota)
        .toList();
  }

  List<PersonnelModel> _parseAll() {
    final personnel = <PersonnelModel>[];
    personnelData.forEach((category, categoryData) {
      if (!_includedCategories.contains(category)) return;
      if (categoryData is! Map<String, dynamic>) return;
      categoryData.forEach((key, value) {
        if (_isRotaGroup(value)) {
          (value as Map<String, dynamic>).forEach((rankAbbreviation, data) {
            personnel.addAll(_parseRankGroup(
              category: category,
              rota: key,
              rankAbbreviation: rankAbbreviation,
              data: data,
            ));
          });
        } else {
          personnel.addAll(_parseRankGroup(
            category: category,
            rota: null,
            rankAbbreviation: key,
            data: value,
          ));
        }
      });
    });

    return personnel;
  }

  static bool _isRotaGroup(dynamic value) {
    return value is Map<String, dynamic> && !value.containsKey('name');
  }

  static List<PersonnelModel> _parseRankGroup({
    required String category,
    required String? rota,
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
        rota: rota,
      );
    }).toList();
  }
}
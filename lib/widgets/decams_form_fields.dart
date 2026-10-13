import 'package:flutter/material.dart';
import 'package:tuas_decamps_maker/models/personnel_model.dart';
import 'package:tuas_decamps_maker/utils/form_validators.dart';
import 'package:tuas_decamps_maker/constants/app_constants.dart';

class DecamsFormFields extends StatelessWidget {
  final String? selectedAppliance;
  final ValueChanged<String?> onApplianceChanged;
  final PersonnelModel? selectedPersonnel;
  final ValueChanged<PersonnelModel?> onPersonnelChanged;
  final List<PersonnelModel> personnelList;
  final TextEditingController locationController;
  final String? selectedCaseOf;
  final ValueChanged<String?> onCaseOfChanged;
  final TextEditingController callerNameController;

  const DecamsFormFields({
    super.key,
    required this.selectedAppliance,
    required this.onApplianceChanged,
    required this.selectedPersonnel,
    required this.onPersonnelChanged,
    required this.personnelList,
    required this.locationController,
    required this.selectedCaseOf,
    required this.onCaseOfChanged,
    required this.callerNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedAppliance,
          decoration: const InputDecoration(
            labelText: 'Appliance *',
            border: OutlineInputBorder(),
          ),
          items: AppConstants.applianceOptions.map((appliance) {
            return DropdownMenuItem(value: appliance, child: Text(appliance));
          }).toList(),
          onChanged: onApplianceChanged,
          validator: FormValidators.createRequiredValidator('Appliance'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<PersonnelModel>(
          initialValue: selectedPersonnel,
          decoration: const InputDecoration(
            labelText: 'SC Personnel *',
            border: OutlineInputBorder(),
          ),
          items: _buildPersonnelItems(context),
          onChanged: onPersonnelChanged,
          validator: (value) => FormValidators.validateRequired(
            value?.toString(),
            'SC Personnel',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: locationController,
          decoration: const InputDecoration(
            labelText: 'Location *',
            border: OutlineInputBorder(),
          ),
          validator: FormValidators.createRequiredValidator('Location'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedCaseOf,
          decoration: const InputDecoration(
            labelText: 'Case Of *',
            border: OutlineInputBorder(),
          ),
          items: AppConstants.caseOptions.map((caseType) {
            return DropdownMenuItem(value: caseType, child: Text(caseType));
          }).toList(),
          onChanged: onCaseOfChanged,
          validator: FormValidators.createRequiredValidator('Case Of'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: callerNameController,
          decoration: const InputDecoration(
            labelText: 'Caller Name',
            border: OutlineInputBorder(),
          ),
          // validator: FormValidators.createRequiredValidator('Caller Name'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Custom method to build the personnel dropdown items with section headers
  List<DropdownMenuItem<PersonnelModel>> _buildPersonnelItems(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    final items = <DropdownMenuItem<PersonnelModel>>[];
    String? currentCategory;
    for (final personnel in personnelList) {
      if (personnel.category != currentCategory) {
        currentCategory = personnel.category;
        items.add(
          DropdownMenuItem<PersonnelModel>(
            enabled: false,
            value: _PersonnelSectionHeader(currentCategory),
            child: Text(currentCategory, style: headerStyle),
          ),
        );
      }
      items.add(
        DropdownMenuItem(value: personnel, child: Text(personnel.toString())),
      );
    }
    return items;
  }
}

class _PersonnelSectionHeader extends PersonnelModel {
  _PersonnelSectionHeader(String category)
    : super(name: '', fullRank: '', rankAbbreviation: '', category: category);
}

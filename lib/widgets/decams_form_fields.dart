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
          items:  AppConstants.applianceOptions.map((appliance) {
            return DropdownMenuItem(
              value: appliance,
              child: Text(appliance),
            );
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
          items: personnelList.map((personnel) {
            return DropdownMenuItem(
              value: personnel,
              child: Text(personnel.toString()),
            );
          }).toList(),
          onChanged: onPersonnelChanged,
          validator: (value) => FormValidators.validateRequired(
            value?.toString(), 
            'SC Personnel'
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
            return DropdownMenuItem(
              value: caseType,
              child: Text(caseType),
            );
          }).toList(),
          onChanged: onCaseOfChanged,
          validator: FormValidators.createRequiredValidator('Case Of'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: callerNameController,
          decoration: const InputDecoration(
            labelText: 'Caller Name *',
            border: OutlineInputBorder(),
          ),
          validator: FormValidators.createRequiredValidator('Caller Name'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IncidentDetailsSection extends StatelessWidget {
  final DateTime selectedDate;
  final Function(BuildContext) onDateSelected;
  final TextEditingController incNumberController;
  final String? Function(String?) validator;

  const IncidentDetailsSection({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.incNumberController,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Incident Details *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => onDateSelected(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Incident Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: incNumberController,
                    decoration: InputDecoration(
                      labelText: 'Incident Number',
                      border: const OutlineInputBorder(),
                      hintText: '',
                      errorStyle: const TextStyle(
                        fontSize: 12,
                        height: 0.8,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: validator,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Incident No. will be: /${selectedDate.year}${selectedDate.month.toString().padLeft(2, '0')}${selectedDate.day.toString().padLeft(2, '0')}/${incNumberController.text}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
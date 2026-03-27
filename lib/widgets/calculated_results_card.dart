import 'package:flutter/material.dart';

class CalculatedResultsCard extends StatelessWidget {
  final String activationResult;
  final String responseResult;

  const CalculatedResultsCard({
    super.key,
    required this.activationResult,
    required this.responseResult,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculated Results:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Activation: $activationResult',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Response: $responseResult',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
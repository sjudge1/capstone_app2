import 'package:flutter/material.dart';
import '../models/person.dart';

class ComparisonScreen extends StatelessWidget {
  final Person person1;
  final Person person2;

  const ComparisonScreen({
    Key? key,
    required this.person1,
    required this.person2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLung = person1.organType.toLowerCase() == 'lung';
    final color = isLung ? Colors.blue : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with names
            Row(
              children: [
                Expanded(
                  child: _buildPersonHeader(person1, color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPersonHeader(person2, color),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Medical Information Section
            Text(
              'Medical Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildMedicalInfo(person1, isLung),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMedicalInfo(person2, isLung),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contact Information Section
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildContactInfo(person1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactInfo(person2),
                ),
              ],
            ),
            if ((person1.notes?.isNotEmpty ?? false) || (person2.notes?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 24),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildNotes(person1, context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNotes(person2, context),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonHeader(Person person, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            person.type == PersonType.patient ? Icons.person_outline : Icons.volunteer_activism,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            person.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            person.type == PersonType.patient ? 'Recipient' : 'Donor',
            style: TextStyle(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfo(Person person, bool isLung) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLung)
          _buildDetailRow('Predicted TLC', '${person.predictedTotalLungCapacity?.toStringAsFixed(2) ?? 'N/A'} L')
        else
          _buildDetailRow('Predicted Heart Mass', '${person.predictedTotalHeartMass?.toStringAsFixed(2) ?? 'N/A'} g'),
        _buildDetailRow('Age', person.age?.toString() ?? 'N/A'),
        _buildDetailRow('Height', '${person.height} cm'),
        _buildDetailRow('Weight', '${person.weight} kg'),
        _buildDetailRow('Gender', person.gender ?? 'N/A'),
        _buildDetailRow('Blood Type', person.bloodType ?? 'N/A'),
      ],
    );
  }

  Widget _buildContactInfo(Person person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Phone', person.contactNumber ?? 'N/A'),
        _buildDetailRow('Email', person.email ?? 'N/A'),
        _buildDetailRow('Address', person.address ?? 'N/A'),
      ],
    );
  }

  Widget _buildNotes(Person person, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        person.notes ?? 'No notes',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 
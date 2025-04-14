import 'package:flutter/material.dart';
import '../models/person.dart';

class HeartCalculatorResultsScreen extends StatefulWidget {
  final double recipientLeftVentricularMass;
  final double recipientRightVentricularMass;
  final double recipientTotalHeartMass;
  final double donorLeftVentricularMass;
  final double donorRightVentricularMass;
  final double donorTotalHeartMass;
  final double massDifferencePercentage;
  final String? recipientBloodType;
  final String? donorBloodType;
  final String? recipientName;
  final String? donorName;

  const HeartCalculatorResultsScreen({
    Key? key,
    required this.recipientLeftVentricularMass,
    required this.recipientRightVentricularMass,
    required this.recipientTotalHeartMass,
    required this.donorLeftVentricularMass,
    required this.donorRightVentricularMass,
    required this.donorTotalHeartMass,
    required this.massDifferencePercentage,
    this.recipientBloodType,
    this.donorBloodType,
    this.recipientName,
    this.donorName,
  }) : super(key: key);

  @override
  State<HeartCalculatorResultsScreen> createState() => _HeartCalculatorResultsScreenState();
}

class _HeartCalculatorResultsScreenState extends State<HeartCalculatorResultsScreen> {
  bool _isBloodTypeCompatible() {
    if (widget.recipientBloodType == null || widget.donorBloodType == null) {
      return false;
    }

    // O- can donate to anyone
    if (widget.donorBloodType == 'O-') {
      return true;
    }

    // O+ can donate to any positive blood type
    if (widget.donorBloodType == 'O+') {
      return widget.recipientBloodType!.endsWith('+');
    }

    // A- can donate to A and AB
    if (widget.donorBloodType == 'A-') {
      return widget.recipientBloodType!.startsWith('A') || widget.recipientBloodType!.startsWith('AB');
    }

    // A+ can donate to A+ and AB+
    if (widget.donorBloodType == 'A+') {
      return widget.recipientBloodType == 'A+' || widget.recipientBloodType == 'AB+';
    }

    // B- can donate to B and AB
    if (widget.donorBloodType == 'B-') {
      return widget.recipientBloodType!.startsWith('B') || widget.recipientBloodType!.startsWith('AB');
    }

    // B+ can donate to B+ and AB+
    if (widget.donorBloodType == 'B+') {
      return widget.recipientBloodType == 'B+' || widget.recipientBloodType == 'AB+';
    }

    // AB- can donate to AB
    if (widget.donorBloodType == 'AB-') {
      return widget.recipientBloodType!.startsWith('AB');
    }

    // AB+ can only donate to AB+
    if (widget.donorBloodType == 'AB+') {
      return widget.recipientBloodType == 'AB+';
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Size Calculator Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Recipient Heart Mass',
              children: [
                _buildResultRow('Name', widget.recipientName ?? 'N/A'),
                _buildResultRow('Left Ventricular Mass', '${widget.recipientLeftVentricularMass.toStringAsFixed(2)} g'),
                _buildResultRow('Right Ventricular Mass', '${widget.recipientRightVentricularMass.toStringAsFixed(2)} g'),
                _buildResultRow('Total Heart Mass', '${widget.recipientTotalHeartMass.toStringAsFixed(2)} g'),
                if (widget.recipientBloodType != null)
                  _buildResultRow('Blood Type', widget.recipientBloodType!),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Donor Heart Mass',
              children: [
                _buildResultRow('Name', widget.donorName ?? 'N/A'),
                _buildResultRow('Left Ventricular Mass', '${widget.donorLeftVentricularMass.toStringAsFixed(2)} g'),
                _buildResultRow('Right Ventricular Mass', '${widget.donorRightVentricularMass.toStringAsFixed(2)} g'),
                _buildResultRow('Total Heart Mass', '${widget.donorTotalHeartMass.toStringAsFixed(2)} g'),
                if (widget.donorBloodType != null)
                  _buildResultRow('Blood Type', widget.donorBloodType!),
              ],
            ),
            const SizedBox(height: 24),
            _buildBloodTypeCompatibilitySection(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Mass Difference',
              children: [
                _buildResultRow(
                  'Percentage Difference',
                  '${widget.massDifferencePercentage.toStringAsFixed(2)}%',
                  isHighlighted: true,
                ),
              ],
              isHighlighted: true,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Heart Mass Chart',
              children: [
                Image.asset(
                  'assets/images/heartgraph.png',
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ródenas-Alesina, E., Foroutan, F., Fan, C.-P., Stehlik, J., Bartlett, I., Tremblay-Gravel, M., Aleksova, N., Rao, V., Miller, R. J. H., Khush, K. K., Ross, H. J., & Moayedi, Y. (2023). Predicted heart mass: A tale of 2 Ventricles. Circulation: Heart Failure, 16(9). https://doi.org/10.1161/circheartfailure.120.008311',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeCompatibilitySection() {
    if (widget.recipientBloodType == null || widget.donorBloodType == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.orange),
        ),
        child: const Text(
          'Warning: Blood type information is missing. Please ensure blood type compatibility before proceeding.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final isCompatible = _isBloodTypeCompatible();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isCompatible ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: isCompatible ? Colors.green : Colors.red),
      ),
      child: Row(
        children: [
          Icon(
            isCompatible ? Icons.check_circle : Icons.warning,
            color: isCompatible ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isCompatible
                  ? 'Blood types are compatible: ${widget.donorBloodType} can donate to ${widget.recipientBloodType}'
                  : 'Warning: Blood types are not compatible. ${widget.donorBloodType} cannot donate to ${widget.recipientBloodType}',
              style: TextStyle(
                fontSize: 16,
                color: isCompatible ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    bool isHighlighted = false,
  }) {
    return Card(
      elevation: 0,
      color: isHighlighted ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? Theme.of(context).primaryColor : null,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color: isHighlighted ? Theme.of(context).primaryColor : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 24 : 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
} 
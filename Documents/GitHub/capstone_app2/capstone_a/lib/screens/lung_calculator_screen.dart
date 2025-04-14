import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/person.dart';
import '../services/person_service.dart';
import 'lung_calculator_results_screen.dart';

class LungCalculatorScreen extends StatefulWidget {
  const LungCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<LungCalculatorScreen> createState() => _LungCalculatorScreenState();
}

class _LungCalculatorScreenState extends State<LungCalculatorScreen> {
  final _personService = PersonService();
  final _formKey = GlobalKey<FormState>();
  bool _isRecipientManualEntry = true;
  bool _isDonorManualEntry = true;
  Person? _selectedRecipient;
  Person? _selectedDonor;
  List<Person> _recipients = [];
  List<Person> _donors = [];
  bool _isLoading = false;

  // Form controllers for recipient
  final _recipientHeightController = TextEditingController();
  String? _selectedRecipientGender;
  String? _selectedRecipientBloodType;
  bool _isRecipientHeightCm = true;

  // Form controllers for donor
  final _donorHeightController = TextEditingController();
  String? _selectedDonorGender;
  String? _selectedDonorBloodType;
  bool _isDonorHeightCm = true;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final recipients = await PersonService.getPeople(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        organType: 'lung',
        personType: PersonType.patient,
      );
      final donors = await PersonService.getPeople(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        organType: 'lung',
        personType: PersonType.donor,
      );
      setState(() {
        _recipients = recipients;
        _donors = donors;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading patients: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFieldsFromPatient(Person patient, bool isRecipient) {
    setState(() {
      if (isRecipient) {
        _recipientHeightController.text = patient.height?.toString() ?? '';
        _selectedRecipientGender = patient.gender?.toLowerCase();
        _selectedRecipientBloodType = patient.bloodType;
      } else {
        _donorHeightController.text = patient.height?.toString() ?? '';
        _selectedDonorGender = patient.gender?.toLowerCase();
        _selectedDonorBloodType = patient.bloodType;
      }
    });
  }

  void _clearFields(bool isRecipient) {
    setState(() {
      if (isRecipient) {
        _recipientHeightController.clear();
        _selectedRecipientGender = null;
        _selectedRecipientBloodType = null;
        _selectedRecipient = null;
      } else {
        _donorHeightController.clear();
        _selectedDonorGender = null;
        _selectedDonorBloodType = null;
        _selectedDonor = null;
      }
    });
  }

  @override
  void dispose() {
    _recipientHeightController.dispose();
    _donorHeightController.dispose();
    super.dispose();
  }

  double _calculatePredictedTotalLungCapacity(String gender, double heightInMeters) {
    // Using the formula from the paper
    if (gender.toLowerCase() == 'male') {
      return (7.99 * heightInMeters) - 7.08;
    } else {
      return (6.60 * heightInMeters) - 5.79;
    }
  }

  void _calculateAndShowResults() {
    if (_formKey.currentState?.validate() ?? false) {
      // Convert height to meters
      double recipientHeightInMeters;
      double donorHeightInMeters;
      
      if (_isRecipientHeightCm) {
        recipientHeightInMeters = double.parse(_recipientHeightController.text) / 100;
      } else {
        recipientHeightInMeters = double.parse(_recipientHeightController.text) * 0.0254;
      }
      
      if (_isDonorHeightCm) {
        donorHeightInMeters = double.parse(_donorHeightController.text) / 100;
      } else {
        donorHeightInMeters = double.parse(_donorHeightController.text) * 0.0254;
      }

      final recipientGender = _selectedRecipientGender!;
      final donorGender = _selectedDonorGender!;

      // Calculate predicted total lung capacity
      final recipientTLC = _calculatePredictedTotalLungCapacity(
        recipientGender,
        recipientHeightInMeters,
      );
      final donorTLC = _calculatePredictedTotalLungCapacity(
        donorGender,
        donorHeightInMeters,
      );

      // Calculate pTLC ratio
      final pTLCRatio = donorTLC / recipientTLC;

      // Navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LungCalculatorResultsScreen(
            recipientTLC: recipientTLC,
            donorTLC: donorTLC,
            pTLCRatio: pTLCRatio,
            recipientBloodType: _selectedRecipientBloodType,
            donorBloodType: _selectedDonorBloodType,
            recipientName: _selectedRecipient?.name,
            donorName: _selectedDonor?.name,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lung Size Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientSection(
                title: 'Recipient',
                isManualEntry: _isRecipientManualEntry,
                onToggleEntry: (value) {
                  setState(() {
                    _isRecipientManualEntry = value;
                    _clearFields(true);
                  });
                },
                selectedPatient: _selectedRecipient,
                patients: _recipients,
                onPatientSelected: (patient) {
                  setState(() => _selectedRecipient = patient);
                  if (patient != null) {
                    _populateFieldsFromPatient(patient, true);
                  }
                },
                heightController: _recipientHeightController,
                selectedGender: _selectedRecipientGender,
                selectedBloodType: _selectedRecipientBloodType,
                onGenderChanged: (value) => setState(() => _selectedRecipientGender = value),
                onBloodTypeChanged: (value) => setState(() => _selectedRecipientBloodType = value),
                isHeightCm: _isRecipientHeightCm,
                onHeightUnitChanged: (value) => setState(() => _isRecipientHeightCm = value),
              ),
              const SizedBox(height: 24),
              _buildPatientSection(
                title: 'Donor',
                isManualEntry: _isDonorManualEntry,
                onToggleEntry: (value) {
                  setState(() {
                    _isDonorManualEntry = value;
                    _clearFields(false);
                  });
                },
                selectedPatient: _selectedDonor,
                patients: _donors,
                onPatientSelected: (patient) {
                  setState(() => _selectedDonor = patient);
                  if (patient != null) {
                    _populateFieldsFromPatient(patient, false);
                  }
                },
                heightController: _donorHeightController,
                selectedGender: _selectedDonorGender,
                selectedBloodType: _selectedDonorBloodType,
                onGenderChanged: (value) => setState(() => _selectedDonorGender = value),
                onBloodTypeChanged: (value) => setState(() => _selectedDonorBloodType = value),
                isHeightCm: _isDonorHeightCm,
                onHeightUnitChanged: (value) => setState(() => _isDonorHeightCm = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateAndShowResults,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Calculate'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientSection({
    required String title,
    required bool isManualEntry,
    required ValueChanged<bool> onToggleEntry,
    required Person? selectedPatient,
    required List<Person> patients,
    required ValueChanged<Person?> onPatientSelected,
    required TextEditingController heightController,
    required String? selectedGender,
    required String? selectedBloodType,
    required ValueChanged<String?> onGenderChanged,
    required ValueChanged<String?> onBloodTypeChanged,
    required bool isHeightCm,
    required ValueChanged<bool> onHeightUnitChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    label: 'Manual Entry',
                    isSelected: isManualEntry,
                    onTap: () => onToggleEntry(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildToggleButton(
                    label: 'Select Patient',
                    isSelected: !isManualEntry,
                    onTap: () => onToggleEntry(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isManualEntry) ...[
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<Person>(
                  value: selectedPatient,
                  decoration: InputDecoration(
                    labelText: 'Choose a $title',
                    border: const OutlineInputBorder(),
                  ),
                  items: patients.map((patient) {
                    return DropdownMenuItem(
                      value: patient,
                      child: Text(patient.name),
                    );
                  }).toList(),
                  onChanged: onPatientSelected,
                ),
              const SizedBox(height: 16),
            ],
            Text(
              '$title Information',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender *',
                border: OutlineInputBorder(),
              ),
              items: ['male', 'female'].map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender.capitalize()),
                );
              }).toList(),
              onChanged: onGenderChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select gender';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: heightController,
                    decoration: InputDecoration(
                      labelText: 'Height (${isHeightCm ? 'cm' : 'in'}) *',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter height';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _buildUnitToggle(
                  isSelected: isHeightCm,
                  onChanged: onHeightUnitChanged,
                  unit1: 'cm',
                  unit2: 'in',
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBloodType,
              decoration: const InputDecoration(
                labelText: 'Blood Type',
                border: OutlineInputBorder(),
              ),
              items: _bloodTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: onBloodTypeChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitToggle({
    required bool isSelected,
    required ValueChanged<bool> onChanged,
    required String unit1,
    required String unit2,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => onChanged(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : null,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
              ),
              child: Text(
                unit1,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => onChanged(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: !isSelected ? Theme.of(context).primaryColor : null,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
              ),
              child: Text(
                unit2,
                style: TextStyle(
                  color: !isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/person.dart';
import '../services/person_service.dart';
import 'heart_calculator_results_screen.dart';
import 'dart:math';

class HeartCalculatorScreen extends StatefulWidget {
  const HeartCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<HeartCalculatorScreen> createState() => _HeartCalculatorScreenState();
}

class _HeartCalculatorScreenState extends State<HeartCalculatorScreen> {
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
  final _recipientWeightController = TextEditingController();
  final _recipientAgeController = TextEditingController();
  String? _selectedRecipientGender;
  String? _selectedRecipientBloodType;
  bool _isRecipientWeightKg = true;
  bool _isRecipientHeightCm = true;

  // Form controllers for donor
  final _donorHeightController = TextEditingController();
  final _donorWeightController = TextEditingController();
  final _donorAgeController = TextEditingController();
  String? _selectedDonorGender;
  String? _selectedDonorBloodType;
  bool _isDonorWeightKg = true;
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
        organType: 'heart',
        personType: PersonType.patient,
      );
      final donors = await PersonService.getPeople(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        organType: 'heart',
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
        _recipientWeightController.text = patient.weight?.toString() ?? '';
        _recipientAgeController.text = patient.age?.toString() ?? '';
        _selectedRecipientGender = patient.gender?.toLowerCase();
        _selectedRecipientBloodType = patient.bloodType;
      } else {
        _donorHeightController.text = patient.height?.toString() ?? '';
        _donorWeightController.text = patient.weight?.toString() ?? '';
        _donorAgeController.text = patient.age?.toString() ?? '';
        _selectedDonorGender = patient.gender?.toLowerCase();
        _selectedDonorBloodType = patient.bloodType;
      }
    });
  }

  void _clearFields(bool isRecipient) {
    setState(() {
      if (isRecipient) {
        _recipientHeightController.clear();
        _recipientWeightController.clear();
        _recipientAgeController.clear();
        _selectedRecipientGender = null;
        _selectedRecipientBloodType = null;
        _selectedRecipient = null;
      } else {
        _donorHeightController.clear();
        _donorWeightController.clear();
        _donorAgeController.text = '';
        _selectedDonorGender = null;
        _selectedDonorBloodType = null;
        _selectedDonor = null;
      }
    });
  }

  @override
  void dispose() {
    _recipientHeightController.dispose();
    _recipientWeightController.dispose();
    _recipientAgeController.dispose();
    _donorHeightController.dispose();
    _donorWeightController.dispose();
    _donorAgeController.dispose();
    super.dispose();
  }

  double _calculateLeftVentricularMass(String gender, double heightInMeters, double weightInKg) {
    final a = gender.toLowerCase() == 'female' ? 6.82 : 8.25;
    return a * pow(heightInMeters, 0.54) * pow(weightInKg, 0.61);
  }

  double _calculateRightVentricularMass(String gender, int age, double heightInMeters, double weightInKg) {
    final a = gender.toLowerCase() == 'female' ? 10.59 : 11.25;
    return a * pow(age.toDouble(), -0.32) * pow(heightInMeters, 1.135) * pow(weightInKg, 0.315);
  }

  double _calculateMassDifferencePercentage(double recipientMass, double donorMass) {
    return ((recipientMass - donorMass) / recipientMass) * 100;
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

      // Convert weight to kg
      double recipientWeight;
      double donorWeight;
      
      if (_isRecipientWeightKg) {
        recipientWeight = double.parse(_recipientWeightController.text);
      } else {
        recipientWeight = double.parse(_recipientWeightController.text) * 0.453592;
      }
      
      if (_isDonorWeightKg) {
        donorWeight = double.parse(_donorWeightController.text);
      } else {
        donorWeight = double.parse(_donorWeightController.text) * 0.453592;
      }

      // Get other values
      final recipientAge = int.parse(_recipientAgeController.text);
      final donorAge = int.parse(_donorAgeController.text);
      final recipientGender = _selectedRecipientGender!;
      final donorGender = _selectedDonorGender!;

      // Calculate masses
      final recipientLeftVentricularMass = _calculateLeftVentricularMass(
        recipientGender,
        recipientHeightInMeters,
        recipientWeight,
      );
      final recipientRightVentricularMass = _calculateRightVentricularMass(
        recipientGender,
        recipientAge,
        recipientHeightInMeters,
        recipientWeight,
      );
      final recipientTotalHeartMass = recipientLeftVentricularMass + recipientRightVentricularMass;

      final donorLeftVentricularMass = _calculateLeftVentricularMass(
        donorGender,
        donorHeightInMeters,
        donorWeight,
      );
      final donorRightVentricularMass = _calculateRightVentricularMass(
        donorGender,
        donorAge,
        donorHeightInMeters,
        donorWeight,
      );
      final donorTotalHeartMass = donorLeftVentricularMass + donorRightVentricularMass;

      final massDifferencePercentage = _calculateMassDifferencePercentage(
        recipientTotalHeartMass,
        donorTotalHeartMass,
      );

      // Navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HeartCalculatorResultsScreen(
            recipientLeftVentricularMass: recipientLeftVentricularMass,
            recipientRightVentricularMass: recipientRightVentricularMass,
            recipientTotalHeartMass: recipientTotalHeartMass,
            donorLeftVentricularMass: donorLeftVentricularMass,
            donorRightVentricularMass: donorRightVentricularMass,
            donorTotalHeartMass: donorTotalHeartMass,
            massDifferencePercentage: massDifferencePercentage,
            recipientBloodType: _selectedRecipientBloodType,
            donorBloodType: _selectedDonorBloodType,
            recipientName: _selectedRecipient?.name,
            donorName: _selectedDonor?.name,
          ),
        ),
      );
    }
  }

  Future<void> _showPatientSearchDialog({
    required BuildContext context,
    required List<Person> patients,
    required Person? selectedPatient,
    required ValueChanged<Person?> onPatientSelected,
    required String title,
  }) async {
    final TextEditingController searchController = TextEditingController();
    List<Person> filteredPatients = List.from(patients);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select $title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by name',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredPatients = patients
                            .where((p) => p.name.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: filteredPatients.isEmpty
                        ? const Center(child: Text('No patients found'))
                        : ListView.builder(
                            itemCount: filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              return ListTile(
                                title: Text(patient.name),
                                selected: selectedPatient?.name == patient.name,
                                onTap: () {
                                  onPatientSelected(patient);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Size Calculator'),
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
                weightController: _recipientWeightController,
                ageController: _recipientAgeController,
                selectedGender: _selectedRecipientGender,
                selectedBloodType: _selectedRecipientBloodType,
                onGenderChanged: (value) => setState(() => _selectedRecipientGender = value),
                onBloodTypeChanged: (value) => setState(() => _selectedRecipientBloodType = value),
                isWeightKg: _isRecipientWeightKg,
                isHeightCm: _isRecipientHeightCm,
                onWeightUnitChanged: (value) => setState(() => _isRecipientWeightKg = value),
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
                weightController: _donorWeightController,
                ageController: _donorAgeController,
                selectedGender: _selectedDonorGender,
                selectedBloodType: _selectedDonorBloodType,
                onGenderChanged: (value) => setState(() => _selectedDonorGender = value),
                onBloodTypeChanged: (value) => setState(() => _selectedDonorBloodType = value),
                isWeightKg: _isDonorWeightKg,
                isHeightCm: _isDonorHeightCm,
                onWeightUnitChanged: (value) => setState(() => _isDonorWeightKg = value),
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
    required TextEditingController weightController,
    required TextEditingController ageController,
    required String? selectedGender,
    required String? selectedBloodType,
    required ValueChanged<String?> onGenderChanged,
    required ValueChanged<String?> onBloodTypeChanged,
    required bool isWeightKg,
    required bool isHeightCm,
    required ValueChanged<bool> onWeightUnitChanged,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedPatient?.name ?? 'No $title selected'),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.search, color: Colors.red),
                        label: Text('Search $title', style: const TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _showPatientSearchDialog(
                          context: context,
                          patients: patients,
                          selectedPatient: selectedPatient,
                          onPatientSelected: onPatientSelected,
                          title: title,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight (${isWeightKg ? 'kg' : 'lb'}) *',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter weight';
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
                  isSelected: isWeightKg,
                  onChanged: onWeightUnitChanged,
                  unit1: 'kg',
                  unit2: 'lb',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Age *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter age';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
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
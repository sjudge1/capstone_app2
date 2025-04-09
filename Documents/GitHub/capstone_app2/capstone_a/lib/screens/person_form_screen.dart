import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../services/person_service.dart';

class PersonFormScreen extends StatefulWidget {
  final Person? person;
  final PersonType listType;
  final String organType;
  final String userId;

  const PersonFormScreen({
    Key? key,
    this.person,
    required this.listType,
    required this.organType,
    required this.userId,
  }) : super(key: key);

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personService = PersonService();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;
  bool _isMetric = true;
  bool _isKilograms = true;
  bool _showGenderError = false;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  bool get _isHeart => widget.organType == 'heart';

  // Helper method to show required field indicator
  Widget _requiredFieldIndicator() {
    return const Text(
      ' *',
      style: TextStyle(color: Colors.red),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultUnits();
    if (widget.person != null) {
      _nameController.text = widget.person!.name;
      _ageController.text = widget.person!.age?.toString() ?? '';
      _heightController.text = widget.person!.height?.toString() ?? '';
      _weightController.text = widget.person!.weight?.toString() ?? '';
      _contactNumberController.text = widget.person!.contactNumber ?? '';
      _addressController.text = widget.person!.address ?? '';
      _emailController.text = widget.person!.email ?? '';
      _notesController.text = widget.person!.notes ?? '';
      _selectedGender = widget.person!.gender?.toLowerCase();
      _selectedBloodType = widget.person!.bloodType;
    }
  }

  Future<void> _loadDefaultUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final useMetricUnits = prefs.getBool('useMetricUnits') ?? true;
    setState(() {
      _isMetric = useMetricUnits;
      _isKilograms = useMetricUnits;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _convertHeight(String value) {
    if (value.isEmpty) return null;
    final double? number = double.tryParse(value);
    if (number == null) return null;
    return _isMetric ? number : number * 2.54; // Convert inches to cm
  }

  double? _convertWeight(String value) {
    if (value.isEmpty) return null;
    final double? number = double.tryParse(value);
    if (number == null) return null;
    return _isKilograms ? number : number * 0.453592; // Convert lbs to kg
  }

  String _getHeightUnit() => _isMetric ? 'cm' : 'inches';
  String _getWeightUnit() => _isKilograms ? 'kg' : 'lbs';

  Future<void> _savePerson() async {
    setState(() {
      _showGenderError = _selectedGender == null;
    });

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a gender'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final person = Person.create(
          name: _nameController.text,
          age: int.tryParse(_ageController.text),
          height: _convertHeight(_heightController.text),
          weight: _convertWeight(_weightController.text),
          gender: _selectedGender,
          address: _addressController.text,
          contactNumber: _contactNumberController.text,
          email: _emailController.text,
          bloodType: _selectedBloodType,
          notes: _notesController.text,
          organType: widget.organType,
          type: widget.listType,
          userId: widget.userId,
        );

        if (widget.person != null) {
          await _personService.updatePerson(
            person.copyWith(
              id: widget.person!.id,
              createdAt: widget.person!.createdAt,
              updatedAt: DateTime.now(),
            ),
          );
        } else {
          await _personService.addPerson(person);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.person == null
                    ? '${widget.listType == PersonType.patient ? "Patient" : "Donor"} added successfully'
                    : '${widget.listType == PersonType.patient ? "Patient" : "Donor"} updated successfully',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.person == null
              ? 'Add ${widget.organType} ${widget.listType == PersonType.patient ? "Patient" : "Donor"}'
              : 'Edit ${widget.organType} ${widget.listType == PersonType.patient ? "Patient" : "Donor"}',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Required Fields Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_outline, size: 20, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Required Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Name/ID Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name/ID *',
                        hintText: 'Enter patient name or ID number',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name or ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Gender Selection
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: const Icon(Icons.wc_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        errorText: _showGenderError ? 'Please select a gender' : null,
                      ),
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        underline: const SizedBox(),
                        isExpanded: true,
                        hint: const Text('Select Gender'),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(value: 'female', child: Text('Female')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _showGenderError = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Height Field
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: InputDecoration(
                              labelText: 'Height *',
                              hintText: 'Enter height',
                              prefixIcon: const Icon(Icons.height),
                              suffixText: _getHeightUnit(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Height is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              if (_heightController.text.isNotEmpty) {
                                final currentHeight = double.tryParse(_heightController.text);
                                if (currentHeight != null) {
                                  _heightController.text = (_isMetric
                                      ? currentHeight / 2.54
                                      : currentHeight * 2.54
                                  ).toStringAsFixed(1);
                                }
                              }
                              _isMetric = !_isMetric;
                            });
                          },
                          icon: Icon(_isMetric ? Icons.swap_horiz : Icons.swap_horiz),
                          label: Text(_isMetric ? 'cm' : 'in'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isHeart) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: InputDecoration(
                                labelText: 'Weight *',
                                hintText: 'Enter weight',
                                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                                suffixText: _getWeightUnit(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              validator: (value) {
                                if (_isHeart && (value == null || value.isEmpty)) {
                                  return 'Weight is required for heart patients/donors';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_weightController.text.isNotEmpty) {
                                  final currentWeight = double.tryParse(_weightController.text);
                                  if (currentWeight != null) {
                                    _weightController.text = (_isKilograms
                                        ? currentWeight * 2.20462
                                        : currentWeight / 2.20462
                                    ).toStringAsFixed(1);
                                  }
                                }
                                _isKilograms = !_isKilograms;
                              });
                            },
                            icon: Icon(_isKilograms ? Icons.swap_horiz : Icons.swap_horiz),
                            label: Text(_isKilograms ? 'kg' : 'lb'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: 'Age *',
                          hintText: 'Enter age',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (_isHeart && (value == null || value.isEmpty)) {
                            return 'Age is required for heart patients/donors';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Optional Fields Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_outlined, size: 20, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Additional Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (!_isHeart) ...[
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  decoration: InputDecoration(
                                    labelText: 'Weight',
                                    hintText: 'Enter weight',
                                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                                    suffixText: _getWeightUnit(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (_weightController.text.isNotEmpty) {
                                      final currentWeight = double.tryParse(_weightController.text);
                                      if (currentWeight != null) {
                                        _weightController.text = (_isKilograms
                                            ? currentWeight * 2.20462
                                            : currentWeight / 2.20462
                                        ).toStringAsFixed(1);
                                      }
                                    }
                                    _isKilograms = !_isKilograms;
                                  });
                                },
                                icon: Icon(_isKilograms ? Icons.swap_horiz : Icons.swap_horiz),
                                label: Text(_isKilograms ? 'kg' : 'lb'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ageController,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              hintText: 'Enter age',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Blood Type',
                        prefixIcon: const Icon(Icons.bloodtype_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedBloodType,
                        underline: const SizedBox(),
                        isExpanded: true,
                        hint: const Text('Select Blood Type'),
                        items: _bloodTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBloodType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactNumberController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        hintText: 'Enter contact number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter email address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter address',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Enter any additional notes',
                        prefixIcon: const Icon(Icons.note_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _savePerson,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.person == null ? Icons.add : Icons.save),
                        const SizedBox(width: 8),
                        Text(
                          widget.person == null ? 'Add ${widget.listType.toString().split('.').last}' : 'Save Changes',
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 
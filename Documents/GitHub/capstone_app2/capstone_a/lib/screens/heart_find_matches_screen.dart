import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/person.dart';
import '../services/person_service.dart';
import 'heart_calculator_screen.dart';

class HeartFindMatchesScreen extends StatefulWidget {
  const HeartFindMatchesScreen({Key? key}) : super(key: key);

  @override
  State<HeartFindMatchesScreen> createState() => _HeartFindMatchesScreenState();
}

class _HeartFindMatchesScreenState extends State<HeartFindMatchesScreen> {
  final _personService = PersonService();
  List<Person> _recipients = [];
  List<Person> _donors = [];
  List<Person> _filteredRecipients = [];
  List<Person> _filteredDonors = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedSortBy = 'name';
  bool _sortAscending = true;
  String? _selectedBloodType;
  String? _selectedGender;
  bool _showFilters = false;
  double _minMassDifference = -30.0;
  double _maxMassDifference = 30.0;

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
        _filteredRecipients = recipients;
        _filteredDonors = donors;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipients: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterAndSort() {
    List<Person> filteredRecipients = _recipients;
    List<Person> filteredDonors = _donors;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredRecipients = filteredRecipients.where((person) =>
        person.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (person.bloodType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
      filteredDonors = filteredDonors.where((person) =>
        person.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (person.bloodType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Apply blood type filter
    if (_selectedBloodType != null) {
      filteredRecipients = filteredRecipients.where((person) =>
        person.bloodType == _selectedBloodType
      ).toList();
      filteredDonors = filteredDonors.where((person) =>
        person.bloodType == _selectedBloodType
      ).toList();
    }

    // Apply gender filter
    if (_selectedGender != null) {
      filteredRecipients = filteredRecipients.where((person) =>
        person.gender?.toLowerCase() == _selectedGender?.toLowerCase()
      ).toList();
      filteredDonors = filteredDonors.where((person) =>
        person.gender?.toLowerCase() == _selectedGender?.toLowerCase()
      ).toList();
    }

    // Apply mass difference filter
    filteredRecipients = filteredRecipients.where((recipient) {
      if (recipient.height == null || recipient.weight == null || recipient.gender == null) return false;
      
      final recipientMass = _calculatePredictedHeartMass(
        recipient.gender!,
        recipient.height!,
        recipient.weight!,
      );

      return filteredDonors.any((donor) {
        if (donor.height == null || donor.weight == null || donor.gender == null) return false;
        
        final donorMass = _calculatePredictedHeartMass(
          donor.gender!,
          donor.height!,
          donor.weight!,
        );

        final massDifference = ((donorMass - recipientMass) / recipientMass) * 100;
        return massDifference >= _minMassDifference && massDifference <= _maxMassDifference;
      });
    }).toList();

    filteredDonors = filteredDonors.where((donor) {
      if (donor.height == null || donor.weight == null || donor.gender == null) return false;
      
      final donorMass = _calculatePredictedHeartMass(
        donor.gender!,
        donor.height!,
        donor.weight!,
      );

      return filteredRecipients.any((recipient) {
        if (recipient.height == null || recipient.weight == null || recipient.gender == null) return false;
        
        final recipientMass = _calculatePredictedHeartMass(
          recipient.gender!,
          recipient.height!,
          recipient.weight!,
        );

        final massDifference = ((donorMass - recipientMass) / recipientMass) * 100;
        return massDifference >= _minMassDifference && massDifference <= _maxMassDifference;
      });
    }).toList();

    // Apply sorting
    filteredRecipients.sort((a, b) {
      switch (_selectedSortBy) {
        case 'name':
          return _sortAscending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
        case 'bloodType':
          return _sortAscending
              ? (a.bloodType ?? '').compareTo(b.bloodType ?? '')
              : (b.bloodType ?? '').compareTo(a.bloodType ?? '');
        case 'gender':
          return _sortAscending
              ? (a.gender ?? '').compareTo(b.gender ?? '')
              : (b.gender ?? '').compareTo(a.gender ?? '');
        default:
          return 0;
      }
    });

    filteredDonors.sort((a, b) {
      switch (_selectedSortBy) {
        case 'name':
          return _sortAscending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
        case 'bloodType':
          return _sortAscending
              ? (a.bloodType ?? '').compareTo(b.bloodType ?? '')
              : (b.bloodType ?? '').compareTo(a.bloodType ?? '');
        case 'gender':
          return _sortAscending
              ? (a.gender ?? '').compareTo(b.gender ?? '')
              : (b.gender ?? '').compareTo(a.gender ?? '');
        default:
          return 0;
      }
    });

    setState(() {
      _filteredRecipients = filteredRecipients;
      _filteredDonors = filteredDonors;
    });
  }

  double _calculatePredictedHeartMass(String gender, double height, double weight) {
    // Using the formula from the paper
    if (gender.toLowerCase() == 'male') {
      return 0.33 * weight + 0.36 * height - 0.03 * 25 - 0.03;
    } else {
      return 0.33 * weight + 0.36 * height - 0.03 * 25 - 0.03;
    }
  }

  void _navigateToCalculator(Person recipient, Person donor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeartCalculatorScreen(
          initialRecipient: recipient,
          initialDonor: donor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Heart Matches'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Filter & Sort Settings'),
                  trailing: IconButton(
                    icon: Icon(
                      _showFilters ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() => _showFilters = !_showFilters);
                    },
                  ),
                ),
                if (_showFilters) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                            _filterAndSort();
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedBloodType,
                                decoration: const InputDecoration(
                                  labelText: 'Blood Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Blood Types'),
                                  ),
                                  ..._bloodTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedBloodType = value);
                                  _filterAndSort();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Genders'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'male',
                                    child: Text('Male'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'female',
                                    child: Text('Female'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedGender = value);
                                  _filterAndSort();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedSortBy,
                                decoration: const InputDecoration(
                                  labelText: 'Sort By',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'name',
                                    child: Text('Name'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'bloodType',
                                    child: Text('Blood Type'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'gender',
                                    child: Text('Gender'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedSortBy = value!);
                                  _filterAndSort();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(
                                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              ),
                              onPressed: () {
                                setState(() => _sortAscending = !_sortAscending);
                                _filterAndSort();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _minMassDifference.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Min Mass Difference (%)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final newValue = double.tryParse(value);
                                  if (newValue != null) {
                                    setState(() => _minMassDifference = newValue);
                                    _filterAndSort();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                initialValue: _maxMassDifference.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Max Mass Difference (%)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final newValue = double.tryParse(value);
                                  if (newValue != null) {
                                    setState(() => _maxMassDifference = newValue);
                                    _filterAndSort();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredRecipients.length * _filteredDonors.length,
                    itemBuilder: (context, index) {
                      final recipientIndex = index ~/ _filteredDonors.length;
                      final donorIndex = index % _filteredDonors.length;
                      final recipient = _filteredRecipients[recipientIndex];
                      final donor = _filteredDonors[donorIndex];

                      // Calculate mass difference
                      final recipientMass = _calculatePredictedHeartMass(
                        recipient.gender!,
                        recipient.height!,
                        recipient.weight!,
                      );
                      final donorMass = _calculatePredictedHeartMass(
                        donor.gender!,
                        donor.height!,
                        donor.weight!,
                      );
                      final massDifference = ((donorMass - recipientMass) / recipientMass) * 100;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          title: Text('${recipient.name} ↔ ${donor.name}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recipient: ${recipient.bloodType ?? 'N/A'}'),
                              Text('Donor: ${donor.bloodType ?? 'N/A'}'),
                              Text('Mass Difference: ${massDifference.toStringAsFixed(2)}%'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _navigateToCalculator(recipient, donor),
                            child: const Text('Calculate'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../services/person_service.dart';
import '../widgets/search_filter_bar.dart';
import 'person_form_screen.dart';
import 'matches_screen.dart';

class PatientListScreen extends StatefulWidget {
  final String organType; // 'Lung' or 'Heart'
  final String listType; // 'patient' or 'donor'
  final String userId;

  const PatientListScreen({
    super.key,
    required this.organType,
    required this.listType,
    required this.userId,
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();
  final _personService = PersonService();
  String? _selectedBloodType;
  String? _selectedGender;
  String _selectedSortOption = 'name';
  RangeValues _organSizeRange = const RangeValues(0, 100);
  List<Person> _people = [];
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultSort();
    _loadPeople();
  }

  Future<void> _loadDefaultSort() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSortOption = prefs.getString('defaultSortOption') ?? 'name';
    });
  }

  Future<void> _loadPeople() async {
    try {
      final people = await PersonService.getPeople(
        personType: widget.listType == 'patient' ? PersonType.patient : PersonType.donor,
        userId: widget.userId,
        organType: widget.organType.toLowerCase(),
      );
      setState(() {
        _people = people;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading people: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLung = widget.organType.toLowerCase() == 'lung';
    final double minRange = isLung ? 2.0 : 75.0;
    final double maxRange = isLung ? 10.0 : 500.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.organType} ${widget.listType == 'patient' ? "Patients" : "Donors"}'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            tooltip: _isEditMode ? 'Done' : 'Edit List',
          ),
        ],
      ),
      body: Column(
        children: [
          SearchFilterBar(
            searchController: _searchController,
            selectedBloodType: _selectedBloodType,
            selectedGender: _selectedGender,
            selectedSortOption: _selectedSortOption,
            organSizeRange: _organSizeRange,
            organType: widget.organType,
            onSearchChanged: (value) => setState(() {}),
            onBloodTypeChanged: (value) => setState(() => _selectedBloodType = value),
            onGenderChanged: (value) => setState(() => _selectedGender = value),
            onSortOptionChanged: (value) {
              if (value != null) {
                setState(() => _selectedSortOption = value);
              }
            },
            onOrganSizeRangeChanged: (values) => setState(() => _organSizeRange = values),
          ),
          Expanded(
            child: StreamBuilder<List<Person>>(
              stream: _personService.getPeopleStream(
                widget.listType == 'patient' ? PersonType.patient : PersonType.donor,
                widget.userId,
                widget.organType.toLowerCase(),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Person> people = snapshot.data ?? [];

                // Apply filters
                people = people.where((person) {
                  final matchesSearch = person.name.toLowerCase().contains(_searchController.text.toLowerCase());
                  final matchesBloodType = _selectedBloodType == null || person.bloodType == _selectedBloodType;
                  final matchesGender = _selectedGender == null || person.gender?.toLowerCase() == _selectedGender?.toLowerCase();
                  
                  // Apply organ size range filter
                  bool matchesOrganSize = true;
                  if (_organSizeRange != null) {
                    if (isLung) {
                      final tlc = person.predictedTotalLungCapacity ?? 0;
                      final bool isAtMin = _organSizeRange!.start == minRange;
                      final bool isAtMax = _organSizeRange!.end == maxRange;
                      
                      // When at min, include all values less than or equal to end value
                      // When at max, include all values greater than or equal to start value
                      // Otherwise use exact range
                      matchesOrganSize = (isAtMin ? true : tlc >= _organSizeRange!.start) &&
                                       (isAtMax ? true : tlc <= _organSizeRange!.end);
                    } else {
                      final heartMass = person.predictedTotalHeartMass ?? 0;
                      final bool isAtMin = _organSizeRange!.start == minRange;
                      final bool isAtMax = _organSizeRange!.end == maxRange;
                      
                      // When at min, include all values less than or equal to end value
                      // When at max, include all values greater than or equal to start value
                      // Otherwise use exact range
                      matchesOrganSize = (isAtMin ? true : heartMass >= _organSizeRange!.start) &&
                                       (isAtMax ? true : heartMass <= _organSizeRange!.end);
                    }
                  }

                  return matchesSearch && matchesBloodType && matchesGender && matchesOrganSize;
                }).toList();

                // Apply sorting
                people.sort((a, b) {
                  switch (_selectedSortOption) {
                    case 'name':
                      return _getNameOrId(a).compareTo(_getNameOrId(b));
                    case 'date':
                      return b.createdAt.compareTo(a.createdAt); // Most recent first
                    case 'organ_size':
                      if (isLung) {
                        return (b.predictedTotalLungCapacity ?? 0)
                            .compareTo(a.predictedTotalLungCapacity ?? 0);
                      } else {
                        return (b.predictedTotalHeartMass ?? 0)
                            .compareTo(a.predictedTotalHeartMass ?? 0);
                      }
                    default:
                      return _getNameOrId(a).compareTo(_getNameOrId(b)); // Default to name
                  }
                });

                if (people.isEmpty) {
                  return const Center(
                    child: Text('No matches found'),
                  );
                }

                return ListView.builder(
                  itemCount: people.length,
                  itemBuilder: (context, index) {
                    final person = people[index];
                    return Dismissible(
                      key: Key(person.id ?? ''),
                      direction: _isEditMode ? DismissDirection.endToStart : DismissDirection.none,
                      confirmDismiss: (direction) async {
                        if (!_isEditMode) return false;
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text('Are you sure you want to delete ${person.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ) ?? false;
                      },
                      onDismissed: (direction) async {
                        try {
                          await _personService.deletePerson(person.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${person.name} deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  // Re-add the person
                                  _personService.addPerson(person);
                                },
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting patient: $e')),
                          );
                        }
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            _getDisplayText(person),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: widget.organType.toLowerCase() == 'lung'
                            ? Text(
                                'pTLC: ${person.predictedTotalLungCapacity?.toStringAsFixed(2) ?? 'N/A'} L',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              )
                            : Text(
                                'pHM: ${person.predictedTotalHeartMass?.toStringAsFixed(2) ?? 'N/A'} g',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isEditMode)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: Text('Are you sure you want to delete ${person.name}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirmed == true) {
                                      try {
                                        await _personService.deletePerson(person.id!);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${person.name} deleted'),
                                            action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () {
                                                // Re-add the person
                                                _personService.addPerson(person);
                                              },
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error deleting patient: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              TextButton.icon(
                                icon: const Icon(Icons.visibility),
                                label: const Text('View Details'),
                                onPressed: () {
                                  _showPersonDetails(person);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonFormScreen(
                listType: widget.listType == 'patient' ? PersonType.patient : PersonType.donor,
                organType: widget.organType.toLowerCase(),
                userId: widget.userId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPersonDetails(Person person) {
    final String patientType = '${widget.organType.substring(0, 1).toUpperCase()}${widget.organType.substring(1)} ${widget.listType == 'patient' ? 'Recipient' : 'Donor'}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(person.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Patient Type
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: widget.organType.toLowerCase() == 'lung' ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.organType.toLowerCase() == 'lung' ? Colors.blue.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.listType == 'patient' ? Icons.person_outline : Icons.volunteer_activism,
                      color: widget.organType.toLowerCase() == 'lung' ? Colors.blue : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      patientType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.organType.toLowerCase() == 'lung' ? Colors.blue : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Medical Information Section
              Text(
                'Medical Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.organType.toLowerCase() == 'lung' && person.predictedTotalLungCapacity != null)
                _buildDetailRow('Predicted TLC', '${person.predictedTotalLungCapacity!.toStringAsFixed(2)} L')
              else if (widget.organType.toLowerCase() == 'heart' && person.predictedTotalHeartMass != null)
                _buildDetailRow('Predicted Heart Mass', '${person.predictedTotalHeartMass!.toStringAsFixed(2)} g'),
              _buildDetailRow('Age', person.age?.toString() ?? 'N/A'),
              _buildDetailRow('Height', '${person.height} cm'),
              _buildDetailRow('Weight', '${person.weight} kg'),
              _buildDetailRow('Gender', person.gender),
              _buildDetailRow('Blood Type', person.bloodType),
              const SizedBox(height: 16),
              
              // Contact Information Section
              Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Phone', person.contactNumber ?? 'N/A'),
              _buildDetailRow('Email', person.email ?? 'N/A'),
              _buildDetailRow('Address', person.address ?? 'N/A'),
              const SizedBox(height: 16),
              
              // Notes Section
              if (person.notes?.isNotEmpty ?? false) ...[
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    person.notes ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.people_outline),
            label: const Text('Find Matches'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchesScreen(
                    person: person,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonFormScreen(
                    person: person,
                    listType: widget.listType == 'patient' ? PersonType.patient : PersonType.donor,
                    organType: widget.organType.toLowerCase(),
                    userId: widget.userId,
                  ),
                ),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  String _getDisplayText(Person person) {
    if (person.name.contains(RegExp(r'^\d'))) {
      return 'Patient ID: ${person.name}';
    }
    return person.name;
  }

  String _getNameOrId(Person person) {
    if (person.name.contains(RegExp(r'^\d'))) {
      return person.name.padLeft(10, '0');
    }
    return person.name;
  }
} 
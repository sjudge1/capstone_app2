import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/person_service.dart';
import '../widgets/search_filter_bar.dart';
import 'person_form_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBloodType;
  String? _selectedGender;
  String? _selectedSortOption = 'name_asc';
  RangeValues? _organSizeRange;
  final PersonService _personService = PersonService();
  bool _isEditMode = false;

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
            onSortOptionChanged: (value) => setState(() => _selectedSortOption = value),
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
                  switch (_selectedSortOption ?? 'name_asc') {
                    case 'name_asc':
                      return _getNameOrId(a).compareTo(_getNameOrId(b));
                    case 'name_desc':
                      return _getNameOrId(b).compareTo(_getNameOrId(a));
                    case 'date_desc':
                      return b.createdAt.compareTo(a.createdAt);
                    case 'date_asc':
                      return a.createdAt.compareTo(b.createdAt);
                    case 'organ_size_asc':
                      if (isLung) {
                        return (a.predictedTotalLungCapacity ?? 0)
                            .compareTo(b.predictedTotalLungCapacity ?? 0);
                      } else {
                        return (a.predictedTotalHeartMass ?? 0)
                            .compareTo(b.predictedTotalHeartMass ?? 0);
                      }
                    case 'organ_size_desc':
                      if (isLung) {
                        return (b.predictedTotalLungCapacity ?? 0)
                            .compareTo(a.predictedTotalLungCapacity ?? 0);
                      } else {
                        return (b.predictedTotalHeartMass ?? 0)
                            .compareTo(a.predictedTotalHeartMass ?? 0);
                      }
                    default:
                      return 0;
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
                listType: PersonType.patient,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(person.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.organType.toLowerCase() == 'lung' && person.predictedTotalLungCapacity != null)
                _buildDetailRow('Predicted TLC', '${person.predictedTotalLungCapacity!.toStringAsFixed(2)} L')
              else if (widget.organType.toLowerCase() == 'heart' && person.predictedTotalHeartMass != null)
                _buildDetailRow('Predicted Heart Mass', '${person.predictedTotalHeartMass!.toStringAsFixed(2)} g'),
              _buildDetailRow('Age', '${person.age}'),
              _buildDetailRow('Height', '${person.height} cm'),
              _buildDetailRow('Weight', '${person.weight} kg'),
              _buildDetailRow('Gender', person.gender),
              _buildDetailRow('Blood Type', person.bloodType),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonFormScreen(
                    person: person,
                    listType: PersonType.patient,
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
            width: 180,
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
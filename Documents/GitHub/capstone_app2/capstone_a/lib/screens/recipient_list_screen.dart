import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../services/person_service.dart';
import '../widgets/search_filter_bar.dart';
import 'person_form_screen.dart';
import 'matches_screen.dart';

class RecipientListScreen extends StatefulWidget {
  final String organType; // 'Lung' or 'Heart'
  final String listType; // 'patient' or 'donor'
  final String userId;

  const RecipientListScreen({
    super.key,
    required this.organType,
    required this.listType,
    required this.userId,
  });

  @override
  State<RecipientListScreen> createState() => _RecipientListScreenState();
}

class _RecipientListScreenState extends State<RecipientListScreen> {
  final _searchController = TextEditingController();
  final _personService = PersonService();
  String? _selectedBloodType;
  String? _selectedGender;
  String _selectedSortOption = 'name';
  RangeValues _organSizeRange = const RangeValues(0, 100);
  List<Person> _recipients = [];
  List<Person> _filteredRecipients = [];
  bool _isEditMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultSort();
    _loadRecipients();
  }

  Future<void> _loadDefaultSort() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSortOption = prefs.getString('defaultSortOption') ?? 'name';
    });
  }

  Future<void> _loadRecipients() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final people = await PersonService.getPeople(
        personType: widget.listType == 'patient' ? PersonType.recipient : PersonType.donor,
        userId: widget.userId,
        organType: widget.organType.toLowerCase(),
      );
      setState(() {
        _recipients = people;
        _filteredRecipients = people;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recipients: ${e.toString()}')),
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
        title: Text('${widget.organType} ${widget.listType == 'patient' ? "Recipients" : "Donors"}'),
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonFormScreen(
                    isEditing: false,
                    personType: PersonType.recipient,
                  ),
                ),
              );
              if (result == true) {
                _loadRecipients();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                  child: _filteredRecipients.isEmpty
                      ? Center(
                          child: Text(
                            'No ${widget.organType.toLowerCase()} recipients found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredRecipients.length,
                          itemBuilder: (context, index) {
                            final recipient = _filteredRecipients[index];
                            return Dismissible(
                              key: Key(recipient.id ?? ''),
                              direction: _isEditMode ? DismissDirection.endToStart : DismissDirection.none,
                              confirmDismiss: (direction) async {
                                if (!_isEditMode) return false;
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: Text('Are you sure you want to delete ${recipient.name}?'),
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
                                  await _personService.deletePerson(recipient.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${recipient.name} deleted'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          // Re-add the person
                                          _personService.addPerson(recipient);
                                        },
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error deleting recipient: $e')),
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
                                    _getDisplayText(recipient),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: widget.organType.toLowerCase() == 'lung'
                                    ? Text(
                                        'pTLC: ${recipient.predictedTotalLungCapacity?.toStringAsFixed(2) ?? 'N/A'} L',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      )
                                    : Text(
                                        'pHM: ${recipient.predictedTotalHeartMass?.toStringAsFixed(2) ?? 'N/A'} g',
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
                                                content: Text('Are you sure you want to delete ${recipient.name}?'),
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
                                                await _personService.deletePerson(recipient.id!);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${recipient.name} deleted'),
                                                    action: SnackBarAction(
                                                      label: 'Undo',
                                                      onPressed: () {
                                                        // Re-add the person
                                                        _personService.addPerson(recipient);
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
                                          _showPersonDetails(recipient);
                                        },
                                      ),
                                    ],
                                  ),
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

  void _showPersonDetails(Person person) {
    final recipientType = '${widget.organType} ${widget.listType == 'patient' ? 'Recipient' : 'Donor'}';
    final isLung = widget.organType.toLowerCase() == 'lung';
    final color = isLung ? Colors.blue : Colors.red;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              widget.listType == 'patient' ? Icons.person : Icons.volunteer_activism,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(person.name),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.listType == 'patient' ? Icons.person : Icons.volunteer_activism,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      recipientType,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Medical Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Blood Type', person.bloodType),
              _buildDetailRow('Gender', person.gender),
              _buildDetailRow('Age', person.age?.toString()),
              _buildDetailRow('Height', '${person.height} cm'),
              _buildDetailRow('Weight', '${person.weight} kg'),
              if (isLung)
                _buildDetailRow('Predicted Total Lung Capacity',
                    '${person.predictedTotalLungCapacity?.toStringAsFixed(2) ?? 'N/A'} L')
              else
                _buildDetailRow('Predicted Heart Mass',
                    '${person.predictedTotalHeartMass?.toStringAsFixed(2) ?? 'N/A'} g'),
              const SizedBox(height: 16),
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Phone', person.contactNumber),
              _buildDetailRow('Email', person.email),
              if (person.notes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(person.notes ?? ''),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonFormScreen(
                    person: person,
                    personType: widget.listType == 'patient'
                        ? PersonType.recipient
                        : PersonType.donor,
                    organType: widget.organType,
                  ),
                ),
              );
              if (result == true) {
                Navigator.pop(context);
                _loadRecipients();
              }
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
    final recipientInfo = [person.name];
    
    if (person.gender != null) {
      recipientInfo.add(person.gender!);
    }
    if (person.age != null) {
      recipientInfo.add('${person.age} years');
    }
    if (person.bloodType != null) {
      recipientInfo.add('Blood: ${person.bloodType}');
    }
    
    return recipientInfo.join(' • ');
  }

  String _getNameOrId(Person person) {
    if (person.name.contains(RegExp(r'^\d'))) {
      return person.name.padLeft(10, '0');
    }
    return person.name;
  }
} 
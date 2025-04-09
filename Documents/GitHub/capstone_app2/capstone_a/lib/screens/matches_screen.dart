import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../services/person_service.dart';

class MatchesScreen extends StatefulWidget {
  final Person person;
  final String userId;

  const MatchesScreen({
    Key? key,
    required this.person,
    required this.userId,
  }) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final _personService = PersonService();
  List<Person> _matches = [];
  bool _isLoading = true;
  RangeValues _heartMassDiffRange = const RangeValues(-20, 50);
  RangeValues _pTLCRatioRange = const RangeValues(0.75, 1.5);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _heartMassDiffRange = RangeValues(
        prefs.getDouble('heartMassDiffMin') ?? -20,
        prefs.getDouble('heartMassDiffMax') ?? 50,
      );
      _pTLCRatioRange = RangeValues(
        prefs.getDouble('pTLCRatioMin') ?? 0.75,
        prefs.getDouble('pTLCRatioMax') ?? 1.5,
      );
    });
    _findMatches();
  }

  bool _isBloodTypeCompatible(String? donorType, String? recipientType) {
    if (donorType == null || recipientType == null) return true;

    final Map<String, List<String>> compatibility = {
      'O-': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
      'O+': ['O+', 'A+', 'B+', 'AB+'],
      'A-': ['A-', 'A+', 'AB-', 'AB+'],
      'A+': ['A+', 'AB+'],
      'B-': ['B-', 'B+', 'AB-', 'AB+'],
      'B+': ['B+', 'AB+'],
      'AB-': ['AB-', 'AB+'],
      'AB+': ['AB+'],
    };

    return compatibility[donorType]?.contains(recipientType) ?? false;
  }

  String _getBloodTypeStatus(Person person1, Person person2) {
    if (person1.bloodType == null && person2.bloodType == null) {
      return 'Both patient and donor blood types unknown';
    } else if (person1.bloodType == null) {
      return widget.person.type == PersonType.patient 
          ? 'Patient blood type unknown'
          : 'Donor blood type unknown';
    } else if (person2.bloodType == null) {
      return widget.person.type == PersonType.patient 
          ? 'Donor blood type unknown'
          : 'Patient blood type unknown';
    }
    return '';
  }

  double _calculateRatio(Person person1, Person person2) {
    if (widget.person.organType == 'lung') {
      final donor = widget.person.type == PersonType.donor ? person1 : person2;
      final recipient = widget.person.type == PersonType.patient ? person1 : person2;
      
      if (donor.predictedTotalLungCapacity == null || recipient.predictedTotalLungCapacity == null) {
        return double.infinity;
      }
      
      return donor.predictedTotalLungCapacity! / recipient.predictedTotalLungCapacity!;
    } else {
      final donor = widget.person.type == PersonType.donor ? person1 : person2;
      final recipient = widget.person.type == PersonType.patient ? person1 : person2;
      
      if (donor.predictedTotalHeartMass == null || recipient.predictedTotalHeartMass == null) {
        return double.infinity;
      }
      
      return ((recipient.predictedTotalHeartMass! - donor.predictedTotalHeartMass!) / 
              recipient.predictedTotalHeartMass!) * 100;
    }
  }

  Future<void> _findMatches() async {
    setState(() => _isLoading = true);

    try {
      // Get potential matches (opposite type from current person)
      final matches = await PersonService.getPeople(
        userId: widget.userId,
        organType: widget.person.organType,
        personType: widget.person.type == PersonType.patient ? PersonType.donor : PersonType.patient,
      );

      // Filter and sort matches
      _matches = matches.where((match) {
        final ratio = _calculateRatio(widget.person, match);
        
        if (ratio == double.infinity) return false;

        if (widget.person.organType == 'lung') {
          return ratio >= _pTLCRatioRange.start && ratio <= _pTLCRatioRange.end;
        } else {
          return ratio >= _heartMassDiffRange.start && ratio <= _heartMassDiffRange.end;
        }
      }).toList();

      // Sort by closest to ideal ratio (1.0 for lung, 0% for heart)
      _matches.sort((a, b) {
        final ratioA = _calculateRatio(widget.person, a);
        final ratioB = _calculateRatio(widget.person, b);
        
        if (widget.person.organType == 'lung') {
          return (ratioA - 1.0).abs().compareTo((ratioB - 1.0).abs());
        } else {
          return ratioA.abs().compareTo(ratioB.abs());
        }
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding matches: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches for ${widget.person.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _matches.isEmpty
                ? Center(
                    child: Text(
                      'No matches found within the current ${widget.person.organType == 'lung' ? 'pTLC ratio' : 'heart mass difference'} range',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: _matches.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      final ratio = _calculateRatio(widget.person, match);
                      final bloodTypeStatus = _getBloodTypeStatus(widget.person, match);
                      final isBloodTypeCompatible = widget.person.type == PersonType.patient
                          ? _isBloodTypeCompatible(match.bloodType, widget.person.bloodType)
                          : _isBloodTypeCompatible(widget.person.bloodType, match.bloodType);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      match.name,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ),
                                  if (bloodTypeStatus.isEmpty && !isBloodTypeCompatible)
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (widget.person.organType == 'lung')
                                Text(
                                  'pTLC Ratio: ${ratio.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                )
                              else
                                Text(
                                  'Heart Mass Difference: ${ratio.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (bloodTypeStatus.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        bloodTypeStatus,
                                        style: const TextStyle(color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                )
                              else if (!isBloodTypeCompatible)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                                      SizedBox(width: 4),
                                      Text(
                                        'Blood types not compatible',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (match.bloodType != null)
                                        Text('Blood Type: ${match.bloodType}'),
                                      if (widget.person.organType == 'lung')
                                        Text('pTLC: ${match.predictedTotalLungCapacity?.toStringAsFixed(2)} L')
                                      else
                                        Text('pHM: ${match.predictedTotalHeartMass?.toStringAsFixed(2)} g'),
                                    ],
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View Details'),
                                    onPressed: () {
                                      // TODO: Show match details dialog
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Reference Graph and Citation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.person.organType == 'lung') ...[
                  Text(
                    'Lung Relative Risk Chart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/lunggraph.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Citation: Eberlein, M., & Reed, R. M. (2016). Donor to recipient sizing in thoracic organ transplantation. World journal of transplantation, 6(1), 155–164. https://doi.org/10.5500/wjt.v6.i1.155',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ] else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/heartgraph.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Citation: Ródenas-Alesina, E., Foroutan, F., Fan, C.-P., Stehlik, J., Bartlett, I., Tremblay-Gravel, M., Aleksova, N., Rao, V., Miller, R. J. H., Khush, K. K., Ross, H. J., & Moayedi, Y. (2023). Predicted heart mass: A tale of 2 Ventricles. Circulation: Heart Failure, 16(9). https://doi.org/10.1161/circheartfailure.120.008311',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
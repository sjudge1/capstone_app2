import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Default values
  RangeValues _heartMassDiffRange = const RangeValues(-20, 50);
  RangeValues _pTLCRatioRange = const RangeValues(0.75, 1.5);
  String _defaultSortOption = 'name';
  String _selectedUnits = 'metric';

  final List<Map<String, String>> _sortOptions = [
    {'value': 'name', 'label': 'Name'},
    {'value': 'date', 'label': 'Date Added'},
    {'value': 'organ_size', 'label': 'Organ Size'},
  ];

  final List<Map<String, String>> _unitOptions = [
    {'value': 'metric', 'label': 'Metric (cm, kg)'},
    {'value': 'imperial', 'label': 'Imperial (in, lb)'},
  ];

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
      _defaultSortOption = prefs.getString('defaultSortOption') ?? 'name';
      _selectedUnits = prefs.getString('selectedUnits') ?? 'metric';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('heartMassDiffMin', _heartMassDiffRange.start);
    await prefs.setDouble('heartMassDiffMax', _heartMassDiffRange.end);
    await prefs.setDouble('pTLCRatioMin', _pTLCRatioRange.start);
    await prefs.setDouble('pTLCRatioMax', _pTLCRatioRange.end);
    await prefs.setString('defaultSortOption', _defaultSortOption);
    await prefs.setString('selectedUnits', _selectedUnits);
    await prefs.setBool('useMetricUnits', _selectedUnits == 'metric');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Default Sort Order',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _defaultSortOption,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option['value'],
                        child: Text(option['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _defaultSortOption = value;
                        });
                        _saveSettings();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Default Units',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedUnits,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _unitOptions.map((option) {
                      return DropdownMenuItem(
                        value: option['value']!,
                        child: Text(option['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUnits = value;
                        });
                        _saveSettings();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lung Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'pTLC Ratio Range',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _pTLCRatioRange.start.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Expanded(
                        child: RangeSlider(
                          values: _pTLCRatioRange,
                          min: 0.5,
                          max: 2.0,
                          divisions: 150,
                          labels: RangeLabels(
                            _pTLCRatioRange.start.toStringAsFixed(2),
                            _pTLCRatioRange.end.toStringAsFixed(2),
                          ),
                          onChanged: (values) {
                            setState(() {
                              _pTLCRatioRange = values;
                            });
                            _saveSettings();
                          },
                        ),
                      ),
                      Text(
                        _pTLCRatioRange.end.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Lung Graph
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
                  // Lung Citation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Citation: Eberlein, M., & Reed, R. M. (2016). Donor to recipient sizing in thoracic organ transplantation. World journal of transplantation, 6(1), 155–164. https://doi.org/10.5500/wjt.v6.i1.155',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heart Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Predicted Heart Mass Difference (%) Range',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${_heartMassDiffRange.start.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Expanded(
                        child: RangeSlider(
                          values: _heartMassDiffRange,
                          min: -50,
                          max: 100,
                          divisions: 150,
                          labels: RangeLabels(
                            '${_heartMassDiffRange.start.toStringAsFixed(1)}%',
                            '${_heartMassDiffRange.end.toStringAsFixed(1)}%',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _heartMassDiffRange = values;
                            });
                            _saveSettings();
                          },
                        ),
                      ),
                      Text(
                        '${_heartMassDiffRange.end.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Heart Graph
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/heartgraph.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Heart Citation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Citation: Ródenas-Alesina, E., Foroutan, F., Fan, C.-P., Stehlik, J., Bartlett, I., Tremblay-Gravel, M., Aleksova, N., Rao, V., Miller, R. J. H., Khush, K. K., Ross, H. J., & Moayedi, Y. (2023). Predicted heart mass: A tale of 2 Ventricles. Circulation: Heart Failure, 16(9). https://doi.org/10.1161/circheartfailure.120.008311',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
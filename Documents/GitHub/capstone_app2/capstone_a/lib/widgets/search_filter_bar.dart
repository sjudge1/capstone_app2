import 'package:flutter/material.dart';
import '../models/person.dart';

class SearchFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final String? selectedBloodType;
  final String? selectedGender;
  final String? selectedSortOption;
  final RangeValues? organSizeRange;
  final String organType;
  final Function(String?) onBloodTypeChanged;
  final Function(String?) onGenderChanged;
  final Function(String?) onSortOptionChanged;
  final Function(String) onSearchChanged;
  final Function(RangeValues) onOrganSizeRangeChanged;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    this.selectedBloodType,
    this.selectedGender,
    this.selectedSortOption,
    this.organSizeRange,
    required this.organType,
    required this.onBloodTypeChanged,
    required this.onGenderChanged,
    required this.onSortOptionChanged,
    required this.onSearchChanged,
    required this.onOrganSizeRangeChanged,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  bool _showFilters = false;
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _initializeRange();
  }

  @override
  void didUpdateWidget(SearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeRange();
  }

  void _initializeRange() {
    final bool isLung = widget.organType.toLowerCase() == 'lung';
    final double minRange = isLung ? 2.0 : 75.0;
    final double maxRange = isLung ? 10.0 : 500.0;
    
    if (widget.organSizeRange != null) {
      // Ensure the values are within bounds
      _currentRange = RangeValues(
        widget.organSizeRange!.start.clamp(minRange, maxRange),
        widget.organSizeRange!.end.clamp(minRange, maxRange)
      );
    } else {
      _currentRange = RangeValues(minRange, maxRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLung = widget.organType.toLowerCase() == 'lung';
    final double minRange = isLung ? 2.0 : 75.0;
    final double maxRange = isLung ? 10.0 : 500.0;
    final String unit = isLung ? 'L' : 'g';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar and filter toggle button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _showFilters ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: IconButton.filled(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: const Icon(Icons.filter_list),
                  tooltip: _showFilters ? 'Hide filters' : 'Show filters',
                ),
              ),
            ],
          ),
          // Animated filter section
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Sort Options - Moved above filters and styled differently
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sort, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Sort list by:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: widget.selectedSortOption,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem<String>(
                                value: 'name',
                                child: Text('Name'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'date',
                                child: Text('Date Added'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'organ_size_high',
                                child: Text('Organ Size (High to Low)'),
                              ),
                              const DropdownMenuItem<String>(
                                value: 'organ_size_low',
                                child: Text('Organ Size (Low to High)'),
                              ),
                            ],
                            onChanged: widget.onSortOptionChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter section header
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Filter by:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Organ Size Range Filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organ Size Range (${isLung ? 'Lung Capacity' : 'Heart Mass'})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${minRange.toStringAsFixed(1)}$unit'),
                        Expanded(
                          child: RangeSlider(
                            values: _currentRange,
                            min: minRange,
                            max: maxRange,
                            divisions: isLung ? 80 : 425,
                            labels: RangeLabels(
                              _currentRange.start == minRange 
                                  ? 'All'
                                  : '${_currentRange.start.toStringAsFixed(1)}$unit',
                              _currentRange.end == maxRange 
                                  ? '${maxRange.toStringAsFixed(1)}+$unit'
                                  : '${_currentRange.end.toStringAsFixed(1)}$unit',
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _currentRange = values;
                              });
                              widget.onOrganSizeRangeChanged(values);
                            },
                          ),
                        ),
                        Text('${maxRange.toStringAsFixed(1)}+$unit'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Blood Type and Gender Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Blood Type Filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: widget.selectedBloodType,
                          hint: const Text('Blood Type'),
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Blood Types'),
                            ),
                            ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                                .map((type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                          ],
                          onChanged: widget.onBloodTypeChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Gender Filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: widget.selectedGender,
                          hint: const Text('Gender'),
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Genders'),
                            ),
                            ...['Male', 'Female']
                                .map((gender) => DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    ))
                                .toList(),
                          ],
                          onChanged: widget.onGenderChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import '../models/person.dart';

class SearchFilterBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool isLung = organType.toLowerCase() == 'lung';
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
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: onSearchChanged,
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
                      values: organSizeRange ?? RangeValues(minRange, maxRange),
                      min: minRange,
                      max: maxRange,
                      divisions: isLung ? 80 : 425, // For more precise control
                      labels: RangeLabels(
                        organSizeRange?.start == minRange 
                            ? 'All'
                            : '${organSizeRange?.start.toStringAsFixed(1) ?? minRange.toStringAsFixed(1)}$unit',
                        organSizeRange?.end == maxRange 
                            ? '${maxRange.toStringAsFixed(1)}+$unit'
                            : '${organSizeRange?.end.toStringAsFixed(1) ?? maxRange.toStringAsFixed(1)}$unit',
                      ),
                      onChanged: onOrganSizeRangeChanged,
                    ),
                  ),
                  Text('${maxRange.toStringAsFixed(1)}+$unit'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filters row
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
                    value: selectedBloodType,
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
                    onChanged: onBloodTypeChanged,
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
                    value: selectedGender,
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
                    onChanged: onGenderChanged,
                  ),
                ),
                const SizedBox(width: 8),
                // Sort Options
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedSortOption,
                    hint: const Text('Sort By'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Default'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'name_asc',
                        child: Text('Name (A-Z)'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'name_desc',
                        child: Text('Name (Z-A)'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'date_desc',
                        child: Text('Most Recent'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'date_asc',
                        child: Text('Oldest'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'organ_size_asc',
                        child: Text('Organ Size (Smallest)'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'organ_size_desc',
                        child: Text('Organ Size (Largest)'),
                      ),
                    ],
                    onChanged: onSortOptionChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
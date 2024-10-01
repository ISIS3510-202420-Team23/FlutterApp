import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class FilterModal extends StatefulWidget {
  final double? initialPrice;
  final double? initialMinutes;
  final DateTimeRange? initialDateRange;
  final Function(double price, double minutes, DateTimeRange? dateRange) onApply;

  const FilterModal({
    super.key,
    this.initialPrice,
    this.initialMinutes,
    this.initialDateRange,
    required this.onApply,
  });

  @override
  FilterModalState createState() => FilterModalState();
}

class FilterModalState extends State<FilterModal> {
  double selectedPrice = 10000000; // Initial price value
  double selectedMinutes = 30; // Initial minutes value
  DateTimeRange? selectedDateRange; // Variable to store selected date range
  bool showDateFields = false; // To track whether to show the date fields
  bool showPriceSlider = false; // Track if price slider should show
  bool showMinutesSlider = false; // Track if minutes slider should show

  @override
  void initState() {
    super.initState();
    // Initialize filter values with the passed-in initial values
    selectedPrice = widget.initialPrice ?? selectedPrice;
    selectedMinutes = widget.initialMinutes ?? selectedMinutes;
    selectedDateRange = widget.initialDateRange;
  }

  // Method to show date picker for 'From' and 'To' dates
  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(), // From today onwards
      lastDate: DateTime(2030), // Set to future limit
      initialDateRange: selectedDateRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  // Method to apply the filters
  void _applyFilters() {
    widget.onApply(selectedPrice, selectedMinutes, selectedDateRange);
    Navigator.pop(context); // Close the modal after applying filters
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row with 'Close' and 'Apply' buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF0C356A)),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                },
              ),
              ElevatedButton(
                onPressed: _applyFilters, // Call apply filters method
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C356A), // Set blue background color
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Add some padding for better appearance
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: Colors.white, // Set white text color
                    fontWeight: FontWeight.w600, // Make the text bold
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Date Selection Row (Add dates)
          GestureDetector(
            onTap: () {
              setState(() {
                showDateFields = !showDateFields;
              });
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('When?',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C356A))),
                Text('Add dates',
                    style: TextStyle(
                        color: Color(0xFF0C356A), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Divider(),
          if (showDateFields)
            Column(
              children: [
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('From',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Monserrat',
                              fontWeight: FontWeight.w500)),
                      Text(
                        selectedDateRange != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)
                            : 'Select date',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('To',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Monserrat',
                              fontWeight: FontWeight.w500)),
                      Text(
                        selectedDateRange != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)
                            : 'Select date',
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          // Slideable Price Field
          GestureDetector(
            onTap: () {
              setState(() {
                showPriceSlider = !showPriceSlider;
              });
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C356A))),
                Text('Select price'),
              ],
            ),
          ),
          if (showPriceSlider)
            Column(
              children: [
                Slider(
                  value: selectedPrice,
                  min: 0,
                  max: 10000000,
                  divisions: 100,
                  activeColor: const Color(0xFF0C356A),
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value;
                    });
                  },
                ),
                Text('\$${selectedPrice.toInt()}'),
              ],
            ),
          // Slideable Minutes from Campus Field
          const Divider(),
          // Slideable Minutes from Campus Field
          GestureDetector(
            onTap: () {
              setState(() {
                showMinutesSlider = !showMinutesSlider;
              });
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Minutes from campus',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C356A))),
                Text('Select minutes'),
              ],
            ),
          ),
          const Divider(),
          if (showMinutesSlider)
            Column(
              children: [
                Slider(
                  value: selectedMinutes,
                  min: 0,
                  max: 60,
                  divisions: 60,
                  activeColor: const Color(0xFF0C356A),
                  onChanged: (value) {
                    setState(() {
                      selectedMinutes = value;
                    });
                  },
                ),
                Text('${selectedMinutes.toInt()} mins'),
                const Divider(),
              ],
            ),
        ],
      ),
    );
  }
}

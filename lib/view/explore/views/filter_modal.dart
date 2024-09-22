import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF0C356A), // Set blue color
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0C356A), // Blue color for selected range
              onPrimary: Colors.white, // Text color on selected days
              surface: Color(0xFFC5DDFF), // Light blue selection color
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary, // Style for buttons
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          // Show From/To Fields with Date Picker if Add Dates is clicked
          if (showDateFields)
            Column(
              children: [
                GestureDetector(
                  onTap: _pickDateRange, // Pick date when clicked
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
                            ? DateFormat('dd/MM/yyyy')
                                .format(selectedDateRange!.start)
                            : 'Select date',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDateRange, // Pick date when clicked
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
                            ? DateFormat('dd/MM/yyyy')
                                .format(selectedDateRange!.end)
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
          const Divider(),
          if (showPriceSlider)
            Column(
              children: [
                Slider(
                  value: selectedPrice,
                  min: 0,
                  max: 10000000,
                  divisions: 100,
                  activeColor: const Color(0xFF0C356A), // Blue color
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value;
                    });
                  },
                ),
                Text('\$${selectedPrice.toInt().toString()}'),
                const Divider(),
              ],
            ),
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
                  activeColor: const Color(0xFF0C356A), // Blue color
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

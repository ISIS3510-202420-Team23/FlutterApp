import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:flutter_screenutil/flutter_screenutil.dart'; // For responsive design

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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h), // Responsive padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjusts based on content
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
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), // Add some responsive padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r), // Rounded corners
                  ),
                ),
                child: Text(
                  'Apply',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15.sp, // Responsive font size
                    color: Colors.white, // Set white text color
                    fontWeight: FontWeight.w600, // Make the text bold
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h), // Responsive spacing
          // Date Selection Row (Add dates)
          GestureDetector(
            onTap: () {
              setState(() {
                showDateFields = !showDateFields;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('When?',
                    style: TextStyle(
                        fontSize: 25.sp, // Responsive font size
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0C356A))),
                Text('Add dates',
                    style: TextStyle(
                        color: const Color(0xFF0C356A), fontWeight: FontWeight.w500, fontSize: 14.sp)), // Responsive font size
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
                      Text('From',
                          style: TextStyle(
                              fontSize: 18.sp, // Responsive font size
                              fontFamily: 'Monserrat',
                              fontWeight: FontWeight.w500)),
                      Text(
                        selectedDateRange != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)
                            : 'Select date',
                        style: TextStyle(fontSize: 14.sp), // Responsive font size
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h), // Responsive spacing
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('To',
                          style: TextStyle(
                              fontSize: 18.sp, // Responsive font size
                              fontFamily: 'Monserrat',
                              fontWeight: FontWeight.w500)),
                      Text(
                        selectedDateRange != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)
                            : 'Select date',
                        style: TextStyle(fontSize: 14.sp), // Responsive font size
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price',
                    style: TextStyle(
                        fontSize: 25.sp, // Responsive font size
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0C356A))),
                Text('Select price', style: TextStyle(fontSize: 14.sp)), // Responsive font size
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
                Text('\$${selectedPrice.toInt()}', style: TextStyle(fontSize: 16.sp)), // Responsive font size
              ],
            ),
          const Divider(),
          // Slideable Minutes from Campus Field
          GestureDetector(
            onTap: () {
              setState(() {
                showMinutesSlider = !showMinutesSlider;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Minutes from campus',
                    style: TextStyle(
                        fontSize: 25.sp, // Responsive font size
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0C356A))),
                Text('Select minutes', style: TextStyle(fontSize: 14.sp)), // Responsive font size
              ],
            ),
          ),
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
                Text('${selectedMinutes.toInt()} mins', style: TextStyle(fontSize: 16.sp)), // Responsive font size
                const Divider(),
              ],
            ),
        ],
      ),
    );
  }
}

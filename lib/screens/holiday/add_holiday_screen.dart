import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../localization/app_localizations.dart';
import '../../theme/adaptive_colors.dart';

class AddHolidayScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onHolidayAdded;

  const AddHolidayScreen({
    super.key,
    this.onHolidayAdded,
  });

  @override
  State<AddHolidayScreen> createState() => _AddHolidayScreenState();
}

class _AddHolidayScreenState extends State<AddHolidayScreen> {
  // Controllers for text fields
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameFrController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Selected values
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false; // Renamed from _isRecurringYearly
  String _holidayType = 'Public'; // Public or Company
  int _count = 1; // Add count field (default to 1)

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _formIsValid = false;

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameFrController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Both English and French names are required
      _formIsValid = _nameEnController.text.isNotEmpty && _nameFrController.text.isNotEmpty;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitHoliday() {
    if (!_formIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).getString('pleaseFillRequiredFields')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create holiday data with both English and French names
    final Map<String, dynamic> holidayData = {
      'name': {
        'en': _nameEnController.text,
        'fr': _nameFrController.text,
      },
      'description': _descriptionController.text,
      'date': _selectedDate,
      'count': _count,
      'recurring': _isRecurring,
      'type': _holidayType,
    };

    // Debug info
    print('Submitting holid ay with recurring: $_isRecurring');

    // Call callback if exists
    if (widget.onHolidayAdded != null) {
      widget.onHolidayAdded!(holidayData);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).getString('holidayAddedSuccessfully')),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);
    final baseFontSize = screenHeight * 0.018;

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AdaptiveColors.primaryTextColor(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          localizations.getString('addHoliday'),
          style: TextStyle(
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: baseFontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Form(
            key: _formKey,
            onChanged: _validateForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // English Holiday Name
                        Text(
                          'Holiday Name (English) *',
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _nameEnController,
                          decoration: InputDecoration(
                            hintText: 'Enter holiday name in English',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.green.shade800),
                            ),
                            filled: true,
                            fillColor: AdaptiveColors.cardColor(context),
                            contentPadding: EdgeInsets.all(screenWidth * 0.03),
                          ),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'English holiday name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // French Holiday Name
                        Text(
                          'Nom du jour férié (Français) *',
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _nameFrController,
                          decoration: InputDecoration(
                            hintText: 'Entrez le nom du jour férié en français',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.green.shade800),
                            ),
                            filled: true,
                            fillColor: AdaptiveColors.cardColor(context),
                            contentPadding: EdgeInsets.all(screenWidth * 0.03),
                          ),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le nom du jour férié en français est requis';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Holiday Description
                        Text(
                          localizations.getString('description'),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: localizations.getString('enterDescription'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.green.shade800),
                            ),
                            filled: true,
                            fillColor: AdaptiveColors.cardColor(context),
                            contentPadding: EdgeInsets.all(screenWidth * 0.03),
                          ),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Holiday Date
                        Text(
                          '${localizations.getString('holidayDate')} *',
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: AdaptiveColors.cardColor(context),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                                  style: TextStyle(
                                    fontSize: baseFontSize,
                                    color: AdaptiveColors.primaryTextColor(context),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.green.shade800,
                                  size: baseFontSize * 1.2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Number of days (count)
                        Text(
                          'Number of days',
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: AdaptiveColors.cardColor(context),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _count,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.green.shade800,
                              ),
                              isExpanded: true,
                              dropdownColor: AdaptiveColors.cardColor(context),
                              items: [1, 2, 3, 4, 5, 6, 7].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(
                                      fontSize: baseFontSize,
                                      color: AdaptiveColors.primaryTextColor(context),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _count = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Holiday Type
                        Text(
                          localizations.getString('holidayType'),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: AdaptiveColors.cardColor(context),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _holidayType,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.green.shade800,
                              ),
                              isExpanded: true,
                              dropdownColor: AdaptiveColors.cardColor(context),
                              items: ['Public', 'Company'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: baseFontSize,
                                      color: AdaptiveColors.primaryTextColor(context),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _holidayType = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Recurring Yearly Option (renamed from _isRecurringYearly to _isRecurring)
                        Row(
                          children: [
                            Checkbox(
                              value: _isRecurring,
                              activeColor: Colors.green.shade800,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isRecurring = value ?? false;
                                });
                                print('Recurring checkbox changed to: $_isRecurring');
                              },
                            ),
                            Text(
                              localizations.getString('recurringYearly'),
                              style: TextStyle(
                                fontSize: baseFontSize,
                                color: AdaptiveColors.primaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          localizations.getString('cancel'),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      ElevatedButton(
                        onPressed: _submitHoliday,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          localizations.getString('addHoliday'),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
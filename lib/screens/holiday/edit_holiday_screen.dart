// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../models/holiday_model.dart';
// import '../../services/holiday_service.dart';
// import '../../theme/adaptive_colors.dart';
// import '../../localization/app_localizations.dart';
// import '../../provider/language_provider.dart';
//
// class EditHolidayScreen extends StatefulWidget {
//   final HolidayModel holiday;
//   final Function() onHolidayEdited;
//
//   const EditHolidayScreen({
//     super.key,
//     required this.holiday,
//     required this.onHolidayEdited,
//   });
//
//   @override
//   State<EditHolidayScreen> createState() => _EditHolidayScreenState();
// }
//
// class _EditHolidayScreenState extends State<EditHolidayScreen> {
//   // Controllers for text fields
//   late TextEditingController _nameEnController;
//   late TextEditingController _nameFrController;
//   late TextEditingController _descriptionController;
//
//   // Selected values
//   late DateTime _selectedDate;
//   late bool _isRecurringYearly;
//   late String _holidayType;
//   late int _holidayCount;
//
//   // Form validation
//   final _formKey = GlobalKey<FormState>();
//   bool _formIsValid = false;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize controllers with existing holiday data
//     _nameEnController = TextEditingController(text: widget.holiday.label['en']);
//     _nameFrController = TextEditingController(text: widget.holiday.label['fr']);
//     _descriptionController = TextEditingController(text: widget.holiday.description ?? '');
//
//     // Initialize selected values
//     _selectedDate = DateTime(
//       DateTime.now().year,
//       widget.holiday.month,
//       widget.holiday.day,
//     );
//     _isRecurringYearly = true; // Always true for this implementation
//     _holidayType = widget.holiday.type ?? 'Public';
//     _holidayCount = widget.holiday.count ?? 1;
//
//     // Initial validation
//     _validateForm();
//   }
//
//   @override
//   void dispose() {
//     _nameEnController.dispose();
//     _nameFrController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   void _validateForm() {
//     setState(() {
//       _formIsValid = _nameEnController.text.isNotEmpty &&
//           _nameFrController.text.isNotEmpty;
//     });
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(DateTime.now().year - 1),
//       lastDate: DateTime(DateTime.now().year + 5),
//     );
//
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   void _updateHoliday() async {
//     if (!_formIsValid) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppLocalizations.of(context).getString('pleaseFillRequiredFields')),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Create holiday data
//       final Map<String, dynamic> holidayData = {
//         'id': widget.holiday.id,
//         'label': {
//           'en': _nameEnController.text,
//           'fr': _nameFrController.text,
//         },
//         'description': _descriptionController.text,
//         'month': _selectedDate.month,
//         'day': _selectedDate.day,
//         'type': _holidayType,
//         'count': _holidayCount,
//       };
//
//       // Call service to update holiday
//       final holidayService = HolidayService();
//       final success = await holidayService.updateHoliday(widget.holiday.id, holidayData);
//
//       // if (success) {
//       //   // Show success message
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     SnackBar(
//       //       content: Text(AppLocalizations.of(context).getString('holidayUpdatedSuccessfully')),
//       //       backgroundColor: Colors.green,
//       //     ),
//       //   );
//       //
//       //   // Call the callback
//       //   widget.onHolidayEdited();
//       //
//       //   // Navigate back
//       //   Navigator.pop(context);
//       // } else {
//       //   // Show error message
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     const SnackBar(
//       //       content: Text('Failed to update holiday. Please try again.'),
//       //       backgroundColor: Colors.red,
//       //     ),
//       //   );
//       // }
//     } catch (e) {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final screenWidth = screenSize.width;
//     final screenHeight = screenSize.height;
//     final localizations = AppLocalizations.of(context);
//     final baseFontSize = screenHeight * 0.018;
//
//     return Scaffold(
//       backgroundColor: AdaptiveColors.backgroundColor(context),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: AdaptiveColors.primaryTextColor(context)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           localizations.getString('editHoliday'),
//           style: TextStyle(
//             color: AdaptiveColors.primaryTextColor(context),
//             fontSize: baseFontSize * 1.2,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(screenWidth * 0.04),
//           child: Form(
//             key: _formKey,
//             onChanged: _validateForm,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // English Holiday Name
//                         Text(
//                           '${localizations.getString('holidayName')} (English) *',
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             fontWeight: FontWeight.w500,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.01),
//                         TextFormField(
//                           controller: _nameEnController,
//                           decoration: InputDecoration(
//                             hintText: localizations.getString('enterHolidayName'),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.green.shade800),
//                             ),
//                             filled: true,
//                             fillColor: AdaptiveColors.cardColor(context),
//                             contentPadding: EdgeInsets.all(screenWidth * 0.03),
//                           ),
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return localizations.getString('holidayNameRequired');
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//
//                         // French Holiday Name
//                         Text(
//                           '${localizations.getString('holidayName')} (Français) *',
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             fontWeight: FontWeight.w500,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.01),
//                         TextFormField(
//                           controller: _nameFrController,
//                           decoration: InputDecoration(
//                             hintText: "Entrez le nom du jour férié",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.green.shade800),
//                             ),
//                             filled: true,
//                             fillColor: AdaptiveColors.cardColor(context),
//                             contentPadding: EdgeInsets.all(screenWidth * 0.03),
//                           ),
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return "Le nom du jour férié est requis";
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//
//                         // Holiday Description
//                         Text(
//                           localizations.getString('description'),
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             fontWeight: FontWeight.w500,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.01),
//                         TextFormField(
//                           controller: _descriptionController,
//                           decoration: InputDecoration(
//                             hintText: localizations.getString('enterDescription'),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.green.shade800),
//                             ),
//                             filled: true,
//                             fillColor: AdaptiveColors.cardColor(context),
//                             contentPadding: EdgeInsets.all(screenWidth * 0.03),
//                           ),
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                           maxLines: 3,
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//
//                         // Holiday Date
//                         Text(
//                           '${localizations.getString('holidayDate')} *',
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             fontWeight: FontWeight.w500,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.01),
//                         InkWell(
//                           onTap: () => _selectDate(context),
//                           child: Container(
//                             padding: EdgeInsets.all(screenWidth * 0.03),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey.shade300),
//                               borderRadius: BorderRadius.circular(8),
//                               color: AdaptiveColors.cardColor(context),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   DateFormat('MMMM d').format(_selectedDate),
//                                   style: TextStyle(
//                                     fontSize: baseFontSize,
//                                     color: AdaptiveColors.primaryTextColor(context),
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.calendar_today,
//                                   color: Colors.green.shade800,
//                                   size: baseFontSize * 1.2,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//
//                         // Holiday Type
//                         Text(
//                           localizations.getString('holidayType'),
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             fontWeight: FontWeight.w500,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.01),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: screenWidth * 0.03,
//                             vertical: screenWidth * 0.01,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(8),
//                             color: AdaptiveColors.cardColor(context),
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               value: _holidayType,
//                               icon: Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Colors.green.shade800,
//                               ),
//                               isExpanded: true,
//                               dropdownColor: AdaptiveColors.cardColor(context),
//                               items: ['Public', 'Company'].map((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(
//                                     value,
//                                     style: TextStyle(
//                                       fontSize: baseFontSize,
//                                       color: AdaptiveColors.primaryTextColor(context),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (String? newValue) {
//                                 if (newValue != null) {
//                                   setState(() {
//                                     _holidayType = newValue;
//                                   });
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//
//                         // Number of days
//                         Text(
//                           localizations.getString('days'),
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             fontWeight: FontWeight.w500,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.01),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: screenWidth * 0.03,
//                             vertical: screenWidth * 0.01,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(8),
//                             color: AdaptiveColors.cardColor(context),
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<int>(
//                               value: _holidayCount,
//                               icon: Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Colors.green.shade800,
//                               ),
//                               isExpanded: true,
//                               dropdownColor: AdaptiveColors.cardColor(context),
//                               items: [1, 2, 3, 4, 5, 6, 7].map((int value) {
//                                 return DropdownMenuItem<int>(
//                                   value: value,
//                                   child: Text(
//                                     value.toString(),
//                                     style: TextStyle(
//                                       fontSize: baseFontSize,
//                                       color: AdaptiveColors.primaryTextColor(context),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (int? newValue) {
//                                 if (newValue != null) {
//                                   setState(() {
//                                     _holidayCount = newValue;
//                                   });
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//
//                         // Recurring Yearly Option
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: _isRecurringYearly,
//                               activeColor: Colors.green.shade800,
//                               onChanged: (bool? value) {
//                                 // We don't actually let them change this - it's always recurring
//                                 // But we show it for clarity
//                               },
//                             ),
//                             Text(
//                               localizations.getString('recurringYearly'),
//                               style: TextStyle(
//                                 fontSize: baseFontSize,
//                                 color: AdaptiveColors.primaryTextColor(context),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Action Buttons
//                 Container(
//                   padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       OutlinedButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(color: Colors.grey.shade300),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: screenWidth * 0.04,
//                             vertical: screenHeight * 0.015,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           localizations.getString('cancel'),
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             color: AdaptiveColors.primaryTextColor(context),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: screenWidth * 0.02),
//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _updateHoliday,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green.shade800,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: screenWidth * 0.04,
//                             vertical: screenHeight * 0.015,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? SizedBox(
//                           width: screenHeight * 0.02,
//                           height: screenHeight * 0.02,
//                           child: const CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                             : Text(
//                           localizations.getString('update'),
//                           style: TextStyle(
//                             fontSize: baseFontSize,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
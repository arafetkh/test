// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../models/holiday_model.dart';
// import '../../services/holiday_service.dart';
// import '../../theme/adaptive_colors.dart';
// import '../../localization/app_localizations.dart';
// import '../../provider/language_provider.dart';
// import 'edit_holiday_screen.dart';
//
// class HolidayDetailDialog extends StatelessWidget {
//   final HolidayModel holiday;
//   final int selectedYear;
//   final Function() onDeleted;
//   final Function() onEdited;
//
//   const HolidayDetailDialog({
//     super.key,
//     required this.holiday,
//     required this.selectedYear,
//     required this.onDeleted,
//     required this.onEdited,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final screenWidth = screenSize.width;
//     final screenHeight = screenSize.height;
//     final localizations = AppLocalizations.of(context);
//
//     // Get the appropriate label based on the app's language
//     final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
//     final currentLanguage = languageProvider.currentLanguage;
//     final holidayName = currentLanguage == 'fr'
//         ? holiday.label['fr']
//         : holiday.label['en'];
//
//     final holidayDate = DateTime(
//       selectedYear,
//       holiday.month,
//       holiday.day,
//     );
//
//     final isToday = DateTime.now().year == holidayDate.year &&
//         DateTime.now().month == holidayDate.month &&
//         DateTime.now().day == holidayDate.day;
//
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(screenWidth * 0.03),
//       ),
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       child: Container(
//         width: screenWidth * 0.9,
//         padding: EdgeInsets.all(screenWidth * 0.05),
//         decoration: BoxDecoration(
//           color: AdaptiveColors.cardColor(context),
//           borderRadius: BorderRadius.circular(screenWidth * 0.03),
//           boxShadow: [
//             BoxShadow(
//               color: AdaptiveColors.shadowColor(context),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with title and close button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     holidayName!,
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.05,
//                       fontWeight: FontWeight.bold,
//                       color: AdaptiveColors.primaryTextColor(context),
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     Icons.close,
//                     color: AdaptiveColors.secondaryTextColor(context),
//                     size: screenWidth * 0.05,
//                   ),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: screenHeight * 0.02),
//
//             // Date information
//             Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   size: screenWidth * 0.05,
//                   color: AdaptiveColors.primaryGreen,
//                 ),
//                 SizedBox(width: screenWidth * 0.02),
//                 Text(
//                   DateFormat('MMMM d, yyyy').format(holidayDate),
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.04,
//                     color: AdaptiveColors.primaryTextColor(context),
//                   ),
//                 ),
//                 if (isToday) ...[
//                   SizedBox(width: screenWidth * 0.02),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.02,
//                       vertical: screenHeight * 0.005,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade800.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(screenWidth * 0.01),
//                     ),
//                     child: Text(
//                       localizations.getString('today'),
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.03,
//                         color: Colors.green.shade800,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//
//             SizedBox(height: screenHeight * 0.015),
//
//             // Type and recurring badges
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.02,
//                     vertical: screenHeight * 0.005,
//                   ),
//                   decoration: BoxDecoration(
//                     color: holiday.type == 'Public'
//                         ? Colors.blue.shade100
//                         : Colors.orange.shade100,
//                     borderRadius: BorderRadius.circular(screenWidth * 0.01),
//                   ),
//                   child: Text(
//                     holiday.type ?? 'Public',
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.03,
//                       color: holiday.type == 'Public'
//                           ? Colors.blue.shade800
//                           : Colors.orange.shade800,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.02),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.02,
//                     vertical: screenHeight * 0.005,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.purple.shade100,
//                     borderRadius: BorderRadius.circular(screenWidth * 0.01),
//                   ),
//                   child: Text(
//                     localizations.getString('recurring'),
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.03,
//                       color: Colors.purple.shade800,
//                     ),
//                   ),
//                 ),
//
//                 // Display the count of days if > 1
//                 if (holiday.count != null && holiday.count! > 1) ...[
//                   SizedBox(width: screenWidth * 0.02),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.02,
//                       vertical: screenHeight * 0.005,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade100,
//                       borderRadius: BorderRadius.circular(screenWidth * 0.01),
//                     ),
//                     child: Text(
//                       '${holiday.count} ${localizations.getString('days')}',
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.03,
//                         color: Colors.green.shade800,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//
//             SizedBox(height: screenHeight * 0.025),
//
//             // Description if available
//             if (holiday.description != null && holiday.description!.isNotEmpty) ...[
//               Text(
//                 localizations.getString('description'),
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.04,
//                   fontWeight: FontWeight.bold,
//                   color: AdaptiveColors.primaryTextColor(context),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.01),
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(screenWidth * 0.03),
//                 decoration: BoxDecoration(
//                   color: AdaptiveColors.isDarkMode(context)
//                       ? Colors.grey.shade800.withOpacity(0.3)
//                       : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                 ),
//                 child: Text(
//                   holiday.description!,
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.035,
//                     color: AdaptiveColors.secondaryTextColor(context),
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.025),
//             ],
//
//             // Information box based on holiday type
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(screenWidth * 0.03),
//               decoration: BoxDecoration(
//                 color: holiday.type == 'Public'
//                     ? Colors.blue.shade50.withOpacity(AdaptiveColors.isDarkMode(context) ? 0.1 : 1)
//                     : Colors.orange.shade50.withOpacity(AdaptiveColors.isDarkMode(context) ? 0.1 : 1),
//                 borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                 border: Border.all(
//                   color: holiday.type == 'Public'
//                       ? Colors.blue.shade200
//                       : Colors.orange.shade200,
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     size: screenWidth * 0.06,
//                     color: holiday.type == 'Public'
//                         ? Colors.blue.shade800
//                         : Colors.orange.shade800,
//                   ),
//                   SizedBox(width: screenWidth * 0.03),
//                   Expanded(
//                     child: Text(
//                       holiday.type == 'Public'
//                           ? localizations.getString('publicHolidayInfo')
//                           : localizations.getString('companyHolidayInfo'),
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.035,
//                         color: holiday.type == 'Public'
//                             ? Colors.blue.shade800
//                             : Colors.orange.shade800,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: screenHeight * 0.03),
//
//             // Action buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 // Edit button
//                 TextButton.icon(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => EditHolidayScreen(
//                           holiday: holiday,
//                           onHolidayEdited: onEdited,
//                         ),
//                       ),
//                     );
//                   },
//                   icon: Icon(
//                     Icons.edit_outlined,
//                     size: screenWidth * 0.045,
//                     color: Colors.green.shade800,
//                   ),
//                   label: Text(
//                     localizations.getString('edit'),
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.035,
//                       color: Colors.green.shade800,
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(width: screenWidth * 0.03),
//
//                 // Delete button
//                 TextButton.icon(
//                   onPressed: () {
//                     _showDeleteConfirmationDialog(context);
//                   },
//                   icon: Icon(
//                     Icons.delete_outline,
//                     size: screenWidth * 0.045,
//                     color: Colors.red,
//                   ),
//                   label: Text(
//                     localizations.getString('delete'),
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.035,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteConfirmationDialog(BuildContext context) {
//     final localizations = AppLocalizations.of(context);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(localizations.getString('confirmDelete')),
//           content: Text(localizations.getString('deleteHolidayConfirmation')),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 localizations.getString('cancel'),
//                 style: TextStyle(color: AdaptiveColors.secondaryTextColor(context)),
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close confirmation dialog
//
//                 // Show loading indicator
//                 showDialog(
//                   context: context,
//                   barrierDismissible: false,
//                   builder: (BuildContext context) {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   },
//                 );
//
//                 // Call the delete API
//                 final holidayService = HolidayService();
//                 final success = await holidayService.deleteHoliday(holiday.id);
//
//                 // Close loading indicator
//                 Navigator.of(context).pop();
//
//                 // if (success) {
//                 //   // Show success message
//                 //   ScaffoldMessenger.of(context).showSnackBar(
//                 //     SnackBar(
//                 //       content: Text(localizations.getString('holidayDeletedSuccessfully')),
//                 //       backgroundColor: Colors.green,
//                 //     ),
//                 //   );
//                 //
//                 //   // Close the detail dialog and notify parent
//                 //   Navigator.of(context).pop();
//                 //   onDeleted();
//                 // } else {
//                 //   // Show error message
//                 //   ScaffoldMessenger.of(context).showSnackBar(
//                 //     const SnackBar(
//                 //       content: Text('Failed to delete holiday. Please try again.'),
//                 //       backgroundColor: Colors.red,
//                 //     ),
//                 //   );
//                 // }
//               },
//               child: Text(
//                 localizations.getString('delete'),
//                 style: const TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
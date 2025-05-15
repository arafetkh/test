// import 'dart:async';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:in_out/ai/camera_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:in_out/ai/remote_pointing_service.dart';
// import 'package:in_out/localization/app_localizations.dart';
// import 'package:in_out/models/recognition_result.dart';
// import 'package:in_out/services/navigation_service.dart';
// import 'package:in_out/theme/adaptive_colors.dart';
// import 'package:in_out/widget/responsive_navigation_scaffold.dart';
// import 'package:in_out/widget/user_profile_header.dart';
// import 'package:in_out/widget/bottom_navigation_bar.dart';
// import 'package:intl/intl.dart';
//
// import 'face_registration_screen.dart';
//
// class RemotePointageScreen extends StatefulWidget {
//   const RemotePointageScreen({super.key});
//
//   @override
//   State<RemotePointageScreen> createState() => _RemotePointageScreenState();
// }
//
// class _RemotePointageScreenState extends State<RemotePointageScreen> with WidgetsBindingObserver {
//   int _selectedIndex = 2; // Assuming 2 is the index for attendance in your app
//   bool _isHeaderVisible = true;
//   final ScrollController _scrollController = ScrollController();
//
//   // Camera service
//   final CameraService _cameraService = CameraService();
//   late CameraController _cameraController;
//   bool _isCameraInitialized = false;
//   bool _isFaceDetected = false;
//   bool _isProcessing = false;
//
//   // Time tracking states
//   bool _isCheckedIn = false;
//   String _lastCheckTime = "";
//   String _checkType = "in"; // "in" or "out"
//
//   // Current time
//   DateTime _currentTime = DateTime.now();
//   late Timer _timer;
//
//   // Captured image
//   Uint8List? _capturedImage;
//
//   // Service instance
//   final RemotePointageService _pointageService = RemotePointageService();
//
//   // Recognition result
//   String _recognitionMessage = "";
//   String? _recognizedUserName;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _scrollController.addListener(_scrollListener);
//
//     // Set preferred orientation to portrait
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//
//     // Initialize timer to update current time
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _currentTime = DateTime.now();
//       });
//     });
//
//     // Initialize camera
//     _initializeCamera();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // App state changed before we got the chance to initialize the camera
//     if (_cameraController == null || !_cameraController.value.isInitialized) {
//       return;
//     }
//
//     if (state == AppLifecycleState.inactive) {
//       _cameraController.dispose();
//     } else if (state == AppLifecycleState.resumed) {
//       _initializeCamera();
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     _timer.cancel();
//     if (_cameraController != null && _cameraController.value.isInitialized) {
//       _cameraController.dispose();
//     }
//     super.dispose();
//   }
//
//   void _scrollListener() {
//     setState(() {
//       _isHeaderVisible = _scrollController.offset <= 0;
//     });
//   }
//
//   Future<void> _initializeCamera() async {
//     try {
//       _cameras = await availableCameras();
//       if (_cameras == null || _cameras!.isEmpty) {
//         setState(() {
//           _recognitionMessage = "No cameras available";
//         });
//         return;
//       }
//
//       // Use front camera if available
//       final frontCamera = _cameras!.firstWhere(
//             (camera) => camera.lensDirection == CameraLensDirection.front,
//         orElse: () => _cameras!.first,
//       );
//
//       _cameraController = CameraController(
//         frontCamera,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//
//       await _cameraController.initialize();
//
//       if (mounted) {
//         setState(() {
//           _isCameraInitialized = true;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _recognitionMessage = "Error initializing camera: $e";
//       });
//     }
//   }
//
//   void _onItemTapped(int index) {
//     if (index == _selectedIndex) return;
//
//     setState(() {
//       _selectedIndex = index;
//     });
//
//     NavigationService.navigateToScreen(context, index);
//   }
//
//   void _captureFace() async {
//     if (!_isCameraInitialized || _isProcessing) return;
//
//     setState(() {
//       _isProcessing = true;
//       _recognitionMessage = "Scanning face...";
//       _isFaceDetected = false;
//     });
//
//     try {
//       // Capture image from camera
//       final Uint8List? bytes = await _cameraService.captureImage();
//
//       if (bytes == null) {
//         setState(() {
//           _isProcessing = false;
//           _recognitionMessage = "Failed to capture image";
//         });
//         return;
//       }
//
//       setState(() {
//         _capturedImage = bytes;
//       });
//
//       // Send to recognition service
//       final result = await _pointageService.recognizeFace(bytes);
//
//       setState(() {
//         _isFaceDetected = result.recognized;
//         _recognitionMessage = result.message;
//         _recognizedUserName = result.userName;
//         _isProcessing = false;
//       });
//
//       if (result.recognized) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Face recognized: ${result.userName}"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Face not recognized: ${result.message}"),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//         _recognitionMessage = "Error: $e";
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error capturing image: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _performCheckInOut() async {
//     if (!_isFaceDetected || _isProcessing || _capturedImage == null) return;
//
//     setState(() {
//       _isProcessing = true;
//     });
//
//     try {
//       // Record attendance
//       final result = await _pointageService.recordAttendance(
//           _capturedImage!,
//           !_isCheckedIn // true for check-in, false for check-out
//       );
//
//       if (result['success']) {
//         setState(() {
//           _isCheckedIn = !_isCheckedIn;
//           _lastCheckTime = DateFormat('HH:mm:ss').format(_currentTime);
//           _checkType = _isCheckedIn ? "in" : "out";
//           _isProcessing = false;
//
//           // Reset face detection state for next scan
//           _isFaceDetected = false;
//           _capturedImage = null;
//         });
//
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message']),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       } else {
//         setState(() {
//           _isProcessing = false;
//           _recognitionMessage = result['message'];
//         });
//
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message']),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//         _recognitionMessage = "Error: $e";
//       });
//
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error recording attendance: $e"),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   void _navigateToRegistration() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const FaceRegistrationScreen(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final screenWidth = screenSize.width;
//     final screenHeight = screenSize.height;
//     final localizations = AppLocalizations.of(context);
//
//     // Format current time
//     final formattedTime = DateFormat('HH:mm:ss').format(_currentTime);
//     final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(_currentTime);
//
//     return ResponsiveNavigationScaffold(
//       selectedIndex: _selectedIndex,
//       onItemTapped: _onItemTapped,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             UserProfileHeader(
//               isHeaderVisible: _isHeaderVisible,
//             ),
//
//             // Main content
//             Expanded(
//               child: SingleChildScrollView(
//                 controller: _scrollController,
//                 child: Padding(
//                   padding: EdgeInsets.all(screenWidth * 0.04),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Title
//                       Text(
//                         "Remote Attendance",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.06,
//                           fontWeight: FontWeight.bold,
//                           color: AdaptiveColors.primaryTextColor(context),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.01),
//
//                       // Current Date and Time
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.04,
//                           vertical: screenHeight * 0.01,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AdaptiveColors.cardColor(context),
//                           borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AdaptiveColors.shadowColor(context),
//                               blurRadius: 3,
//                               offset: const Offset(0, 1),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             Text(
//                               formattedTime,
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.08,
//                                 fontWeight: FontWeight.bold,
//                                 color: AdaptiveColors.primaryGreen,
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.005),
//                             Text(
//                               formattedDate,
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.04,
//                                 color: AdaptiveColors.secondaryTextColor(context),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.02),
//
//                       // Status indicator
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.04,
//                           vertical: screenHeight * 0.01,
//                         ),
//                         decoration: BoxDecoration(
//                           color: _isCheckedIn ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                           border: Border.all(
//                             color: _isCheckedIn ? Colors.green : Colors.orange,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               _isCheckedIn ? Icons.check_circle : Icons.info_outline,
//                               color: _isCheckedIn ? Colors.green : Colors.orange,
//                             ),
//                             SizedBox(width: screenWidth * 0.02),
//                             Text(
//                               _isCheckedIn
//                                   ? "Checked in at $_lastCheckTime"
//                                   : _lastCheckTime.isEmpty
//                                   ? "Not checked in"
//                                   : "Checked out at $_lastCheckTime",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.04,
//                                 fontWeight: FontWeight.bold,
//                                 color: _isCheckedIn ? Colors.green : Colors.orange,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.02),
//
//                       // Camera preview
//                       Container(
//                         width: screenWidth * 0.8,
//                         height: screenWidth * 0.8,
//                         decoration: BoxDecoration(
//                           color: Colors.black87,
//                           borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                           border: Border.all(
//                             color: _isFaceDetected
//                                 ? Colors.green
//                                 : AdaptiveColors.borderColor(context),
//                             width: _isFaceDetected ? 3 : 1,
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                           child: _isCameraInitialized
//                               ? Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               // Camera preview
//                               CameraPreview(_cameraController),
//
//                               // Display captured image if available
//                               if (_capturedImage != null)
//                                 Image.memory(
//                                   _capturedImage!,
//                                   width: screenWidth * 0.8,
//                                   height: screenWidth * 0.8,
//                                   fit: BoxFit.cover,
//                                 ),
//
//                               // Face overlay
//                               _isFaceDetected
//                                   ? Icon(
//                                 Icons.face,
//                                 size: screenWidth * 0.4,
//                                 color: Colors.green.withOpacity(0.5),
//                               )
//                                   : Container(),
//
//                               // Processing indicator
//                               _isProcessing
//                                   ? Container(
//                                 color: Colors.black54,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     ),
//                                     SizedBox(height: screenHeight * 0.02),
//                                     Text(
//                                       _recognitionMessage,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ],
//                                 ),
//                               )
//                                   : Container(),
//
//                               // Face frame guide
//                               !_isFaceDetected && !_isProcessing && _capturedImage == null
//                                   ? Container(
//                                 width: screenWidth * 0.5,
//                                 height: screenWidth * 0.5,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                   shape: BoxShape.circle,
//                                 ),
//                               )
//                                   : Container(),
//
//                               // Recognition message display when not processing
//                               !_isProcessing && _recognitionMessage.isNotEmpty && !_isFaceDetected
//                                   ? Positioned(
//                                 bottom: 10,
//                                 left: 10,
//                                 right: 10,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black54,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     _recognitionMessage,
//                                     style: const TextStyle(color: Colors.white),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               )
//                                   : Container(),
//                             ],
//                           )
//                               : const Center(
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.02),
//
//                       // Action buttons
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Scan face button
//                           ElevatedButton.icon(
//                             onPressed: _isCameraInitialized && !_isProcessing && !_isFaceDetected
//                                 ? _captureFace
//                                 : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: screenWidth * 0.04,
//                                 vertical: screenHeight * 0.015,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                               ),
//                             ),
//                             icon: Icon(Icons.camera_alt),
//                             label: Text(
//                               "Scan Face",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.035,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//
//                           SizedBox(width: screenWidth * 0.04),
//
//                           // Check in/out button
//                           ElevatedButton.icon(
//                             onPressed: _isFaceDetected && !_isProcessing
//                                 ? _performCheckInOut
//                                 : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AdaptiveColors.primaryGreen,
//                               foregroundColor: Colors.white,
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: screenWidth * 0.04,
//                                 vertical: screenHeight * 0.015,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                               ),
//                             ),
//                             icon: Icon(_isCheckedIn ? Icons.logout : Icons.login),
//                             label: Text(
//                               _isCheckedIn ? "Check Out" : "Check In",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.035,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(height: screenHeight * 0.01),
//
//                       // Registration button
//                       TextButton.icon(
//                         onPressed: _navigateToRegistration,
//                         icon: Icon(Icons.person_add),
//                         label: Text("Register New Face"),
//                       ),
//
//                       SizedBox(height: screenHeight * 0.02),
//
//                       // Instructions
//                       Container(
//                         padding: EdgeInsets.all(screenWidth * 0.04),
//                         decoration: BoxDecoration(
//                           color: AdaptiveColors.cardColor(context),
//                           borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AdaptiveColors.shadowColor(context),
//                               blurRadius: 3,
//                               offset: const Offset(0, 1),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.info_outline,
//                                   color: AdaptiveColors.primaryGreen,
//                                   size: screenWidth * 0.05,
//                                 ),
//                                 SizedBox(width: screenWidth * 0.02),
//                                 Text(
//                                   "Instructions",
//                                   style: TextStyle(
//                                     fontSize: screenWidth * 0.045,
//                                     fontWeight: FontWeight.bold,
//                                     color: AdaptiveColors.primaryTextColor(context),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             _buildInstructionStep(context, "1", "Position your face within the circle", screenWidth),
//                             SizedBox(height: screenHeight * 0.01),
//                             _buildInstructionStep(context, "2", "Ensure good lighting for better recognition", screenWidth),
//                             SizedBox(height: screenHeight * 0.01),
//                             _buildInstructionStep(context, "3", "Press the Scan Face button", screenWidth),
//                             SizedBox(height: screenHeight * 0.01),
//                             _buildInstructionStep(context, "4", "Once your face is detected, press the Check In/Out button", screenWidth),
//                           ],
//                         ),
//                       ),
//
//                       // Last check records
//                       SizedBox(height: screenHeight * 0.02),
//                       if (_lastCheckTime.isNotEmpty)
//                         Container(
//                           padding: EdgeInsets.all(screenWidth * 0.04),
//                           decoration: BoxDecoration(
//                             color: AdaptiveColors.cardColor(context),
//                             borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: AdaptiveColors.shadowColor(context),
//                                 blurRadius: 3,
//                                 offset: const Offset(0, 1),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.history,
//                                     color: AdaptiveColors.primaryGreen,
//                                     size: screenWidth * 0.05,
//                                   ),
//                                   SizedBox(width: screenWidth * 0.02),
//                                   Text(
//                                     "Recent Activity",
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.045,
//                                       fontWeight: FontWeight.bold,
//                                       color: AdaptiveColors.primaryTextColor(context),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: screenHeight * 0.01),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Today",
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.035,
//                                       color: AdaptiveColors.secondaryTextColor(context),
//                                     ),
//                                   ),
//                                   Text(
//                                     formattedDate,
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.035,
//                                       color: AdaptiveColors.secondaryTextColor(context),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: screenHeight * 0.01),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Last ${ _isCheckedIn ? "Check In" : "Check Out"}",
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.04,
//                                       fontWeight: FontWeight.w500,
//                                       color: AdaptiveColors.primaryTextColor(context),
//                                     ),
//                                   ),
//                                   Text(
//                                     _lastCheckTime,
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.04,
//                                       fontWeight: FontWeight.bold,
//                                       color: _isCheckedIn ? Colors.green : Colors.orange,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               if (_recognizedUserName != null)
//                                 Padding(
//                                   padding: EdgeInsets.only(top: screenHeight * 0.01),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "User",
//                                         style: TextStyle(
//                                           fontSize: screenWidth * 0.04,
//                                           fontWeight: FontWeight.w500,
//                                           color: AdaptiveColors.primaryTextColor(context),
//                                         ),
//                                       ),
//                                       Text(
//                                         _recognizedUserName!,
//                                         style: TextStyle(
//                                           fontSize: screenWidth * 0.04,
//                                           fontWeight: FontWeight.bold,
//                                           color: AdaptiveColors.primaryTextColor(context),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }
//
//   Widget _buildInstructionStep(BuildContext context, String step, String text, double screenWidth) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: screenWidth * 0.06,
//           height: screenWidth * 0.06,
//           decoration: BoxDecoration(
//             color: AdaptiveColors.primaryGreen.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Text(
//               step,
//               style: TextStyle(
//                 fontSize: screenWidth * 0.035,
//                 fontWeight: FontWeight.bold,
//                 color: AdaptiveColors.primaryGreen,
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: screenWidth * 0.02),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(
//               fontSize: screenWidth * 0.035,
//               color: AdaptiveColors.primaryTextColor(context),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
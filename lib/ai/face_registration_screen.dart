import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:in_out/ai/remote_pointing_service.dart';
import 'package:in_out/ai/recognition_result.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key});

  @override
  _FaceRegistrationScreenState createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() => _cameraController = controller);
    } on CameraException catch (_) {
      setState(() => _permissionDenied = true);
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Camera access is required to register and recognize faces. Please enable camera permission in settings.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Prompt the user to enter a name for registration
  Future<String?> _promptForName() async {
    String name = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Who's this person?"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter full name'),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(name.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (_cameraController == null) return;
    // Ask for the person's name
    final userName = await _promptForName();
    if (userName == null || userName.isEmpty) {
      // User cancelled or entered nothing
      return;
    }
    try {
      final picture = await _cameraController!.takePicture();
      final bytes = await File(picture.path).readAsBytes();
      // Generate a simple ID based on timestamp
      final userId = DateTime.now().millisecondsSinceEpoch;
      final msg = await RemotePointageService().registerUser(userId, userName, [bytes]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering face: $e')),
      );
    }
  }

  Future<void> _onCheck() async {
    if (_cameraController == null) return;
    try {
      final picture = await _cameraController!.takePicture();
      final bytes = await File(picture.path).readAsBytes();
      final RecognitionResult result = await RemotePointageService().recognizeFace(bytes);
      String message;
      if (result.recognized && result.userName != null) {
        final now = DateTime.now().toLocal();
        message =
        'Recognized: ${result.userName} at ${now.toString().split('.')[0]}';
      } else {
        message = 'No person with the same correspondence found.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recognizing face: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: const Text('Face Registration & Check')),
        body: const Center(
          child: Text(
            'Camera permission denied. Please enable it in settings.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Face Registration & Check')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              _cameraController == null ||
              !_cameraController!.value.isInitialized) {
            return const Center(
              child: Text(
                'Unable to access the camera.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return Column(
            children: [
              Expanded(child: CameraPreview(_cameraController!)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _onSave,
                      child: const Text('Register Face'),
                    ),
                    ElevatedButton(
                      onPressed: _onCheck,
                      child: const Text('Check Face'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

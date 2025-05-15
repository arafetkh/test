import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  // Singleton instance
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  // Getters
  bool get isInitialized => _isInitialized;
  CameraController? get cameraController => _cameraController;

  /// Initialize the camera
  Future<bool> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return false;
      }

      // Use front camera if available for face recognition
      final frontCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Dispose the camera controller
  void dispose() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _cameraController!.dispose();
      _cameraController = null;
    }
    _isInitialized = false;
  }

  /// Capture an image and return it as bytes
  Future<Uint8List?> captureImage() async {
    if (!_isInitialized || _cameraController == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final Uint8List bytes = await image.readAsBytes();
      return bytes;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Capture multiple images with a delay between captures
  /// Useful for face registration where multiple angles are needed
  Future<List<Uint8List>> captureMultipleImages(int count, Duration delay) async {
    List<Uint8List> images = [];

    for (int i = 0; i < count; i++) {
      try {
        final image = await captureImage();
        if (image != null) {
          images.add(image);
        }

        // Wait for the specified delay before capturing the next image
        if (i < count - 1) {
          await Future.delayed(delay);
        }
      } catch (e) {
        debugPrint('Error capturing image $i: $e');
      }
    }

    return images;
  }

  /// Process a camera image for face detection
  /// This is a placeholder for more advanced processing like face detection
  Future<Uint8List?> processImageForFaceDetection(CameraImage cameraImage) async {
    // This would be implemented with actual face detection logic
    // For now, we just convert the camera image to a byte array

    // This is a simplified conversion and may not work for all camera formats
    // In a real app, you would use a proper image conversion library

    throw UnimplementedError('Image processing not implemented');
  }

  /// Get the appropriate resolution preset based on device capabilities
  ResolutionPreset getOptimalResolution() {
    // Default to medium resolution for most devices
    // This could be adjusted based on device capabilities or user preference
    return ResolutionPreset.medium;
  }
}
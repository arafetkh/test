// lib/models/recognition_result.dart
class RecognitionResult {
  final bool recognized;
  final int? userId;
  final String? userName;
  final String message;

  RecognitionResult({
    required this.recognized,
    this.userId,
    this.userName,
    required this.message,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      recognized: json['recognized'] ?? false,
      userId: json['user_id'],
      userName: json['user_name'],
      message: json['message'] ?? 'Unknown response',
    );
  }

  factory RecognitionResult.error(String errorMessage) {
    return RecognitionResult(
      recognized: false,
      message: errorMessage,
    );
  }
}
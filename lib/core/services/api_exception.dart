class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? body;

  ApiException({
    required this.message,
    required this.statusCode,
    this.body,
  });

  @override
  String toString() => message;
}
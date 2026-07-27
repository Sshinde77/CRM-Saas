class ApiResponse<T> {
  final bool success;
  final int? statusCode;
  final String message;
  final T? data;
  final String rawBody;

  const ApiResponse({
    required this.success,
    required this.message,
    required this.rawBody,
    this.statusCode,
    this.data,
  });
}

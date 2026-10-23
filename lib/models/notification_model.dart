class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, String>? data;
  final DateTime? createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map
        ? rawData.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : null;
    DateTime? date(String key) =>
        DateTime.tryParse(json[key]?.toString() ?? '');

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      data: data,
      createdAt: date('created_at') ?? date('createdAt'),
      readAt: date('read_at') ?? date('readAt'),
    );
  }
}

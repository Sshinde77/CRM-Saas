class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, String>? data;
  final DateTime? createdAt;
  final DateTime? readAt;

  /// The business event this notification is about (e.g. `order_created`,
  /// `lead_assigned`). Mirrors `data['event']`; present as its own field since
  /// the backend contract (2026-11-02) now returns it at the top level too.
  final String? event;

  /// What record this notification is about, and where tapping it should go.
  /// `null` for events with no subject (e.g. `push_test`) or on older rows
  /// from before these fields existed.
  final String? entityType;
  final String? entityId;
  final String? actionUrl;

  /// The user who caused the event, when known.
  final String? actorId;

  /// `organization` for tenant notifications, `platform` for Super Admin /
  /// platform-staff ones.
  final String? scope;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.createdAt,
    this.readAt,
    this.event,
    this.entityType,
    this.entityId,
    this.actionUrl,
    this.actorId,
    this.scope,
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
    String? str(String key) => json[key]?.toString();

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      data: data,
      createdAt: date('created_at') ?? date('createdAt'),
      readAt: date('read_at') ?? date('readAt'),
      event: str('event') ?? data?['event'],
      entityType: str('entity_type'),
      entityId: str('entity_id'),
      actionUrl: str('action_url'),
      actorId: str('actor_id'),
      scope: str('scope'),
    );
  }
}

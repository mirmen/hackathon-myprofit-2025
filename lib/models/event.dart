// models/event.dart
class Event {
  final String id;
  final String clubId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String? location;
  final String eventType; // 'workshop', 'meeting', 'competition', etc.

  Event({
    required this.id,
    required this.clubId,
    required this.title,
    required this.description,
    required this.dateTime,
    this.location,
    required this.eventType,
  });

  Event copyWith({
    String? id,
    String? clubId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? eventType,
  }) {
    return Event(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'location': location,
      'event_type': eventType,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      clubId: json['club_id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['date_time']),
      location: json['location'],
      eventType: json['event_type'],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String hostId;
  final int? maxSlots;
  final List<String> attendees;
  final List<String> waitlist;
  final String category;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.hostId,
    this.maxSlots,
    required this.category,
    this.attendees = const [],
    this.waitlist = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        date: (json['date'] as Timestamp).toDate(),
        time: json['time'],
        location: json['location'],
        hostId: json['hostId'],
        maxSlots: json['maxSlots'],
        category: json['category'],
        attendees: List<String>.from(json['attendees'] ?? []),
        waitlist: List<String>.from(json['waitlist'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': Timestamp.fromDate(date),
        'time': time,
        'location': location,
        'hostId': hostId,
        'maxSlots': maxSlots,
        'category': category,
        'attendees': attendees,
        'waitlist': waitlist,
      };

  int get availableSlots => maxSlots != null ? maxSlots! - attendees.length : 0;
  bool get isFull => maxSlots != null && attendees.length >= maxSlots!;

  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? hostId,
    List<String>? attendees,
    List<String>? waitlist,
    String? description,
    String? time,
    String? location,
    String? category,
    int? maxSlots,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      hostId: hostId ?? this.hostId,
      attendees: attendees ?? this.attendees,
      waitlist: waitlist ?? this.waitlist,
      description: description ?? this.description,
      time: time ?? this.time,
      location: location ?? this.location,
      category: category ?? this.category,
      maxSlots: maxSlots ?? this.maxSlots,
    );
  }
}

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/event/event_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  EventsCubit() : super(EventsInitial());

  void fetchEvents({
    DateTime? startDate,
    String? category,
    String? location,
  }) {
    try {
      emit(EventsLoading());

      // Base query with 1 hour buffer for timezone differences
      DateTime queryDate = (startDate ?? DateTime.now()).subtract(
        const Duration(hours: 1),
      );

      Query query = _firestore
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: queryDate)
          .orderBy('date', descending: false);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }

      _subscription?.cancel();
      _subscription = query.snapshots().listen((snapshot) {
        final events = snapshot.docs
            .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        // Debug: Print events found
        print('Fetched ${events.length} events from Firebase');
        for (var event in events) {
          print('Event: ${event.title}, Date: ${event.date}, ID: ${event.id}');
        }

        emit(EventsLoaded(events));
      }, onError: (error) {
        print('Error in fetchEvents stream: $error');
        emit(EventsError(error.toString()));
      }) as StreamSubscription<QuerySnapshot<Map<String, dynamic>>>;
    } catch (e) {
      print('Exception in fetchEvents: $e');
      emit(EventsError('Failed to load events: $e'));
    }
  }

  Future<void> createEvent(Event event) async {
    try {
      emit(EventsLoading());

      // Set the host ID to current user
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Create a copy of the event with the host ID
      final eventWithHost = event.copyWith(hostId: userId);

      // Save to Firestore
      await _firestore
          .collection('events')
          .doc(eventWithHost.id)
          .set(eventWithHost.toJson());
      print('Event created successfully: ${eventWithHost.id}');

      // Emit success state
      emit(EventCreated());

      // Note: We don't need to fetch events here as the stream will update automatically
    } catch (e) {
      print('Error creating event: $e');
      emit(EventsError('Failed to create event: $e'));
    }
  }

  Future<void> joinEvent(Event event) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final docRef = _firestore.collection('events').doc(event.id);

      await _firestore.runTransaction((transaction) async {
        final freshDoc = await transaction.get(docRef);
        if (!freshDoc.exists) {
          throw Exception('Event no longer exists');
        }

        final freshEvent = Event.fromJson(freshDoc.data()!);

        if (freshEvent.attendees.contains(userId) ||
            freshEvent.waitlist.contains(userId)) {
          throw Exception('Already registered for this event');
        }

        if (freshEvent.isFull) {
          transaction.update(docRef, {
            'waitlist': FieldValue.arrayUnion([userId])
          });
        } else {
          transaction.update(docRef, {
            'attendees': FieldValue.arrayUnion([userId])
          });
        }
      });

      emit(EventJoined());
    } catch (e) {
      print('Error joining event: $e');
      emit(EventsError('Failed to join event: $e'));
    }
  }

  Future<void> fetchUserEvents() async {
    try {
      emit(EventsLoading());
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final hosted = await _firestore
          .collection('events')
          .where('hostId', isEqualTo: userId)
          .get()
          .then((snap) =>
              snap.docs.map((d) => Event.fromJson(d.data())).toList());

      final attending = await _firestore
          .collection('events')
          .where('attendees', arrayContains: userId)
          .get()
          .then((snap) =>
              snap.docs.map((d) => Event.fromJson(d.data())).toList());

      final waitlisted = await _firestore
          .collection('events')
          .where('waitlist', arrayContains: userId)
          .get()
          .then((snap) =>
              snap.docs.map((d) => Event.fromJson(d.data())).toList());

      emit(UserEventsLoaded(
        hosted: hosted,
        attending: attending,
        waitlisted: waitlisted,
      ));
    } catch (e) {
      print('Error fetching user events: $e');
      emit(EventsError('Failed to load user events: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

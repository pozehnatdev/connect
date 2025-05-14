part of 'events_cubit.dart';

abstract class EventsState extends Equatable {
  const EventsState();
  @override
  List<Object> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventCreated extends EventsState {}

class EventJoined extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;
  const EventsLoaded(this.events);
  @override
  List<Object> get props => [events];
}

class UserEventsLoaded extends EventsState {
  final List<Event> hosted;
  final List<Event> attending;
  final List<Event> waitlisted;

  const UserEventsLoaded({
    required this.hosted,
    required this.attending,
    required this.waitlisted,
  });

  @override
  List<Object> get props => [hosted, attending, waitlisted];
}

class EventsError extends EventsState {
  final String message;
  const EventsError(this.message);
  @override
  List<Object> get props => [message];
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectapp/screens/events/presentation/cubits/events_cubit.dart';
import 'package:connectapp/screens/events/presentation/pages/create_event_screen.dart';
import 'package:connectapp/screens/events/presentation/pages/events_list_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a single EventsCubit for the entire events feature
    return BlocProvider(
      create: (context) => EventsCubit()..fetchEvents(),
      child: _EventsScreenContent(),
    );
  }
}

class _EventsScreenContent extends StatelessWidget {
  final Color linkedInBlue = const Color(0xFF0077B5);
  final Color lightBlue = const Color(0xFF0A66C2);
  final Color whiteBackground = const Color(0xFFF3F2EF);
  final Color borderGrey = const Color(0xFFE1E9EE);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.event, color: linkedInBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              'Events',
              style: TextStyle(
                color: linkedInBlue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: linkedInBlue),
            onPressed: () => context.read<EventsCubit>().fetchEvents(),
          ),
        ],
      ),
      body: const EventsListScreen(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A66C2),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateEventScreen(),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

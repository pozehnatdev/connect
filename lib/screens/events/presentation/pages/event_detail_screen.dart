import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/event/event_model.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/events/presentation/cubits/events_cubit.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final Future<Userr?> _hostFuture;

  @override
  void initState() {
    super.initState();
    _hostFuture = _fetchHostDetails(widget.event.hostId);
  }

  Future<Userr?> _fetchHostDetails(String hostId) async {
    try {
      // Handle empty host ID
      if (hostId.isEmpty) {
        print('Warning: Empty hostId for event ${widget.event.id}');
        return null;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(hostId)
          .withConverter<Userr>(
            fromFirestore: (snapshot, _) {
              if (snapshot.exists && snapshot.data() != null) {
                return Userr.fromJson(snapshot.data()!);
              } else {
                throw Exception('User data is null or does not exist');
              }
            },
            toFirestore: (user, _) => user.toJson(),
          )
          .get();

      return doc.data();
    } catch (e) {
      print('Error fetching host details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Category color mapping (matching EventCard)
    final categoryColors = {
      'Networking': Colors.blue[700],
      'Workshop': Colors.green[700],
      'Social': Colors.purple[700],
      'Other': Colors.orange[700],
    };

    final categoryColor =
        categoryColors[widget.event.category] ?? Colors.blue[700];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        backgroundColor: categoryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<EventsCubit, EventsState>(
        listener: (context, state) {
          if (state is EventJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Successfully joined event!')));
            setState(() {}); // Refresh UI
          } else if (state is EventsError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Column(
          children: [
            // Category header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              color: categoryColor,
              child: Text(
                widget.event.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventHeader(),
                    const SizedBox(height: 24),

                    // Event date and time
                    _buildEventDateTime(),
                    const SizedBox(height: 24),

                    // Description header
                    Text(
                      'About this event',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      widget.event.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Event details
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Details',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.location_on,
                            widget.event.location,
                            categoryColor!,
                          ),
                          if (widget.event.maxSlots != null)
                            _buildDetailRow(
                              Icons.people,
                              '${widget.event.attendees.length}/${widget.event.maxSlots} slots filled',
                              categoryColor,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildAttendeesSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Action button at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildJoinButton(categoryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return FutureBuilder<Userr?>(
      future: _hostFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final host = snapshot.data;
        if (host == null) {
          // Handle null host
          return const Card(
            elevation: 1,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 30),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unknown Host',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Host details not available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      host.imageUrl != null && host.imageUrl!.isNotEmpty
                          ? NetworkImage(host.imageUrl!)
                          : null,
                  child: (host.imageUrl == null || host.imageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hosted by ${host.first_name ?? ''} ${host.last_name ?? ''}'
                            .trim(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (host.proffesional_details != null &&
                          host.proffesional_details!.isNotEmpty &&
                          host.proffesional_details!.first['position'] != null)
                        Text(
                          host.proffesional_details!.first['position'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventDateTime() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMd().format(widget.event.date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.jm().format(widget.event.date),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendees (${widget.event.attendees.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        widget.event.attendees.isEmpty
            ? const Text('No attendees yet. Be the first to join!')
            : FutureBuilder<List<Userr>>(
                future: _fetchAttendees(widget.event.attendees),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Unable to load attendees');
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: snapshot.data!.map((user) {
                        final firstLetter =
                            (user.first_name?.isNotEmpty ?? false)
                                ? user.first_name![0].toUpperCase()
                                : '?';

                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  (user.imageUrl?.isNotEmpty ?? false)
                                      ? NetworkImage(user.imageUrl!)
                                      : null,
                              child: (user.imageUrl?.isNotEmpty ?? false)
                                  ? null
                                  : Text(firstLetter),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.first_name ?? 'User',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Future<List<Userr>> _fetchAttendees(List<String> userIds) async {
    if (userIds.isEmpty) {
      return [];
    }

    try {
      // Firestore has a limit of 10 items for whereIn queries
      // We need to batch our requests if there are more than 10 attendees
      final List<Userr> allUsers = [];

      for (var i = 0; i < userIds.length; i += 10) {
        final end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
        final chunk = userIds.sublist(i, end);

        final users = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .withConverter<Userr>(
              fromFirestore: (snapshot, _) =>
                  snapshot.exists && snapshot.data() != null
                      ? Userr.fromJson(snapshot.data()!)
                      : Userr(
                          first_name: '',
                          last_name: '',
                          email: ''), // Return empty user as fallback
              toFirestore: (user, _) => user.toJson(),
            )
            .get()
            .then(
                (snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

        allUsers.addAll(users);
      }

      return allUsers;
    } catch (e) {
      print('Error fetching attendees: $e');
      return [];
    }
  }

  Widget _buildJoinButton(Color categoryColor) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isHost = widget.event.hostId == currentUserId;
    final isAttending = widget.event.attendees.contains(currentUserId);
    final isWaitlisted = widget.event.waitlist.contains(currentUserId);

    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        final isLoading = state is EventsLoading;

        if (isHost) {
          return ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Manage Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: categoryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              // TODO: Add event management navigation
            },
          );
        }

        if (isAttending) {
          return OutlinedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Already Attending'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green[700],
              side: BorderSide(color: Colors.green[700]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: null,
          );
        }

        if (isWaitlisted) {
          return OutlinedButton.icon(
            icon: const Icon(Icons.hourglass_top),
            label: const Text('Waitlisted'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange[700],
              side: BorderSide(color: Colors.orange[700]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: null,
          );
        }

        if (widget.event.isFull) {
          return OutlinedButton.icon(
            icon: const Icon(Icons.error_outline),
            label: const Text('Event Full - Join Waitlist'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[700]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: isLoading
                ? null
                : () {
                    context.read<EventsCubit>().joinEvent(widget.event);
                  },
          );
        }

        return ElevatedButton.icon(
          icon: isLoading
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.event_available),
          label: Text(isLoading ? 'Joining...' : 'Join Event'),
          style: ElevatedButton.styleFrom(
            backgroundColor: categoryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: isLoading
              ? null
              : () {
                  context.read<EventsCubit>().joinEvent(widget.event);
                },
        );
      },
    );
  }
}

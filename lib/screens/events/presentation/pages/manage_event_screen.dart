import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectapp/model/event/event_model.dart';
import 'package:connectapp/screens/events/presentation/cubits/events_cubit.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ManageEventScreen extends StatefulWidget {
  final Event? event;
  const ManageEventScreen({this.event, super.key});

  @override
  State<ManageEventScreen> createState() => _ManageEventScreenState();
}

class _ManageEventScreenState extends State<ManageEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  String _category = 'Networking';
  int? _maxSlots;
  // Removed _categoryController as category is managed by _category String variable.
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? "");
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? "");
    _locationController =
        TextEditingController(text: widget.event?.location ?? "");
    _selectedDate =
        widget.event?.date ?? DateTime.now().add(const Duration(days: 1));
    // Removed _categoryController initialization as it's not needed.
    _category = widget.event?.category ?? 'Networking';
    _maxSlots = widget.event?.maxSlots;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    // Removed _categoryController disposal as it's not needed.

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventsCubit, EventsState>(
      listener: (context, state) {
        if (state is EventsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          setState(() => _isCreating = false);
        } else if (state is EventsLoaded) {
          // Success! Go back to the events list
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Manage Event')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Networking', 'Workshop', 'Social', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Date: ${DateFormat.yMMMd().add_jm().format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Max Slots (optional)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() => _maxSlots = int.tryParse(value));
                  } else {
                    setState(() => _maxSlots = null);
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isCreating ? null : _submitForm,
                child: _isCreating
                    ? const CircularProgressIndicator()
                    : const Text('Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isCreating = true);

      final event = Event(
        id: widget.event?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate,
        category: _category,
        maxSlots: _maxSlots,
        hostId: '', // Will be set by Firebase Auth in the cubit
        attendees: widget.event?.attendees ?? [],
        waitlist: widget.event?.waitlist ?? [],
        time:
            DateTime.now().toString(), // Placeholder, will be set in the cubit
      );

      context.read<EventsCubit>().updateEvent(event).then((_) {
        // Explicitly fetch events after creating
        context.read<EventsCubit>().fetchEvents();
      });
    }
  }
}

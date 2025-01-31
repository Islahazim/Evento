import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController maxPaxController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();

  DateTime? selectedDateTime;

  // Function to pick date and time
  Future<void> _pickDateTime(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          dateTimeController.text =
          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedTime.hour}:${selectedTime.minute}";
        });
      }
    }
  }

  // Function to generate a random event code
  String generateEventCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD1A055), // Top gradient color
              Color(0xFFF3C1A9), // Bottom gradient color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox.expand( // Ensures the gradient covers the entire screen
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: eventNameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateTimeController,
                  readOnly: true,
                  onTap: () => _pickDateTime(context),
                  decoration: const InputDecoration(
                    labelText: 'Date/Time',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: 'Venue'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: maxPaxController,
                  decoration: const InputDecoration(labelText: 'Maximum Pax (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (eventNameController.text.isNotEmpty && selectedDateTime != null) {
                      try {
                        final eventCode = generateEventCode();
                        await createEvent(
                          eventNameController.text,
                          descriptionController.text,
                          venueController.text,
                          selectedDateTime!,
                          maxPaxController.text,
                          eventCode,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Event created successfully! Event Code: $eventCode')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                    }
                  },
                  child: const Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }

  Future<void> createEvent(
      String eventName,
      String description,
      String venue,
      DateTime eventDateTime,
      String maxPax,
      String eventCode,
      ) async {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    // Generate unique event ID
    final eventId = eventCode;

    // Event data to save
    final eventData = {
      'eventId': eventId,
      'eventName': eventName,
      'description': description,
      'venue': venue,
      'eventDateTime': eventDateTime.toIso8601String(),
      'maxPax': maxPax.isNotEmpty ? int.parse(maxPax) : null,
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': user.uid, // Associate event with the current user
      'eventCode': eventCode, // Random code for joining the event
    };

    // Save event under the user's subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('CreatedEvents')
        .doc(eventId)
        .set(eventData);

    // Optionally save event in a global 'events' collection
    await FirebaseFirestore.instance.collection('events').doc(eventId).set(eventData);
  }
}

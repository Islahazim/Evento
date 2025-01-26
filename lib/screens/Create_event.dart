import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class CreateEventPage extends StatelessWidget {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController maxPaxController = TextEditingController();
  DateTime? eventDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Event Name Input
              TextField(
                controller: eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              // Description Input
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              // Venue Input
              TextField(
                controller: venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
              ),
              // Maximum Pax Input
              TextField(
                controller: maxPaxController,
                decoration: const InputDecoration(labelText: 'Maximum Pax (Optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Date Picker Button
              ElevatedButton(
                onPressed: () async {
                  eventDateTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
                child: const Text('Select Event Date'),
              ),
              const SizedBox(height: 16),
              // Create Event Button
              ElevatedButton(
                onPressed: () async {
                  if (eventNameController.text.isNotEmpty && eventDateTime != null) {
                    try {
                      await createEvent(
                        eventNameController.text,
                        descriptionController.text,
                        venueController.text,
                        eventDateTime!,
                        maxPaxController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event created successfully!')),
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
    );
  }

  Future<void> createEvent(
      String eventName,
      String description,
      String venue,
      DateTime eventDateTime,
      String maxPax,
      ) async {
    // Get current user
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    // Generate unique event ID
    final eventId = Uuid().v4();

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

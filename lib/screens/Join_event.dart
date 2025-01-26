import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinEventPage extends StatelessWidget {
  final TextEditingController eventCodeController = TextEditingController();

  JoinEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Event Code Input
            TextField(
              controller: eventCodeController,
              decoration: const InputDecoration(labelText: 'Enter Event Code'),
            ),
            const SizedBox(height: 16),

            // Join Event Button
            ElevatedButton(
              onPressed: () async {
                final eventCode = eventCodeController.text.trim();
                if (eventCode.isNotEmpty) {
                  try {
                    final event = await fetchEventByCode(eventCode);
                    if (event != null) {
                      await addToJoinedEvents(event);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Joined event: ${event['eventName']}')),
                      );
                      Navigator.pop(context); // Navigate back after successful join
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid event code')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid event code')),
                  );
                }
              },
              child: const Text('Join Event'),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch event details by event code
  Future<Map<String, dynamic>?> fetchEventByCode(String eventCode) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('eventCode', isEqualTo: eventCode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }

  // Add event to user's JoinedEvents subcollection
  Future<void> addToJoinedEvents(Map<String, dynamic> event) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final joinedEventRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('JoinedEvents')
        .doc(event['eventId']); // Use eventId as the document ID

    // Save the event details in the user's JoinedEvents subcollection
    await joinedEventRef.set(event);
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'participants_page.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  _ManageEventsPageState createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Created'),
            Tab(text: 'Joined'),
          ],
        ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab for Created Events
            _buildCreatedEventsTab(),
            // Tab for Joined Events
            _buildJoinedEventsTab(),
          ],
        ),
      ),

    );
  }

  Widget _buildCreatedEventsTab() {
    if (user == null) {
      return const Center(child: Text('You need to sign in to view your events.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('CreatedEvents') // Created events subcollection
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No created events.'));
        }

        final events = snapshot.data!.docs;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;
            final eventID = events[index].id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['eventName'] ?? 'No Event Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date and Time: ${event['eventDateTime'] ?? 'No Date/Time'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Venue: ${event['venue'] ?? 'No Venue'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Description: ${event['description'] ?? 'No Description'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Maximum Pax: ${event['maxPax'] ?? 'Not Specified'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Event Code: ${event['eventCode'] ?? 'No Event Code'}',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParticipantsPage(
                              eventId: eventID,
                              eventName: event['eventName']),
                            ),
                          );
                        },
                        child: const Text('View Participants'),
                      ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Delete Event"),
                                content: const Text("Are you sure you want to delete this event?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete){
                            try {
                              await deleteEvent(event['eventId']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Event deleted successfully')),
                            );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildJoinedEventsTab() {
    if (user == null) {
      return const Center(child: Text('You need to sign in to view your events.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('JoinedEvents') // Joined events subcollection
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No joined events.'));
        }

        final events = snapshot.data!.docs;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(event['eventName']),
              subtitle: Text(event['eventDateTime']),
            );
          },
        );
      },
    );
  }

  Future<void> deleteEvent(String eventId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    QuerySnapshot joinedUsersSnapshot = await _firestore
        .collection('users')
        .get();

    // Remove event from each user's joined events
    for (var userDoc in joinedUsersSnapshot.docs){
      DocumentSnapshot joinedEventDoc = await _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('JoinedEvents')
          .doc(eventId)
          .get();

        if(joinedEventDoc.exists){
          await joinedEventDoc.reference.delete(); // Delete event from user’s JoinedEvents
        }
    }

    // Remove all participants from the event
    QuerySnapshot participantsSnapshot = await _firestore
      .collection('events')
      .doc(eventId)
      .collection('Participants')
      .get();

    for (var participant in participantsSnapshot.docs){
      await participant.reference.delete();
    }

    //Deleting the event from the database
    await _firestore.collection('events').doc(eventId).delete();
    await _firestore
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('CreatedEvents')
      .doc(eventId)
      .delete();
  }
}

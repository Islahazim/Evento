import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageEventsPage extends StatefulWidget {
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab for Created Events
          _buildCreatedEventsTab(),
          // Tab for Joined Events
          _buildJoinedEventsTab(),
        ],
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await deleteEvent(events[index].id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event deleted successfully')),
                          );
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
    // Delete from the specific user's created events
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('CreatedEvents')
        .doc(eventId)
        .delete();

    // Optionally delete from the global events collection
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }
}

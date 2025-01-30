import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_services.dart';

class HomePage extends StatelessWidget {
  final FirebaseServices _firebaseServices = FirebaseServices();

  HomePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _firebaseServices.googleSignOut();
                Navigator.of(context).pop(); //Close the dialog
                Navigator.pushReplacementNamed(
                    context, '/login'); // Navigate to Login page
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              _showLogoutDialog(context); // Navigate to login page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            SizedBox(height: 16),

            // User Name
            Text(
              user?.displayName ?? "Guest User",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // User Email
            Text(
              user?.email ?? "No Email",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),

            // Create Event Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createEvent'); // Navigate to Create Event page
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Create Event"),
            ),
            SizedBox(height: 16),

            // Join Event Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/joinEvent'); // Navigate to Join Event page
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Join Event"),
            ),
            SizedBox(height: 16),

            // Manage Events Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manageEvents'); // Navigate to Manage Events page
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Manage Events"),
            ),
          ],
        ),
      ),
    );
  }
}


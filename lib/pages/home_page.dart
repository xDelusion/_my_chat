import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/components/user_tile.dart';
import 'package:my_chat/pages/chat_page.dart';
import 'package:my_chat/services/auth/auth_service.dart';
import 'package:my_chat/components/my_drawer.dart';
import 'package:my_chat/services/chat/chat_service.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Add this line to update user presence when the HomePage is opened
    _authService.updateUserPresence();
  }

  @override
  void dispose() {
    super.dispose();
    // Add this line to update user presence when the HomePage is closed
    _authService.updateUserOffline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          StreamBuilder(
            stream: _authService.getUserPresenceStream(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              bool isOnline = snapshot.data?['online'] ?? false;

              return Column(
                children: [
                  // Display online status
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(fontSize: 18),
                  ),
                  // User list
                  _userList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _userList() {
    return StreamBuilder(
      stream: _chatService.getUsers(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Loading...'));
        }

        List<Map<String, dynamic>> users = snapshot.data;

        print("Number of users: ${users.length}");

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            print("User data: ${users[index]}");
            Map<String, dynamic> userData = users[index];

            // Exclude the current user's status
            if (userData["email"] != _authService.getCurrentUser()!.email) {
              // Determine online/offline status
              bool isOnline = userData['online'] ?? false;

              // Set the circle color based on online/offline status
              Color circleColor = isOnline ? Colors.green : Colors.grey;

              return ListTile(
                title: Text(userData["email"]),
                trailing: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverEmail: userData["email"],
                        receiverID: userData["uid"],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Container(); // Exclude the current user's item
            }
          },
        );
      },
    );
  }

  Widget _userListItem(Map<String, dynamic> userData, BuildContext context) {
    // display all users except for the current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      // adding !.email will the if statement to execute only if the email is not null
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        receiverEmail: userData["email"],
                        receiverID: userData["uid"],
                      )));
        },
      );
    } else {
      return Container();
    }
  }
}

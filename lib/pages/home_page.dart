import 'package:flutter/material.dart';
import 'package:my_chat/components/user_tile.dart';
import 'package:my_chat/pages/chat_page.dart';
import 'package:my_chat/services/auth/auth_service.dart';
import 'package:my_chat/components/my_drawer.dart';
import 'package:my_chat/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // chat & auth services

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
      ),
      drawer: MyDrawer(),
      body: _userList(),
    );
  }

  Widget _userList() {
    return StreamBuilder(
        stream: _chatService.getUsers(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the connection state is waiting, it means the data is still being loaded. So, it shows a loading spinner
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            // if there's an error or data is null, show a message
            return Center(
              child: Text('Loading...'),
            );
          }

          return ListView(
              children: snapshot.data!
                  .map<Widget>((userData) => _userListItem(userData, context))
                  .toList());
        });
  }

  Widget _userListItem(Map<String, dynamic> userData, BuildContext context) {
    // display all users except for current user
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

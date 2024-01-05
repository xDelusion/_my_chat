import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/components/chat_bubble.dart';
import 'package:my_chat/components/my_textfield.dart';
import 'package:my_chat/services/auth/auth_service.dart';
import 'package:my_chat/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
// text controller
  final TextEditingController _messageController = TextEditingController();

// auth & chat services
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  // for textfield focus

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // cause a delay so that the keyboard has time to show up
        // then the amount of remaining space is calculated,
        // then scroll down
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

// send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);

      // clear the controller
      _messageController.clear();

      // scroll to the bottom after sending the message
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: Column(
        children: [
          // display all messages
          Expanded(child: _messageList()), _userInput()
        ],
      ),
    );
  }

  Widget _messageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverID, senderID),
        builder: (context, AsyncSnapshot snapshot) {
          // loading ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the connection state is waiting, it means the data is still being loaded. So, it shows a loading spinner
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // errors
          if (snapshot.hasError || snapshot.data == null) {
            // if there's an error or data is null, show a message
            return Center(
              child: Text('Loading...'),
            );
          }
          List<Widget> messageItems = snapshot.data!.docs
              .map<Widget>((doc) => _messageItem(doc))
              .toList();

          // return list view
          return ListView(
              controller: _scrollController, children: messageItems);
        });
  }

  Widget _messageItem(DocumentSnapshot doc) {
    Map<String, dynamic> messageData = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser =
        messageData['senderID'] == _authService.getCurrentUser()!.uid;

    // align msg to the right if sender is the current user, otherwise left
    // var alignment =
    //     isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // Parse timestamp from Firestore
    Timestamp timestamp = messageData['timestamp'];
    DateTime dateTime = timestamp.toDate();

    // Format the timestamp to display
    String formattedTime = "${dateTime.hour}:${dateTime.minute}";

    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ChatBubble(
          message: messageData["message"],
          isCurrentUser: isCurrentUser,
        ),
        // Show the timestamp next to the user's chat bubble
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Text(
            formattedTime,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _userInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // textfield should take up most of the space
          Expanded(
              child: MyTextField(
            focusNode: myFocusNode,
            controller: _messageController,
            hintText: "Type a message...",
            obscureText: false,
          )),
          Container(
              decoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              margin: EdgeInsets.only(right: 25),
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send),
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}

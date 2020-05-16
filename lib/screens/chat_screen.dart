import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:solarchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final _store = Firestore.instance;
FirebaseUser logInUser;

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final textController = TextEditingController();

  String messageText;
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != Null) {
        logInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

//  void pullMessage()async{
//    final messages = await _store.collection('message').getDocuments();
//    for(final message in  messages.documents){
//    print(message.data);}
//  }
  // push data from firebase
//  void getMessages() async {
//    // await keyword before for loop as it Stream
//    await for (var messages in _store.collection('message').snapshots()) {
//      for (var message in messages.documents) {
//        print(message.data);
//      }
//    }
//  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('☀ Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GetStreaming(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textController.clear();
                      _store.collection('message').add({
                        'text': messageText,
                        'sender': logInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GetStreaming extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _store.collection('message').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          List<MessageBox> textList = [];

          final messages = snapshot.data.documents.reversed;


          for (var message in messages) {
            final text = message.data['text'];
            final sender = message.data['sender'];
            final currentUser = logInUser.email;

            final textWidget = MessageBox(
              sender: sender,
              text: text,
              myMessage: currentUser == sender,
            );
            textList.add(textWidget);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: textList,
            ),
          );
        });
  }
}

class MessageBox extends StatelessWidget {
  MessageBox({this.text, this.sender, this.myMessage});
  final text;
  final sender;
  final myMessage;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
            ),
          ),
          Material(
              color: myMessage ? Colors.lightBlueAccent : Colors.white,
              elevation: 5.0,
              borderRadius: myMessage
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),

              // padding from material
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                      color: myMessage ? Colors.white : Colors.black,
                      fontSize: 15.0),
                ),
              ))
        ],
      ),
    );
  }
}

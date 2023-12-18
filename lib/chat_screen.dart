import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String receiverId;
  final String receiverName;

  ChatScreen({
    required this.userId,
    required this.userName,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  String getChatCollectionName() {
    // Generate a unique chat collection name using both user IDs
    String collectionName;
    if (widget.userId.compareTo(widget.receiverId) < 0) {
      // Sort the IDs in ascending order
      collectionName = '${widget.userId}_${widget.receiverId}';
    } else {
      // Sort the IDs in descending order
      collectionName = '${widget.receiverId}_${widget.userId}';
    }
    return collectionName;
  }

  void _sendMessage(String text, String imageUrl) {
    if (text.trim().isEmpty && imageUrl.isEmpty) return;

    String chatCollectionName = getChatCollectionName();

    _firestore
        .collection('chat_messages')
        .doc(chatCollectionName)
        .collection('messages')
        .add({
      'senderId': widget.userId,
      'senderName': widget.userName,
      'receiverId': widget.receiverId,
      'receiverName': widget.receiverName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': DateTime.now(),
    }).then((value) {
      // Image message sent successfully
      messageController.clear();
    }).catchError((error) {
      // Handle error while sending image message
      print('Error sending image message: $error');
    });
  }

  Future<void> _sendImage(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(source: source);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref =
          _storage.ref().child('images').child(fileName);
      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();

      _sendMessage('', imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    String chatCollectionName = getChatCollectionName();

    Stream<QuerySnapshot> messagesStream = _firestore
        .collection('chat_messages')
        .doc(chatCollectionName)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    reverse: false,
                    itemBuilder: (context, index) {
                      String senderId = messages[index]['senderId'];
                      String senderName = senderId == widget.userId
                          ? widget.userName
                          : widget.receiverName;
                      String text = messages[index]['text'];
                      String imageUrl = messages[index]['imageUrl'];

                      Widget messageWidget;
                      if (imageUrl.isNotEmpty) {
                        // Display image message
                        messageWidget = ListTile(
                          title: Align(
                            alignment: senderId == widget.userId
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              senderName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                            ),
                          ),
                          subtitle: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 100, // Set the minimum width
                              ),
                              child: Align(
                                alignment: senderId == widget.userId
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Image.network(
                                  imageUrl,
                                  height: 100, // Set the height of the image
                                  width: 100, // Set the width of the image
                                  fit: BoxFit.cover,
                                  // Adjust the fit as per your requirement
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Display text message
                        messageWidget = ListTile(
                          title: Align(
                            alignment: senderId == widget.userId
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              senderName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                            ),
                          ),
                          subtitle: Align(
                            alignment: senderId == widget.userId
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(text),
                          ),
                        );
                      }

                      return messageWidget;
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () => _showImageSourceBottomSheet(),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendMessage(
                  messageController.text.trim(),
                  '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _sendImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                _sendImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authentcatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('createdAt', descending: true) // order by time
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No massages'));
        }
        if (chatSnapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        final loadedMessages = chatSnapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 15, right: 15),
          reverse: true, // reverse order
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMassage = loadedMessages[index].data();
            final nextchatMassage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMassageUserId = chatMassage['userId'];
            final nextMassageUserId = nextchatMassage != null
                ? nextchatMassage['userId']
                : null;
            final nextUserIsSame = nextMassageUserId == currentMassageUserId;
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMassage['text'],
                isMe: authentcatedUser.uid == currentMassageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMassage['userImage'],
                username: chatMassage['username'],
                message: chatMassage['text'],
                isMe: authentcatedUser.uid == currentMassageUserId,
              );
            }
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool iscurrentUser;
  const ChatBubble(
      {super.key, required this.message, required this.iscurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: iscurrentUser
            ? Color.fromARGB(212, 30, 144, 34)
            : Color.fromARGB(255, 80, 79, 79),
      ),
      padding: EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class timeBubble extends StatelessWidget {
  final String time;
  const timeBubble({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Text(
        time,
        style: TextStyle(
            color: const Color.fromARGB(255, 122, 121, 121), fontSize: 13.0),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Usertile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const Usertile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(
              width: 20,
            ),
            Text(text),
            const Spacer(), // This pushes the next widget to the right end
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.add_circle_outline,
                size: 30, // Adjust the size as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}

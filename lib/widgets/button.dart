import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isRed;
  const MyButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.isRed});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: widget.isRed ? Colors.red : Colors.lightGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            fixedSize: const Size(250, 50)),
        child: Text(
          widget.text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

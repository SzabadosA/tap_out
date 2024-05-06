import 'package:flutter/material.dart';

class StyledElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  // Constructor for your custom button
  StyledElevatedButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.symmetric(
            horizontal: 50, vertical: 20), // Adjust padding to change size
        textStyle: TextStyle(fontSize: 20), // Optionally adjust font size
      ),
      child: Text(text),
    );
  }
}

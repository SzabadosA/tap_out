import 'package:flutter/material.dart';

// Custom styled button widget
class StyledElevatedButton extends StatelessWidget {
  // Properties for the button's text, action, background color, and text color
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  // Constructor for your custom button
  const StyledElevatedButton({
    super.key,
    required this.text, // Text to be displayed on the button
    required this.onPressed, // Callback function when the button is pressed
    this.backgroundColor = Colors.blue, // Default background color
    this.textColor = Colors.white, // Default text color
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          onPressed, // Assign the callback function to the button's onPressed property
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15), // Rounded corners for the button
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 50, vertical: 20), // Adjust padding to change size
        textStyle: const TextStyle(fontSize: 20), // Optionally adjust font size
      ),
      child: Text(
        text, // Text to display on the button
        style: TextStyle(color: textColor), // Text color
      ),
    );
  }
}

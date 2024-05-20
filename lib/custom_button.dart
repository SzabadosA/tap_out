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
    this.backgroundColor = const Color(0x00390c64), // Default background color
    this.textColor = Colors.white, // Default text color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColor.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        //boxShadow: [
        //  BoxShadow(
        //    //color: const Color(0x6D3EAF),
        //    color: const Color(0x1D093A).withOpacity(0.5),
        //    offset: const Offset(2, 2),
        //    blurRadius: 8,
        //    spreadRadius: 1,
        //  ),
        //  BoxShadow(
        //    color: const Color(0x1D093A).withOpacity(0.5),
        //    offset: const Offset(0, 0),
        //    blurRadius: 20,
        //    spreadRadius: 5,
        //  ),
        //],
      ),
      child: ElevatedButton(
        onPressed:
            onPressed, // Assign the callback function to the button's onPressed property
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors
              .transparent, // Set background to transparent to show gradient
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16), // Rounded corners for the button
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 15, vertical: 15), // Adjust padding to change size
          elevation: 0, // Remove default elevation
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text, // Text to display on the button
            style: TextStyle(
              color: textColor, // Text color
              fontSize: 20, // Initial font size
            ),
          ),
        ),
      ),
    );
  }
}

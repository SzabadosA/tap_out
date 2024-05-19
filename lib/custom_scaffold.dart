import 'package:flutter/material.dart';

// Custom scaffold widget that includes a gradient background
class CustomScaffold extends StatelessWidget {
  // Properties for appBar title, actions, body, floatingActionButton, and gradient colors
  final Widget? appBarTitle;
  final List<Widget>? actions;
  final Widget? body;
  final Widget? floatingActionButton;
  final List<Color> gradientColors;

  // Constructor for your custom scaffold
  const CustomScaffold({
    super.key,
    this.appBarTitle, // Title widget for the app bar
    this.actions, // List of action widgets for the app bar
    this.body, // Main content widget for the scaffold's body
    this.floatingActionButton, // Floating action button widget
    required this.gradientColors, // List of colors for the background gradient
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle, // Set the app bar title
        actions: actions, // Set the app bar actions
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors, // Set the background gradient colors
          ),
        ),
        child: body, // Set the scaffold's body content
      ),
      floatingActionButton:
          floatingActionButton, // Set the floating action button
    );
  }
}

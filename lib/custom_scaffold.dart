import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget? appBarTitle;
  final List<Widget>? actions;
  final Widget? body;
  final Widget? floatingActionButton;
  final List<Color> gradientColors;

  const CustomScaffold({super.key, 
    this.appBarTitle,
    this.actions,
    this.body,
    this.floatingActionButton,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        actions: actions,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

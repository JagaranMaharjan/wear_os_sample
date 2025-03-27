import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  final String responseValue;

  const LandingScreen({
    super.key,
    required this.responseValue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Landing Screen'),
      ),
      body: Center(
        child: Text(responseValue),
      ),
    );
  }
}

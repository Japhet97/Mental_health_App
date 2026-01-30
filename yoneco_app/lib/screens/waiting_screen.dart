import 'package:flutter/material.dart';

class WaitingScreen extends StatelessWidget {
  final String roomId;
  final String name;
  final String issue;

  const WaitingScreen({
    super.key,
    required this.roomId,
    required this.name,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for Counsellor'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 30),
              Text(
                'Connecting you with a counsellor for issue: $issue...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please wait while we find an available counsellor.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // You might want to add a cancel button here
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pop(context); // Go back to previous screen
              //   },
              //   child: const Text('Cancel'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
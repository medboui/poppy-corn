// ignore_for_file: file_names

import 'package:flutter/material.dart';

class LoadingModal extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onDismiss;

  const LoadingModal({super.key, required this.isLoading, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Stack(
      children: [
        Opacity(
          opacity: 0.6,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.black,
          ),
        ),
        Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    )
        : const SizedBox.shrink();
  }
}

void main() {
  runApp(const MaterialApp(
    home: LoadingModalDemo(),
  ));
}

class LoadingModalDemo extends StatefulWidget {
  const LoadingModalDemo({super.key});

  @override
  _LoadingModalDemoState createState() => _LoadingModalDemoState();
}

class _LoadingModalDemoState extends State<LoadingModalDemo> {
  bool _isLoading = false;

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });

    // Simulate some async operation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Modal Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your Content Goes Here"),
            ElevatedButton(
              onPressed: _showLoading,
              child: const Text("Show Loading Modal"),
            ),
          ],
        ),
      ),
    );
  }
}

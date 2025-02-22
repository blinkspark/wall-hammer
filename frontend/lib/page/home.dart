import 'dart:async';

import 'package:dart_nats/dart_nats.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String downloadUrl = '';
  Future<Message<dynamic>>? response;
  Set<int> selected = {};
  Map<String, dynamic>? data;
  Stream<double>? progressStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [],
      ),
      body: Center(
        child: Column(
          spacing: 40,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(child: Text('Home')),
          ],
        ),
      ),
    );
  }
}

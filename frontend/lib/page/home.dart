import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
        actions: [],
        // backgroundColor: theme.colorScheme.primary,
        // foregroundColor: theme.colorScheme.onPrimary,
      ),
      drawer: const Drawer(
        child: Center(child: Text("Drawer")),
      ),
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Page'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../app_data.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: LoginForm(colorScheme: colorScheme),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool isRegister = false;
  String username = '';
  String password = '';
  String confirmPassword = '';
  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController(text: username);
    final passwordController = TextEditingController(text: password);
    final appData = context.read<AppData>();
    return Form(
      child: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 10),
        child: Column(
          spacing: 20,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: '用户名'),
              onChanged: (v) {
                username = v;
              },
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '密码'),
              onChanged: (v) {
                password = v;
              },
              obscureText: true,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '确认密码'),
              onChanged: (v) {
                confirmPassword = v;
              },
              obscureText: true,
              enabled: isRegister,
            ),
            SwitchListTile(
              value: isRegister,
              onChanged: (v) {
                setState(() {
                  isRegister = v;
                });
              },
              title: const Text('注册'),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              width: 180,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorScheme.tertiary,
                    foregroundColor: widget.colorScheme.onTertiary),
                onPressed: () {
                  setState(() {
                    username = 'admin';
                    password = 'admin';
                  });
                },
                child: const Text('调试'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              width: 180,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorScheme.primary,
                    foregroundColor: widget.colorScheme.onPrimary),
                onPressed: () {
                  appData.accessToken = 'test';
                  appData.username = username == '' ? 'admin' : username;
                  Navigator.pop(context);
                },
                child: const Text('提交'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

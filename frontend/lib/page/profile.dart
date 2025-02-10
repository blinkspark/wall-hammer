import 'package:flutter/material.dart';
import '../app_data.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final appData = context.read<AppData>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        // backgroundColor: theme.colorScheme.primary,
        // foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        children: [
          Consumer(builder: (context, AppData appData, child) {
            return ListTile(
              leading: Icon(Icons.person),
              title: Text('用户'),
              subtitle: appData.username == '' ? null : Text(appData.username),
              onTap: () {
                // Navigate to login page
                Navigator.pushNamed(context, '/login');
              },
            );
          }),
          Consumer<AppData>(builder: (context, appData, child) {
            return appData.accessToken == ''
                ? SizedBox()
                : Container(
                    padding: const EdgeInsets.only(top: 20),
                    width: 200,
                    child: ElevatedButton(
                        onPressed: () {
                          appData.logout();
                          // Navigator.pushNamed(context, '/login');
                        },
                        child: const Text("退出登录")),
                  );
          })
        ],
      ),
    );
  }
}

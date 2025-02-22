import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../data/app_data.dart';
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
          UserTile(),
          DownloadPathTile(),
          CachePathTile(),
          LogoutButton(),
        ],
      ),
    );
  }
}

class CachePathTile extends StatelessWidget {
  const CachePathTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('缓存路径'),
      subtitle: appData.cachePath == '' ? null : Text(appData.cachePath),
      onTap: () async {
        final path = await FilePicker.platform.getDirectoryPath();
        if (path != null) {
          appData.cachePath = path;
        }
      },
    );
  }
}

class DownloadPathTile extends StatelessWidget {
  const DownloadPathTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    // final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('下载路径'),
      subtitle: appData.downloadPath == '' ? null : Text(appData.downloadPath),
      onTap: () async {
        final path = await FilePicker.platform.getDirectoryPath();
        if (path != null) {
          appData.downloadPath = path;
        }
      },
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return ListTile(
      leading: Icon(Icons.person),
      title: Text('用户'),
      subtitle: appData.username == '' ? null : Text(appData.username),
      onTap: () {
        // Navigate to login page
        Navigator.pushNamed(context, '/login');
      },
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
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
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  String currentFolderPath = '';
  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    final logger = getIt.get<Logger>();
    final currentFolder = Directory(currentFolderPath);
    List<FileSystemEntity> allFiles = [];
    // final colorTheme = Theme.of(context).colorScheme;
    bool hasError = false;
    try {
      final entities = currentFolder.listSync();
      final dirs = entities.whereType<Directory>().toList();
      final files = entities.whereType<File>().toList();
      // join dirs and files
      allFiles = [...dirs, ...files];
    } on Exception catch (e) {
      logger.e(e);
      hasError = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Tooltip(
            message: currentFolder.absolute.path, child: Text(currentFolder.absolute.path)),
        actions: [
          IconButton(
              onPressed: () {
                final parentFolderPath = currentFolder.absolute.parent.path;
                setState(() {
                  currentFolderPath = parentFolderPath;
                });
              },
              icon: const Icon(Icons.arrow_upward)),
          IconButton(
              onPressed: () {
                logger.d('refresh');
                setState(() {
                  currentFolderPath = currentFolderPath;
                });
              },
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () {
                logger.d('add');
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                FilePicker.platform
                    .getDirectoryPath(initialDirectory: currentFolderPath)
                    .then((v) {
                  logger.d(v);
                  if (v != null) {
                    setState(() {
                      currentFolderPath = v == '.' ? '' : v;
                    });
                  }
                });
              },
              icon: const Icon(Icons.folder_open)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: hasError
            ? Center(child: Text("无法访问当前文件夹。"))
            : ListView.builder(
                itemCount: allFiles.length,
                itemBuilder: (context, index) {
                  final f = allFiles[index];
                  final fpath = relative(f.path, from: currentFolderPath);
                  final isFile = f is File;
                  return ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Checkbox(value: false, onChanged: (v) {}),
                        Icon(isFile
                            ? Icons.insert_drive_file
                            : Icons.folder_outlined)
                      ],
                    ),
                    title: Text(fpath),
                    onTap: () {
                      final f = allFiles[index];
                      if (f is Directory) {
                        setState(() {
                          currentFolderPath = f.path;
                        });
                      }
                    },
                  );
                }),
      ),
    );
  }
}

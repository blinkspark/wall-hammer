import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app_data.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  String currentFolder = '';
  @override
  Widget build(BuildContext context) {
    final folder = Directory(currentFolder);
    final entities = folder.listSync();
    final dirs = entities.whereType<Directory>().toList();
    final files = entities.whereType<File>().toList();
    // join dirs and files
    final allFiles = [...dirs, ...files];
    // logger.d(files);

    return Scaffold(
      appBar: AppBar(
        title: Tooltip(
            message: folder.absolute.path, child: Text(folder.absolute.path)),
        actions: [
          IconButton(
              onPressed: () {
                final parentFolder = folder.parent;
                setState(() {
                  currentFolder = parentFolder.path;
                });
              },
              icon: const Icon(Icons.arrow_upward)),
          IconButton(
              onPressed: () {
                logger.d('refresh');
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
                    .getDirectoryPath(initialDirectory: currentFolder)
                    .then((v) {
                  logger.d(v);
                  if (v != null) {
                    setState(() {
                      currentFolder = v;
                    });
                  }
                });
              },
              icon: const Icon(Icons.folder_open)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: ListView.builder(
            itemCount: allFiles.length,
            itemBuilder: (context, index) {
              final f = allFiles[index];
              bool isFile = f is File;
              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Checkbox(value: false, onChanged: (v) {}),
                    isFile
                        ? const Icon(Icons.insert_drive_file)
                        : const Icon(Icons.folder_outlined),
                  ],
                ),
                title: Text(f.path),
                onTap: () {
                  final f = allFiles[index];
                  if (f is Directory) {
                    setState(() {
                      currentFolder = f.path;
                    });
                  }
                },
              );
            }),
      ),
    );
  }
}

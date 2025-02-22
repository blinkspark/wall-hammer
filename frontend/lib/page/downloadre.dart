import 'package:flutter/material.dart';
import 'package:frontend/data/download_data.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                DownloadUrlTextField(),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: '格式选择'),
                        Tab(text: '下载任务'),
                      ],
                    ),
                    Expanded(
                        child: TabBarView(children: [
                      FormatsListView(),
                      const Text('Tab 2'),
                    ])),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class DownloadUrlTextField extends StatelessWidget {
  const DownloadUrlTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // final getIt = GetIt.instance;
    final downData = context.read<DownloadData>();
    final controller = TextEditingController(text: downData.downloadUrl);
    return TextField(
      controller: controller,
      onChanged: (value) => downData.downloadUrl = value,
      decoration: InputDecoration(
        labelText: '视频链接',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                controller.clear();
              },
            ),
            UrlAnalyzeButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

class UrlAnalyzeButton extends StatelessWidget {
  const UrlAnalyzeButton({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final downloadData = context.read<DownloadData>();
    final downloadUrl =
        context.select<DownloadData, String>((d) => d.downloadUrl);
    return IconButton(
      icon: Icon(Icons.search),
      disabledColor: Colors.grey,
      onPressed: downloadUrl.isEmpty
          ? null
          : () {
              downloadData.analyzeUrl(context, controller);
            },
    );
  }
}

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected =
        context.select<DownloadData, List<int>>((d) => d.selectedFormatIndex);
    final aStatus =
        context.select<DownloadData, ConnectionState>((d) => d.analyzeStatus);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary),
      onPressed: selected.isNotEmpty || aStatus == ConnectionState.waiting
          ? () async {
              final downData = context.read<DownloadData>();
              final result = await downData.downloadAction(context);
              if (!result) {
                return;
              }
              DefaultTabController.of(context).animateTo(1);
            }
          : null,
      child: aStatus == ConnectionState.waiting
          ? CircularProgressIndicator()
          : Text('下载'),
    );
  }
}

class FormatsListView extends StatelessWidget {
  const FormatsListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final downloadData = context.watch<DownloadData>();
    final getIt = GetIt.instance;
    final logger = getIt.get<Logger>();
    final analyzeStatus =
        context.select<DownloadData, ConnectionState>((d) => d.analyzeStatus);
    final selectedIndex = downloadData.selectedFormatIndex;
    logger.d(analyzeStatus);
    return Column(
      children: [
        Expanded(
          child: Builder(builder: (context) {
            if (analyzeStatus == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (analyzeStatus == ConnectionState.done) {
              if (downloadData.analyzeErrorMessage != null) {
                return Center(
                  child: Text(downloadData.analyzeErrorMessage!),
                );
              } else {
                logger.d(downloadData.listTileMessages);
                return ListView.builder(
                  itemCount: downloadData.listTileMessages.length,
                  itemBuilder: (context, index) {
                    return downloadData.listTileMessages[index].isDivider
                        ? Divider()
                        : ListTile(
                            title: Text(
                                downloadData.listTileMessages[index].title!),
                            subtitle: Text(
                                downloadData.listTileMessages[index].subtitle ??
                                    ""),
                            onTap: downloadData
                                        .listTileMessages[index].formatInfo ==
                                    null
                                ? null
                                : () {
                                    downloadData.toggleSelected(index);
                                  },
                            leading: downloadData
                                        .listTileMessages[index].formatInfo ==
                                    null
                                ? null
                                : Checkbox(
                                    value: selectedIndex.contains(index),
                                    onChanged: (v) {
                                      downloadData.toggleSelected(index);
                                    },
                                  ),
                          );
                  },
                );
              }
            }
            return Container();
          }),
        ),
        Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            child: DownloadButton())
      ],
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:dart_nats/dart_nats.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/download_data.dart';
import '../data/app_data.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  Future<Message<dynamic>>? response;
  Set<int> selected = {};
  Map<String, dynamic>? data;
  Stream<double>? progressStream;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.I;
    final logger = getIt.get<Logger>();
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [],
      ),
      body: Center(
        child: Column(
          spacing: 40,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [
                  UrlTextInput(),
                  Row(spacing: 20, children: [
                    Expanded(
                        child: buildAnalysisButton(colorScheme, getIt, logger)),
                    Expanded(
                        child: buildDownloadButton(
                            context, colorScheme, logger, getIt)),
                  ])
                ],
              ),
            ),
            formatsListFutureBuilder(),
            DownloadStreamBuilder(
              progressStream: progressStream,
              logger: logger,
            )
          ],
        ),
      ),
    );
  }

  FutureBuilder<Message<dynamic>> formatsListFutureBuilder() {
    return FutureBuilder<Message<dynamic>>(
      future: response,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
              child: Center(child: const CircularProgressIndicator()));
        } else if (snapshot.connectionState == ConnectionState.none) {
          return const SizedBox();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final rawData = utf8.decode(snapshot.data!.data);
            final jdata = jsonDecode(rawData);
            if (jdata['ok'] == true) {
              final formatData = jdata['data'];
              data = formatData;
              final List<dynamic>? formats = jdata['data']['formats'];
              final String? formatIds = formatData['format_id'];
              setSelectionFromFormatsIds(formatIds, formats);
              return Expanded(
                child: formatsListBuilder(formats),
              );
            } else {
              return Text("error: ${jdata['error']}");
            }
          } else if (snapshot.hasError) {
            return Text("error: ${snapshot.error}");
          }
        }
        return Text("others");
      },
    );
  }

  void setSelectionFromFormatsIds(String? formatIds, List<dynamic>? formats) {
    if (formatIds != null && formats != null) {
      formatIds.split('+').forEach((fid) {
        formats.asMap().entries.forEach((f) {
          if (f.value['format_id'] == fid) {
            selected.add(f.key);
          }
        });
      });
    }
  }

  ListView formatsListBuilder(List<dynamic>? formats) {
    return ListView.builder(
      itemCount: formats?.length ?? 0,
      itemBuilder: (ctx, index) {
        final item = formats![index];
        return ListTile(
          onTap: () {
            toggleItem(index);
          },
          leading: Checkbox(
              value: selected.contains(index),
              onChanged: (v) {
                toggleItem(index);
              }),
          title:
              Text('${item["format_id"]} - ${item["format"]} - ${item["ext"]}'),
          subtitle: Text('$item'),
        );
      },
    );
  }

  ElevatedButton buildDownloadButton(BuildContext context,
      ColorScheme colorScheme, Logger logger, GetIt getIt) {
    final downData = context.watch<DownloadData>();
    final appData = context.read<AppData>();
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary),
      onPressed: downData.downloadUrl.isNotEmpty
          ? () async {
              logger.t('download pressed');
              final nc = await getIt.getAsync<Client>();
              if (data != null || downData.downloadUrl.isNotEmpty) {
                logger.d('data is not null');
                final downloadUrlArg =
                    data!['original_url'] ?? downData.downloadUrl;
                final List<String> formatIds = getFormatsIds();
                final id = data?['id'] ?? downData.downloadUrl;
                final formatId =
                    formatIds.length >= 2 ? formatIds.join('+') : null;
                final jsonData = jsonEncode({
                  'id': id,
                  'url': downloadUrlArg,
                  'format_id': formatId,
                  'download_path': appData.downloadPath,
                  'cache_path': appData.cachePath,
                });
                logger.d('data: $jsonData');

                setState(() {
                  progressStream = downloadStream(nc, id, jsonData, logger);
                });
              }
            }
          : null,
      child: const Text('下载'),
    );
  }

  Stream<double> downloadStream(
          Client nc, id, String jsonData, Logger logger) =>
      () async* {
        final sub = nc.sub('neal.service.viddown.task_progress.$id');
        nc.pub(
          'neal.service.viddown.download',
          utf8.encode(jsonData),
        );
        // sub.stream.listen((d) {
        //   final rawData = d.data;
        //   final jdata = jsonDecode(utf8.decode(rawData));
        //   logger.e('listened jdata: $jdata');
        //   // yield jdata['progress'];
        // });
        await for (var d in sub.stream) {
          final rawData = d.data;
          final jdata = jsonDecode(utf8.decode(rawData));
          logger.d('listened jdata: $jdata');
          yield jdata['progress'] as double;
          await Future.delayed(const Duration(seconds: 1));
          if (jdata['progress'] >= 1.0) {
            logger.d('progress is done');
            sub.close();
            break;
          }
        }
      }();

  ElevatedButton buildAnalysisButton(
      ColorScheme colorScheme, GetIt getIt, Logger logger) {
    final downData = context.read<DownloadData>();
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary),
      onPressed: () async {
        selected.clear();
        final nc = await getIt.getAsync<Client>();
        final data = jsonEncode({'url': downData.downloadUrl});
        logger.d(data);
        if (response != null) {
          setState(() {
            response = null;
          });
        }
        setState(() {
          if (response != null) {
            logger.d('null');
            response = null;
          } else {
            response = nc.request(
                'neal.service.viddown.extract_info', utf8.encode(data),
                timeout: Duration(seconds: 10));
          }
        });
      },
      child: const Text('分析'),
    );
  }

  void toggleItem(int index) {
    setState(() {
      if (selected.contains(index)) {
        selected.remove(index);
      } else {
        selected.add(index);
      }
    });
  }

  List<String> getFormatsIds() {
    if (data == null) {
      return [];
    } else {
      final formats = data!['formats'];
      return selected.map((i) => formats[i]['format_id'] as String).toList();
    }
  }
}

class DownloadStreamBuilder extends StatelessWidget {
  const DownloadStreamBuilder({
    super.key,
    required this.progressStream,
    required this.logger,
  });

  final Stream<double>? progressStream;
  final Logger logger;

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder(
        stream: progressStream,
        builder: (context, snapshot) {
          logger.d('snapshot: $snapshot');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return LinearProgressIndicator(value: snapshot.data!);
            }
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return LinearProgressIndicator(
                  value: snapshot.data!, color: Colors.green);
            } else if (snapshot.hasError) {
              return LinearProgressIndicator(
                value: 1,
                color: Colors.red,
              );
            }
          } else if (snapshot.hasError) {
            logger.d('error: ${snapshot.error}');
            return Text(snapshot.error.toString());
          }
          return const SizedBox();
        });
  }
}

class UrlTextInput extends StatefulWidget {
  const UrlTextInput({
    super.key,
  });

  @override
  State<UrlTextInput> createState() => _UrlTextInputState();
}

class _UrlTextInputState extends State<UrlTextInput> {
  @override
  Widget build(BuildContext context) {
    final downData = context.read<DownloadData>();
    final TextEditingController controller =
        TextEditingController(text: downData.downloadUrl);
    return TextField(
      autofocus: true,
      controller: controller,
      showCursor: true,
      onEditingComplete: () {
        downData.downloadUrl = controller.text;
      },
      decoration: InputDecoration(
          labelText: 'Download Url',
          suffixIcon: IconButton(
              onPressed: () {
                controller.clear();
                downData.downloadUrl = '';
                downData.downloadUrl = '';
              },
              icon: Icon(Icons.clear))),
    );
  }
}

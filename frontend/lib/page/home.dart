import 'dart:convert';

import 'package:dart_nats/dart_nats.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

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

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.I;
    final logger = getIt.get<Logger>();
    final colorScheme = Theme.of(context).colorScheme;
    final downloadUrlTextInputController =
        TextEditingController(text: downloadUrl);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            spacing: 40,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: UrlTextInput(
                        controller: downloadUrlTextInputController),
                  ),
                  SizedBox(
                    width: 100,
                    child: buildAnalysisButton(colorScheme, getIt,
                        downloadUrlTextInputController, logger),
                  ),
                  SizedBox(
                    width: 100,
                    child: buildDownloadButton(colorScheme, logger, getIt),
                  ),
                ],
              ),
              formatsListFutureBuilder()
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<Message<dynamic>> formatsListFutureBuilder() {
    return FutureBuilder<Message<dynamic>>(
      future: response,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.none) {
          return Text("none");
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

  ElevatedButton buildDownloadButton(
      ColorScheme colorScheme, Logger logger, GetIt getIt) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary),
      onPressed: () async {
        logger.t('download pressed');
        final nc = await getIt.getAsync<Client>();
        if (data != null) {
          logger.d('data is not null');
          final downloadUrl = data!['original_url'];
          final List<String> formatIds = getFormatsIds();
          if (formatIds.length >= 2) {
            final formatId = formatIds.join('+');
            final data = jsonEncode({
              'url': downloadUrl,
              'format_id': formatId,
            });
            logger.d('data: $data');
            final response = await nc.request(
              'neal.service.viddown.download',
              utf8.encode(data),
            );
            logger.d('response: $response');
          }
        } else {
          logger.d('data is null');
          // TODO: show error
        }
      },
      child: const Text('下载'),
    );
  }

  ElevatedButton buildAnalysisButton(ColorScheme colorScheme, GetIt getIt,
      TextEditingController controller, Logger logger) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary),
      onPressed: () async {
        selected.clear();
        final nc = await getIt.getAsync<Client>();
        downloadUrl = controller.text;
        final data = jsonEncode({'url': downloadUrl});
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

class UrlTextInput extends StatelessWidget {
  const UrlTextInput({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: 'Download Url',
          suffixIcon: IconButton(
              onPressed: () {
                controller.clear();
              },
              icon: Icon(Icons.clear))),
    );
  }
}

import 'dart:convert';

import 'package:dart_nats/dart_nats.dart';
import 'package:flutter/material.dart';
import 'package:frontend/consts.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/v4.dart';

class DownloadData extends ChangeNotifier {
  static const downloadTaskKey = 'downloadTasks';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  DownloadData() {
    init();
  }

  Future<void> init() async {
    final downloadDataStrings = await _prefs.getStringList('downloadDatas');
    final lst = downloadDataStrings
        ?.map((data) => DownloadTaskInfo.fromString(data))
        .whereType<DownloadTaskInfo>()
        .toList();
    downloadTasks = lst ?? [];
  }

  Future<void> analyzeUrl(
      BuildContext context, TextEditingController controller) async {
    final getIt = GetIt.I;
    final logger = getIt.get<Logger>();
    if (analyzeStatus == ConnectionState.waiting) {
      logger.d('analyzeUrl: analyzeStatus is waiting');
      return;
    }
    try {
      final nc = await getIt.getAsync<Client>();
      downloadUrl = controller.text;
      final data = jsonEncode({'url': downloadUrl});
      logger.d(data);
      analyzeStatus = ConnectionState.waiting;
      final response = await nc.request(
          extractVideoInfoService, utf8.encode(data),
          timeout: Duration(seconds: 10));
      final responseData = jsonDecode(utf8.decode(response.data));
      if (responseData['ok'] == false) {
        analyzeErrorMessage = responseData['error'];
        analyzeStatus = ConnectionState.done;
        return;
      }
      final List<FormatListTileMessage> msgs = [];
      msgs.add(FormatListTileMessage(
          title: '视频标题', subtitle: responseData['data']['title']));
      logger.d(responseData);
      msgs.add(FormatListTileMessage(
          title: '上传者', subtitle: responseData['data']['uploader']));
      msgs.add(FormatListTileMessage(isDivider: true));
      for (final f in responseData['data']['formats']) {
        final info = FormatInfo(
          id: f['format_id'],
          name: f['format'],
          ext: f['ext'],
          vcodec: f['vcodec'] ?? 'none',
          acodec: f['acodec'] ?? 'none',
          size: f['filesize_approx'],
          fps: f['fps'],
        );
        msgs.add(FormatListTileMessage(
            title: '${info.id} - ${info.name} - ${info.ext}',
            subtitle:
                '视频编码：${info.vcodec}， 音频编码：${info.acodec}， 大小：${bytesToMB(info.size, 2) ?? 'null'} MB， 帧率：${info.fps ?? 'null'}',
            formatInfo: info));
      }
      listTileMessages = msgs;

      // select default format
      final String format = responseData['data']['format_id'];
      final List<String> formats = format.split('+');
      final List<int> selected = [];
      for (final msg in listTileMessages.asMap().entries) {
        final id = msg.value.formatInfo?.id;
        if (formats.contains(id)) {
          selected.add(msg.key);
        }
      }
      selectedFormatIndex = selected;

      analyzeErrorMessage = null;
      analyzeStatus = ConnectionState.done;
    } on Exception catch (e) {
      logger.e(e.toString());
      analyzeStatus = ConnectionState.done;
      analyzeErrorMessage = e.toString();
    }
  }

  String? bytesToMB(int? bytes, int digit) {
    if (bytes == null) {
      return null;
    }
    GetIt.I.get<Logger>().d('original bytes: $bytes, digit: $digit');
    return (bytes / 1024 / 1024).toStringAsFixed(digit);
  }

  List<int> _selectedFormatIndex = [];
  List<int> get selectedFormatIndex => _selectedFormatIndex;
  set selectedFormatIndex(List<int> value) {
    _selectedFormatIndex = value;
    final logger = GetIt.I.get<Logger>();
    logger.d(value);
    notifyListeners();
  }

  ConnectionState _analyzeStatus = ConnectionState.none;
  ConnectionState get analyzeStatus => _analyzeStatus;
  set analyzeStatus(ConnectionState value) {
    _analyzeStatus = value;
    notifyListeners();
  }

  String? _analyzeErrorMessage = '';
  String? get analyzeErrorMessage => _analyzeErrorMessage;
  set analyzeErrorMessage(String? value) {
    _analyzeErrorMessage = value;
    notifyListeners();
  }

  List<FormatListTileMessage> _listTileMessages = [];
  List<FormatListTileMessage> get listTileMessages => _listTileMessages;
  set listTileMessages(List<FormatListTileMessage> value) {
    _listTileMessages = value;
    notifyListeners();
  }

  String _downloadUrl = '';
  String get downloadUrl => _downloadUrl;
  set downloadUrl(String value) {
    _downloadUrl = value;
    notifyListeners();
  }

  Future<bool> downloadAction(BuildContext context) async {
    if (selectedFormatIndex.isEmpty) {
      return false;
    }
    downloadStatus = ConnectionState.waiting;
    final logger = GetIt.I.get<Logger>();
    final ids = selectedFormatIndex
        .map((e) => listTileMessages[e].formatInfo?.id)
        .toList();
    // remove null
    ids.removeWhere((element) => element == null);
    final formatIds = ids.length > 1 ? ids.join('+') : ids[0];
    final taskId = UuidV4().generate();
    try {
      final data = jsonEncode(
          {'id': taskId, 'url': downloadUrl, 'format_id': formatIds});
      logger.d(data);
      final result = await addDownloadTask(taskId, downloadUrl);
      if (result) return false;
      final nc = await GetIt.I.getAsync<Client>();
      // nc.sub();
      final response = await nc.request(downloadService, utf8.encode(data),
          timeout: Duration(seconds: 10));
      final responseData = jsonDecode(utf8.decode(response.data));
      logger.d(responseData);
    } on Exception catch (e) {
      logger.e(e.toString());
      downloadErrorMessage = e.toString();
      return false;
    }
    downloadStatus = ConnectionState.done;
    return true;
  }

  ConnectionState _downloadStatus = ConnectionState.none;
  ConnectionState get downloadStatus => _downloadStatus;
  set downloadStatus(ConnectionState value) {
    _downloadStatus = value;
    notifyListeners();
  }

  String? _downloadErrorMessage = '';
  String? get downloadErrorMessage => _downloadErrorMessage;
  set downloadErrorMessage(String? value) {
    _downloadErrorMessage = value;
    notifyListeners();
  }

  void toggleSelected(int index) {
    if (selectedFormatIndex.contains(index)) {
      selectedFormatIndex.remove(index);
    } else {
      selectedFormatIndex.add(index);
    }
    notifyListeners();
  }

  List<DownloadTaskInfo> _downloadTasks = [];
  List<DownloadTaskInfo> get downloadTasks => _downloadTasks;
  set downloadTasks(List<DownloadTaskInfo> value) {
    _downloadTasks = value;
    // save to local storage
    saveDownloadTaskList();
    notifyListeners();
  }

  Future<bool> addDownloadTask(String id, String url) async {
    final task = DownloadTaskInfo(url: url);
    if (hasDownloadTask(url)) return false;
    _downloadTasks.add(task);
    saveDownloadTaskList();
    notifyListeners();
    return true;
  }

  bool hasDownloadTask(String url) {
    return _downloadTasks.any((element) => element.url == url);
  }

  void saveDownloadTaskList() async {
    try {
      final strList = _downloadTasks.map((e) => jsonEncode(e)).toList();
      _prefs.setStringList(downloadTaskKey, strList);
    } on Exception catch (e) {
      GetIt.I.get<Logger>().e('save download tasks error: $e');
    }
  }
}

class FormatListTileMessage {
  const FormatListTileMessage({
    this.isDivider = false,
    this.title,
    this.subtitle,
    this.formatInfo,
  });
  final bool isDivider;
  final String? title;
  final String? subtitle;
  final FormatInfo? formatInfo;
}

class FormatInfo {
  FormatInfo({
    required this.id,
    required this.name,
    required this.ext,
    required this.vcodec,
    required this.acodec,
    this.size,
    this.fps,
  });

  final String id;
  final String name;
  final String ext;
  final String vcodec;
  final String acodec;
  final int? size;
  final double? fps;
}

class DownloadTaskInfo {
  String? url;
  String? title;
  String? filePath;
  DownloadTaskInfo({
    this.url,
    this.title,
    this.filePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'filePath': filePath,
    };
  }

  static DownloadTaskInfo? fromString(String data) {
    try {
      final jsonData = jsonDecode(data);
      if (jsonData == null) return null;
      final obj = DownloadTaskInfo(
        title: jsonData['title'],
        url: jsonData['url'],
        filePath: jsonData['filePath'],
      );
      return obj;
    } on Exception catch (e) {
      GetIt.I.get<Logger>().e('DownloadTaskInfo.fromString: $e');
      return null;
    }
  }
}

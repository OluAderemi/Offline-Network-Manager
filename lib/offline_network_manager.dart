import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class OfflineNetworkManager {
  static final OfflineNetworkManager _instance = OfflineNetworkManager._internal();
  factory OfflineNetworkManager({http.Client? client}) {
    _instance._client ??= client ?? http.Client();
    return _instance;
  }

  OfflineNetworkManager._internal();

  late Box _queueBox;
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  http.Client? _client;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _queueBox = await Hive.openBox('offline_requests');

    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;

    _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline && wasOffline) {
        _retryQueuedRequests();
      }
    });
  }

  Future<void> post(String url, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    await _sendOrQueue('POST', url, body, headers);
  }

  Future<void> put(String url, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    await _sendOrQueue('PUT', url, body, headers);
  }

  Future<void> delete(String url, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    await _sendOrQueue('DELETE', url, body, headers);
  }

  Future<void> _sendOrQueue(String method, String url, Map<String, dynamic>? body, Map<String, String>? headers) async {
    if (_isOnline) {
      try {
        await _sendRequest(method, url, body, headers);
      } catch (_) {
        _queueRequest(method, url, body, headers);
      }
    } else {
      _queueRequest(method, url, body, headers);
    }
  }

  void _queueRequest(String method, String url, Map<String, dynamic>? body, Map<String, String>? headers) {
    final request = {
      'method': method,
      'url': url,
      'body': body,
      'headers': headers,
      'attempts': 0,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _queueBox.add(request);
  }

  Future<void> _retryQueuedRequests() async {
    final keys = _queueBox.keys.toList();
    for (var key in keys) {
      final request = Map<String, dynamic>.from(_queueBox.get(key));
      int attempts = request['attempts'] ?? 0;
      if (attempts >= 5) {
        _queueBox.delete(key);
        continue;
      }

      try {
        await _sendRequest(
          request['method'],
          request['url'],
          request['body'],
          Map<String, String>.from(request['headers'] ?? {}),
        );
        _queueBox.delete(key);
      } catch (_) {
        request['attempts'] = attempts + 1;
        _queueBox.put(key, request);
        await Future.delayed(Duration(seconds: 2 * (attempts + 1)));
      }
    }
  }

  Future<void> _sendRequest(String method, String url, Map<String, dynamic>? body, Map<String, String>? headers) async {
    final uri = Uri.parse(url);
    final commonHeaders = {"Content-Type": "application/json", ...?headers};

    late http.Response response;

    if (method == 'POST') {
      response = await _client!.post(uri, body: jsonEncode(body), headers: commonHeaders);
    } else if (method == 'PUT') {
      response = await _client!.put(uri, body: jsonEncode(body), headers: commonHeaders);
    } else if (method == 'DELETE') {
      response = await _client!.delete(uri, body: jsonEncode(body), headers: commonHeaders);
    } else {
      throw UnsupportedError("Method $method not supported");
    }



    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP error: ${response.statusCode}');
    }

  }
}

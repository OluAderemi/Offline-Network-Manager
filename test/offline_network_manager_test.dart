import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:offline_network_manager/offline_network_manager.dart';
import 'mocks.mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineNetworkManager', () {
    late OfflineNetworkManager manager;
    late MockClient mockClient;

    setUp(() async {
      mockClient = MockClient();
      manager = OfflineNetworkManager();
      await manager.init();
    });

    test('queues request when offline', () async {
      // Simulate offline state
      await manager.delete("https://example.com/fake");
      final box = await Hive.openBox('offline_requests');
      expect(box.isNotEmpty, true);
    });

    test('retries request when online', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{}', 200));

      await manager.post("https://example.com", body: {"test": "value"});
      final box = await Hive.openBox('offline_requests');
      expect(box.isEmpty, true); // should succeed and not queue
    });
  });
}

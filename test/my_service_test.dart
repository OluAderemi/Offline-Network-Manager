import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../lib/my_service.dart'; // Update this to your actual service location
import 'mocks.mocks.dart';

void main() {
  group('MyService', () {
    late MockClient mockClient;
    late MyService myService;

    setUp(() {
      mockClient = MockClient();
      myService = MyService(client: mockClient); // Inject mock client
    });

    test('returns data if the http call completes successfully', () async {
      final url = Uri.parse('https://example.com/data');

      when(mockClient.get(url)).thenAnswer(
            (_) async => http.Response('{"title": "Test"}', 200),
      );

      final result = await myService.fetchData();

      expect(result, contains('Test'));
    });

    test('throws an exception if the http call completes with an error', () {
      final url = Uri.parse('https://example.com/data');

      when(mockClient.get(url)).thenAnswer(
            (_) async => http.Response('Not Found', 404),
      );

      expect(myService.fetchData(), throwsException);
    });
  });
}

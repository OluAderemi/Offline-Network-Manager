import 'package:http/http.dart' as http;

class MyService {
  final http.Client client;

  MyService({http.Client? client}) : client = client ?? http.Client();

  Future<String> fetchData() async {
    final response = await client.get(Uri.parse('https://example.com/data'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}

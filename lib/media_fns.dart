import 'package:http/http.dart' as http;

gonext(String base) async {
  http.Response response = await http.get(Uri.parse('$base/next'));
  return response.body;
}

goprev(String base) async {
  http.Response response = await http.get(Uri.parse('$base/prev'));
  return response.body;
}

pp(String base) async {
  http.Response response = await http.get(Uri.parse('$base/pp'));
  return response.body;
}

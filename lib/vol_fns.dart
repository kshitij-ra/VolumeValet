import 'package:http/http.dart' as http;

getVolume(String base) async {
  http.Response response = await http.get(Uri.parse('$base/volGet'));
  return (double.parse(response.body) * 100).round();
}

setVolume(String base, int vol) async {
  http.Response response = await http.get(Uri.parse('$base/volSet/$vol'));
  return response.body;
}

muteVolume(String base, int s) async {
  http.Response response = await http.get(Uri.parse('$base/volMute/$s'));
  return response.body;
}

getMute(String base) async {
  bool m;
  http.Response response = await http.get(Uri.parse('$base/getMute'));
  if (response.body == '0') {
    m = false;
  } else {
    m = true;
  }
  return m;
}

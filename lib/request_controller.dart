import 'dart:convert'; //json encode/decode
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestController {
  String path;
  //String server = "http://172.20.10.3:8000/api/";
  String server = "http://192.168.28.11:8000/api/";
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  RequestController({required this.path});
  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  Future<void> postNoToken() async {
    _res = await http.post(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );

    if (_res?.statusCode == 200) {
      _parseResult();
    } else {
      print("HTTP request failed with status code: ${_res?.statusCode}");
    }
  }

  Future<http.Response> post() async {
    var sharedPreferences = await SharedPreferences
        .getInstance(); // Wait for the SharedPreferences instance
    String? token = sharedPreferences.getString("token");
    if (token != null && token.isNotEmpty) {
      // Check if token is not null before calling isNotEmpty
      var header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      _res = await http.post(
        Uri.parse(server + path),
        headers: header,
        body: jsonEncode(_body),
      );

      if (_res!.statusCode == 200) {
        _parseResult();
      } else {
        print("HTTP request failed with status code: ${_res!.statusCode}");
      }

      return _res!; // Return the HTTP response
    } else {
      // Return a Future that completes with a dummy response in case token is null or empty
      return Future.value(http.Response('', 400));
    }
  }

  Future<void> get() async {
    var sharedPreferences = await SharedPreferences
        .getInstance(); // Wait for the SharedPreferences instance
    String? token = sharedPreferences.getString("token");
    if (token!.isNotEmpty) {
      // Check if token is not null before calling isNotEmpty
      print('token - $token');
      var header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      _res = await http.get(
        Uri.parse(server + path),
        headers: header,
      );
      print(_res!.body);
      _parseResult();
    }
  }

  Future<void> put() async {
    var sharedPreferences = await SharedPreferences
        .getInstance(); // Wait for the SharedPreferences instance
    String? token = sharedPreferences.getString("token");
    if (token!.isNotEmpty) {
      // Check if token is not null before calling isNotEmpty
      var header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      _res = await http.put(
        Uri.parse(server + path),
        headers: header,
        body: jsonEncode(_body),
      );
      if (_res?.statusCode == 200) {
        _parseResult();
      } else {
        print("HTTP request failed with status code: ${_res?.statusCode}");
      }
    }
  }

  Future<void> delete() async {
    var sharedPreferences = await SharedPreferences
        .getInstance(); // Wait for the SharedPreferences instance
    String? token = sharedPreferences.getString("token");
    if (token!.isNotEmpty) {
      // Check if token is not null before calling isNotEmpty
      var header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      _res = await http.delete(
        Uri.parse(server + path),
        headers: header,
        body: jsonEncode(_body),
      );

      if (_res?.statusCode == 200) {
        _parseResult();
      } else {
        print("HTTP request failed with status code: ${_res?.statusCode}");
      }
    }
  }

  void _parseResult() {
    // parse result into json structure if possible
    try {
      print("raw response:${_res?.body}");
      _resultData = jsonDecode(_res?.body ?? "");
    } catch (ex) {
      // otherwise the response body will be stored as is
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }

  dynamic result() {
    return _resultData;
  }

  int status() {
    return _res?.statusCode ?? 0;
  }
}

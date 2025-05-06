import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DisasterApiService {
  static const String _apiKey = '9UR9VNA127E8IFG3';
  static const String _baseUrl = 'https://www.safetydata.go.kr/V2/api/DSSP-IF-00247';

  static Future<List<Map<String, dynamic>>> fetchTodayDisasterMessages() async {
    final now = DateTime.now();
    final date = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}';

    final uri = Uri.parse('$_baseUrl'
        '?serviceKey=$_apiKey'
        '&numOfRows=10'
        '&pageNo=1'
        '&returnType=json'
        '&crtDt=$date');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decodedBody = const Utf8Decoder(allowMalformed: true).convert(response.bodyBytes);
      final data = jsonDecode(decodedBody);

      final List<dynamic> items = data['body'] ?? [];

      return items.map((item) {
        DateTime parsedTime;
        try {
          parsedTime = DateFormat('yyyy/MM/dd HH:mm:ss').parse(item['CRT_DT'] ?? '');
        } catch (_) {
          parsedTime = DateTime.now();
        }

        return {
          'sn': item['SN'] ?? 0,
          'msg': item['MSG_CN'] ?? '',
          'timestamp': parsedTime,
        };
      }).toList();
    } else {
      throw Exception('재난문자 API 오류: ${response.statusCode}');
    }
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class DisasterApiService {
  static const String _apiKey = '3THNN6FADIAT498J';
  static const String _baseUrl = 'https://www.safetydata.go.kr/V2/api/DSSP-IF-00247';

  static const String _vworldApiKey = '216C8714-B83F-3003-8FA2-4E15F2020253';
  static const String _vworldBaseUrl =
      'http://api.vworld.kr/req/address?service=address&version=2.0&request=getaddress&format=json&type=both&zipcode=true&simple=false';

  static const String _translatorKey = 'F9a7jxLs7GpOJ7jk9DkXhUD0adwf4Yrc76DEH2unenQoBHWK1LHJJQQJ99BEACNns7RXJ3w3AAAbACOGzDSP';
  static const String _translatorRegion = 'koreacentral';
  static const String _translatorUrl =
      'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=en';

  /// 외부에서 호출: 현재 위치 기반 지역 재난문자 + 번역 포함
  static Future<List<Map<String, dynamic>>> fetchTodayDisasterMessages() async {
  try {
    //  현재 위치 가져오기
    final Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    //  시도(지역명) 가져오기
    final String regionName = await _getRegionName(pos.latitude, pos.longitude);

    //  해당 지역 재난문자 조회
    final List<Map<String, dynamic>> messages = await _fetchByRegion(regionName);

    if (messages.isEmpty) return [];

    //  번역
    final List<Map<String, dynamic>> translated = await _translateMessages(messages);
    return translated;
  } catch (e) {
    print('🚨 재난문자 조회 실패: $e');
    return [];
  }
}


  /// 현재 위치 좌표 → 행정 시도 이름 (예: 서울특별시)
  static Future<String> _getRegionName(double lat, double lon) async {
    final dio = Dio();
    final url = '$_vworldBaseUrl&key=$_vworldApiKey&point=$lon,$lat';
    final res = await dio.get(url);

    if (res.statusCode == 200) {
      final data = res.data;
      final results = data['response']['result'];
      if (results != null && results.isNotEmpty) {
        final structure = results[0]['structure'];
        return structure['level1']; // ex: 서울특별시
      }
    }
    throw Exception('📍 시도 추출 실패');
  }

  /// 시도 이름으로 재난문자 API 조회
  static Future<List<Map<String, dynamic>>> _fetchByRegion(String regionName) async {
    final now = DateTime.now();
    final date = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}';

    final uri = Uri.parse('$_baseUrl'
        '?serviceKey=$_apiKey'
        '&numOfRows=10'
        '&pageNo=1'
        '&returnType=json'
        '&crtDt=$date'
        '&rgnNm=${Uri.encodeComponent(regionName)}');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = const Utf8Decoder(allowMalformed: true).convert(response.bodyBytes);
      final data = jsonDecode(decoded);
      final List<dynamic> items = data['body'] ?? [];

      return items.map<Map<String, dynamic>>((item) {
        DateTime time;
        try {
          time = DateFormat('yyyy/MM/dd HH:mm:ss').parse(item['CRT_DT'] ?? '');
        } catch (_) {
          time = DateTime.now();
        }

        return {
          'sn': item['SN'] ?? 0,
          'msg': item['MSG_CN'] ?? '',
          'timestamp': time,
          'translated': '', // 초기 상태
        };
      }).toList();
    } else {
      throw Exception('❌ 재난문자 API 오류: ${response.statusCode}');
    }
  }

  /// Microsoft Translator API로 번역 수행 (ko → en)
  static Future<List<Map<String, dynamic>>> _translateMessages(List<Map<String, dynamic>> messages) async {
    final dio = Dio();

    // ✅ "Text" 필드는 대문자여야 하며, content-type 명확히
    final payload = messages
        .where((m) => m['msg'] != null && m['msg'].toString().trim().isNotEmpty)
        .map((m) => {"Text": m['msg']}) // 대문자 T
        .toList();

    if (payload.isEmpty) return messages;

    try {
      final response = await dio.post(
        _translatorUrl,
        data: jsonEncode(payload),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Ocp-Apim-Subscription-Key": _translatorKey,
            "Ocp-Apim-Subscription-Region": _translatorRegion,
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        int translatedIdx = 0;
        for (int i = 0; i < messages.length; i++) {
          if (messages[i]['msg'].toString().trim().isNotEmpty && translatedIdx < data.length) {
            messages[i]['translated'] = data[translatedIdx]['translations'][0]['text'];
            translatedIdx++;
          }
        }
      } else {
        print('❌ 번역 실패: status ${response.statusCode}');
        print(response.data);
      }
    } catch (e) {
      print('❌ 번역 예외 발생: $e');
    }

    return messages;
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

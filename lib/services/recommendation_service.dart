import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// RecommendationResult 클래스를 정의하여 추천 문구와 검색 키워드를 함께 반환
class RecommendationResult {
  final String recommendationText;
  final String? searchKeyword; // 지도 검색에 사용할 키워드 (없으면 null)

  RecommendationResult({required this.recommendationText, this.searchKeyword});
}

class RecommendationService {
  RecommendationResult getRecommendation({ // 반환 타입을 RecommendationResult로 변경
    Map<String, dynamic>? weatherData,
    required int batteryLevel,
    required BatteryState batteryState,
    required ConnectivityResult connectivityResult,
  }) {
    String recommendation = "오늘도 즐거운 하루 되세요!";
    String? searchKeyword; // 기본값은 null

    // 1. 날씨 기반 추천
    if (weatherData != null && weatherData.containsKey('weather')) {
      final current = weatherData['weather'];
      final temp = current['main']['temp'] as double;
      final weatherCondition = current['weather'][0]['main'].toString().toLowerCase();

      if (temp < 5) {
        recommendation = "날씨가 많이 춥습니다! 따뜻하게 입고 목도리, 장갑을 챙기세요.";
      } else if (temp > 28) {
        recommendation = "날씨가 매우 덥습니다! 시원한 음료와 함께 야외 활동을 자제하고 실내 활동을 추천합니다.";
      } else if (weatherCondition.contains('rain')) {
        recommendation = "비가 오니 우산을 꼭 챙기고, 실내에서 즐길 수 있는 활동을 찾아보세요.";
      } else if (weatherCondition.contains('snow')) {
        recommendation = "눈이 오니 미끄럼에 주의하시고, 따뜻한 차 한 잔 어떠세요?";
      } else if (weatherCondition.contains('clear')) {
        recommendation = "화창한 날씨입니다! 산책이나 야외 활동을 추천합니다.";
      } else if (weatherCondition.contains('clouds')) {
        recommendation = "흐린 날씨입니다. 가벼운 실내 운동이나 독서를 추천합니다.";
      }
    }

    // 2. 배터리 상태 기반 추천 (날씨 추천과 조합)
    if (batteryState == BatteryState.charging) {
      recommendation += "\n배터리가 충전 중이네요. 충전하면서 영화 한 편 어떠세요?";
    } else if (batteryLevel < 20) {
      recommendation += "\n배터리가 부족합니다! 보조배터리를 챙기거나 전원 연결을 권장합니다.";
      // 배터리가 20% 미만일 때 충전소 검색 키워드 추가
      searchKeyword = "휴대폰 충전소"; // "전기차 충전소" 대신 "휴대폰 충전소"로 변경 (mapScreen의 서브카테고리명과 일치시키기 위해)
    } else if (batteryLevel < 50) {
      recommendation += "\n배터리가 절반 정도 남았네요. 전력 소모가 적은 활동을 추천합니다.";
    }

    // 3. Wi-Fi 상태 기반 추천 (배터리 및 날씨 추천과 조합)
    if (connectivityResult == ConnectivityResult.wifi) {
      recommendation += "\nWi-Fi에 연결되어 있습니다. 데이터 걱정 없이 스트리밍 서비스를 이용해 보세요!";
    } else if (connectivityResult == ConnectivityResult.mobile) {
      recommendation += "\n모바일 데이터 사용 중입니다. 데이터 소모가 많은 활동은 주의하세요.";
    } else if (connectivityResult == ConnectivityResult.none) {
      recommendation += "\n인터넷 연결이 없습니다. 오프라인으로 즐길 수 있는 게임이나 미리 다운로드한 콘텐츠를 추천합니다.";
      // 인터넷 연결이 없을 때 공공 Wi-Fi 검색 키워드 추가
      searchKeyword = "공공 와이파이";
    }

    return RecommendationResult(recommendationText: recommendation, searchKeyword: searchKeyword);
  }
}
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart'; // BuildContext를 위해 추가
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 자동 생성될 경로

// RecommendationResult 클래스를 정의하여 추천 문구와 검색 키워드를 함께 반환
class RecommendationResult {
  final String recommendationText;
  final String? searchKeyword; // 지도 검색에 사용할 키워드 (없으면 null)

  RecommendationResult({required this.recommendationText, this.searchKeyword});
}

class RecommendationService {
  RecommendationResult getRecommendation({
    required BuildContext context, // BuildContext 추가
    Map<String, dynamic>? weatherData,
    required int batteryLevel,
    required BatteryState batteryState,
    required ConnectivityResult connectivityResult,
  }) {
    // AppLocalizations 인스턴스 가져오기
    final l10n = AppLocalizations.of(context)!; //

    String recommendation = l10n.todayEnjoyableDay; //
    String? searchKeyword; // 기본값은 null

    // 1. 날씨 기반 추천
    if (weatherData != null && weatherData.containsKey('weather')) {
      final current = weatherData['weather'];
      final temp = current['main']['temp'] as double;
      final weatherCondition = current['weather'][0]['main'].toString().toLowerCase();

      if (temp < 5) {
        recommendation = l10n.weatherCold; //
      } else if (temp > 28) {
        recommendation = l10n.weatherHot; //
      } else if (weatherCondition.contains('rain')) {
        recommendation = l10n.weatherRain; //
      } else if (weatherCondition.contains('snow')) {
        recommendation = l10n.weatherSnow; //
      } else if (weatherCondition.contains('clear')) {
        recommendation = l10n.weatherClear; //
      } else if (weatherCondition.contains('clouds')) {
        recommendation = l10n.weatherClouds; //
      }
    }

    // 2. 배터리 상태 기반 추천 (날씨 추천과 조합)
    if (batteryState == BatteryState.charging) {
      recommendation += l10n.batteryCharging; //
    } else if (batteryLevel < 20) {
      recommendation += l10n.batteryLow; //
      searchKeyword = l10n.phoneChargingStation; //
    } else if (batteryLevel < 50) {
      recommendation += l10n.batteryHalf; //
    }

    // 3. Wi-Fi 상태 기반 추천 (배터리 및 날씨 추천과 조합)
    if (connectivityResult == ConnectivityResult.wifi) {
      recommendation += l10n.wifiConnected; //
    } else if (connectivityResult == ConnectivityResult.mobile) {
      recommendation += l10n.mobileData; //
    } else if (connectivityResult == ConnectivityResult.none) {
      recommendation += l10n.noInternet; //
      searchKeyword = l10n.publicWifi; //
    }

    return RecommendationResult(recommendationText: recommendation, searchKeyword: searchKeyword);
  }
}
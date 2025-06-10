// lib/widgets/language_selection_widget.dart

import 'package:flutter/material.dart';
import 'package:app_for_traveler/main.dart'; // MyApp에 접근하기 위함
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 번역된 텍스트를 위함

class LanguageSelectionWidget extends StatelessWidget {
  const LanguageSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // AppLocalizations 인스턴스를 가져옵니다.
    // 이 인스턴스를 통해 arb 파일에 정의된 번역된 텍스트에 접근할 수 있습니다.
    final appLocalizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 컬럼의 크기를 내용에 맞게 조절
        children: [
          // 현재 언어의 "Hello, World!" 텍스트를 표시합니다.
          const SizedBox(height: 20),
          // 영어로 변경하는 버튼
          ElevatedButton(
            onPressed: () {
              // MyApp의 setLocale 메서드를 호출하여 언어를 영어로 변경합니다.
              MyApp.of(context)?.setLocale(const Locale('en', 'US'));
            },
            // 버튼 텍스트는 아직 번역되지 않은 고정된 문자열입니다.
            // 필요하다면 이 부분도 appLocalizations를 통해 번역할 수 있습니다.
            child: const Text('Change to English'),
          ),
          const SizedBox(height: 10),
          // 한국어로 변경하는 버튼
          ElevatedButton(
            onPressed: () {
              // MyApp의 setLocale 메서드를 호출하여 언어를 한국어로 변경합니다.
              MyApp.of(context)?.setLocale(const Locale('ko', 'KR'));
            },
            child: const Text('한국어로 변경'),
          ),
        ],
      ),
    );
  }
}
// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ko';

  static String m0(error) => "신청 수락 실패: ${error}";

  static String m1(address) => "주소: ${address}";

  static String m2(error) => "신청 취소 실패: ${error}";

  static String m3(error) => "신청 실패: ${error}";

  static String m4(authorNickname, date) => "작성자: ${authorNickname} (${date})";

  static String m5(rating) => "평균 별점: ${rating}";

  static String m6(error) => "댓글 추가 실패: ${error}";

  static String m7(nickname) => "작성자: ${nickname}";

  static String m8(error) => "댓글 삭제 실패: ${error}";

  static String m9(error) => "댓글 수정 실패: ${error}";

  static String m10(error) => "댓글 로드 실패: ${error}";

  static String m11(error) => "동행 삭제 실패: ${error}";

  static String m12(error) => "동행 로드 실패: ${error}";

  static String m13(scheduleTitle) => "[동행] ${scheduleTitle}";

  static String m14(error) =>
      "데이터 동기화 실패: 네트워크 연결을 확인하거나 나중에 다시 시도해주세요. (에러: ${error})";

  static String m15(error) => "삭제 실패: ${error}";

  static String m16(destination) => "여행지: ${destination}";

  static String m17(error) => "댓글 추가 실패: ${error}";

  static String m18(error) => "장소 추가 실패: ${error}";

  static String m19(error) => "답글 추가 실패: ${error}";

  static String m20(error) => "리뷰 추가 실패: ${error}";

  static String m21(error) => "댓글 삭제 실패: ${error}";

  static String m22(error) => "답글 삭제 실패: ${error}";

  static String m23(error) => "위치 정보를 가져오는 데 실패했습니다: ${error}";

  static String m24(error) => "댓글 로드 실패: ${error}";

  static String m25(error) => "마커 아이콘 로드 실패: ${error}";

  static String m26(error) => "장소 검색 실패: ${error}";

  static String m27(error) => "댓글 수정 실패: ${error}";

  static String m28(error) => "답글 수정 실패: ${error}";

  static String m29(error) => "즐겨찾기 토글 실패: ${error}";

  static String m30(error) => "이미지 업로드 실패: ${error}";

  static String m31(error) => "동행 탈퇴 실패: ${error}";

  static String m32(error) => "불러오기 실패: ${error}";

  static String m33(error) => "현재 위치를 가져오지 못했습니다: ${error}";

  static String m34(error) => "로그인 중 오류: ${error}";

  static String m35(error) => "지도 로드 실패: ${error}";

  static String m36(error) => "지도 검색 실패: ${error}";

  static String m37(subcategory) => "${subcategory} 추가";

  static String m38(keyword) => "\'${keyword}\'에 해당하는 장소를 찾을 수 없습니다.";

  static String m39(query) => "\'${query}\'에 대한 검색 결과가 없습니다.";

  static String m40(userName) => "${userName}님이 수락되었습니다!";

  static String m41(error) => "참여자 목록 로드 실패: ${error}";

  static String m42(error) => "장소 추가 실패: ${error}";

  static String m43(error) => "장소 삭제 실패: ${error}";

  static String m44(error) => "장소 로드 실패: ${error}";

  static String m45(error) => "장소 수정 실패: ${error}";

  static String m46(error) => "게시물 작성 실패: ${error}";

  static String m47(error) => "게시물 로드 실패: ${error}";

  static String m48(rating) => "별점: ${rating}";

  static String m49(error) => "신청 거절 실패: ${error}";

  static String m50(error) => "신청자 목록 로드 실패: ${error}";

  static String m51(error) => "리뷰 추가 실패: ${error}";

  static String m52(error) => "리뷰 로드 실패: ${error}";

  static String m53(error) => "검색 실패: ${error}";

  static String m54(query, placeName) => "\'${query}\'에 대한 결과 표시: ${placeName}";

  static String m55(query) => "\'${query}\' 검색 중...";

  static String m56(error) => "회원가입 오류: ${error}";

  static String m57(error) => "공공 와이파이 로드 실패: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutAppTitle": MessageLookupByLibrary.simpleMessage("앱 정보"),
    "acceptButton": MessageLookupByLibrary.simpleMessage("수락"),
    "acceptRequestFailed": m0,
    "add": MessageLookupByLibrary.simpleMessage("추가"),
    "addButton": MessageLookupByLibrary.simpleMessage("추가"),
    "addComment": MessageLookupByLibrary.simpleMessage("코멘트 추가"),
    "addCommentButton": MessageLookupByLibrary.simpleMessage("댓글 작성"),
    "addNewPlaceTitle": MessageLookupByLibrary.simpleMessage("새 장소 추가"),
    "addPersonalScheduleTooltip": MessageLookupByLibrary.simpleMessage(
      "개인 일정 등록",
    ),
    "addPlace": MessageLookupByLibrary.simpleMessage("장소 추가"),
    "addPlaceButton": MessageLookupByLibrary.simpleMessage("장소 추가"),
    "addPlaceTitle": MessageLookupByLibrary.simpleMessage("새 장소 추가"),
    "addPlaceTooltip": MessageLookupByLibrary.simpleMessage("장소 추가"),
    "addPostTooltip": MessageLookupByLibrary.simpleMessage("새 게시물 추가"),
    "addReviewButton": MessageLookupByLibrary.simpleMessage("리뷰 작성"),
    "addedToFavorites": MessageLookupByLibrary.simpleMessage("즐겨찾기에 추가되었습니다!"),
    "additionalDescriptionLabel": MessageLookupByLibrary.simpleMessage("부가 설명"),
    "additionalDescriptionPrefix": MessageLookupByLibrary.simpleMessage(
      "부가 설명: ",
    ),
    "address": m1,
    "addressLabel": MessageLookupByLibrary.simpleMessage("주소"),
    "addressRequired": MessageLookupByLibrary.simpleMessage(
      "주소 (필수, 예: 대학로 52-1)",
    ),
    "addressSearchFailed": MessageLookupByLibrary.simpleMessage(
      "주소 검색에 실패했습니다.",
    ),
    "ageConditionRange": MessageLookupByLibrary.simpleMessage("범위"),
    "ageHint": MessageLookupByLibrary.simpleMessage("나이"),
    "ageUnlimited": MessageLookupByLibrary.simpleMessage("연령 무관"),
    "allCategories": MessageLookupByLibrary.simpleMessage("모든 카테고리"),
    "anonymous": MessageLookupByLibrary.simpleMessage("익명"),
    "appTitle": MessageLookupByLibrary.simpleMessage("여행자 앱"),
    "applicantsListTitle": MessageLookupByLibrary.simpleMessage("신청자 목록"),
    "applicationCancelError": m2,
    "applicationCancelledSuccess": MessageLookupByLibrary.simpleMessage(
      "신청이 취소되었습니다!",
    ),
    "applicationSendError": m3,
    "applicationSentSuccess": MessageLookupByLibrary.simpleMessage(
      "신청이 완료되었습니다!",
    ),
    "applyForCompanionButton": MessageLookupByLibrary.simpleMessage("동행 신청"),
    "artMuseums": MessageLookupByLibrary.simpleMessage("미술/박물관"),
    "asianFood": MessageLookupByLibrary.simpleMessage("아시아 음식"),
    "atm": MessageLookupByLibrary.simpleMessage("ATM"),
    "atmSyncing": MessageLookupByLibrary.simpleMessage("ATM기 위치 동기화 중..."),
    "attachPhoto": MessageLookupByLibrary.simpleMessage("사진 첨부"),
    "author": MessageLookupByLibrary.simpleMessage("작성자"),
    "authorAndDate": m4,
    "authorLabel": MessageLookupByLibrary.simpleMessage("작성자"),
    "authorPrefix": MessageLookupByLibrary.simpleMessage("작성자: "),
    "averageRating": m5,
    "bank": MessageLookupByLibrary.simpleMessage("은행"),
    "bankSyncing": MessageLookupByLibrary.simpleMessage("은행 위치 동기화 중..."),
    "barsPubs": MessageLookupByLibrary.simpleMessage("바/펍"),
    "batteryCharging": MessageLookupByLibrary.simpleMessage(
      "\n배터리가 충전 중이네요. 충전하면서 영화 한 편 어떠세요?",
    ),
    "batteryHalf": MessageLookupByLibrary.simpleMessage(
      "\n배터리가 절반 정도 남았네요. 전력 소모가 적은 활동을 추천합니다.",
    ),
    "batteryLow": MessageLookupByLibrary.simpleMessage(
      "\n배터리가 부족합니다! 보조배터리를 챙기거나 전원 연결을 권장합니다.",
    ),
    "board": MessageLookupByLibrary.simpleMessage("게시판"),
    "boardTab": MessageLookupByLibrary.simpleMessage("게시판"),
    "boardTitle": MessageLookupByLibrary.simpleMessage("게시판"),
    "bookstores": MessageLookupByLibrary.simpleMessage("서점"),
    "cafe": MessageLookupByLibrary.simpleMessage("카페"),
    "cafeSyncing": MessageLookupByLibrary.simpleMessage("카페 동기화 중..."),
    "cafesDesserts": MessageLookupByLibrary.simpleMessage("카페/디저트"),
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "cancelApplicationButton": MessageLookupByLibrary.simpleMessage("신청 취소"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("취소"),
    "cannotLoadSchedule": MessageLookupByLibrary.simpleMessage(
      "일정을 불러올 수 없습니다.",
    ),
    "categoryAccommodation": MessageLookupByLibrary.simpleMessage("숙박"),
    "categoryEtc": MessageLookupByLibrary.simpleMessage("기타"),
    "categoryLabel": MessageLookupByLibrary.simpleMessage("카테고리"),
    "categoryLandmark": MessageLookupByLibrary.simpleMessage("명소"),
    "categoryRestaurant": MessageLookupByLibrary.simpleMessage("음식점"),
    "categoryTitle": MessageLookupByLibrary.simpleMessage("카테고리 선택"),
    "categoryTransportation": MessageLookupByLibrary.simpleMessage("교통"),
    "cinemas": MessageLookupByLibrary.simpleMessage("영화관"),
    "clearSky": MessageLookupByLibrary.simpleMessage("맑음"),
    "close": MessageLookupByLibrary.simpleMessage("닫기"),
    "closeButton": MessageLookupByLibrary.simpleMessage("닫기"),
    "closedStatus": MessageLookupByLibrary.simpleMessage("마감됨"),
    "clouds": MessageLookupByLibrary.simpleMessage("흐림"),
    "commentAddFailed": m6,
    "commentAddedSuccess": MessageLookupByLibrary.simpleMessage("댓글이 추가되었습니다!"),
    "commentAuthor": m7,
    "commentDeleteFailed": m8,
    "commentDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "댓글이 삭제되었습니다!",
    ),
    "commentEditFailed": m9,
    "commentEditedSuccess": MessageLookupByLibrary.simpleMessage(
      "댓글이 수정되었습니다!",
    ),
    "commentEmptyWarning": MessageLookupByLibrary.simpleMessage(
      "댓글은 비워둘 수 없습니다.",
    ),
    "commentInputHint": MessageLookupByLibrary.simpleMessage("댓글을 입력하세요..."),
    "commentUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "댓글이 성공적으로 수정되었습니다!",
    ),
    "comments": MessageLookupByLibrary.simpleMessage("코멘트:"),
    "commentsLoadError": m10,
    "commentsSectionTitle": MessageLookupByLibrary.simpleMessage("댓글"),
    "commentsTitle": MessageLookupByLibrary.simpleMessage("댓글"),
    "companionApplicationNotPossible": MessageLookupByLibrary.simpleMessage(
      "신청할 수 없습니다 (마감되었거나 정원 초과).",
    ),
    "companionDataNotFound": MessageLookupByLibrary.simpleMessage(
      "동행 데이터를 찾을 수 없습니다.",
    ),
    "companionDeleteFailed": m11,
    "companionDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "동행 게시물이 삭제되었습니다!",
    ),
    "companionDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "예) 조용한 여행 선호해요 / MBTI I이신 분들 환영합니다",
    ),
    "companionLoadError": m12,
    "companionNotFound": MessageLookupByLibrary.simpleMessage("동행을 찾을 수 없습니다."),
    "companionRecruitment": MessageLookupByLibrary.simpleMessage("동행 모집"),
    "companionSchedulePrefix": m13,
    "completeEditButton": MessageLookupByLibrary.simpleMessage("수정 완료"),
    "confirm": MessageLookupByLibrary.simpleMessage("확인"),
    "confirmButton": MessageLookupByLibrary.simpleMessage("확인"),
    "confirmDeleteComment": MessageLookupByLibrary.simpleMessage(
      "정말 이 댓글을 삭제하시겠습니까?",
    ),
    "confirmDeleteCompanion": MessageLookupByLibrary.simpleMessage(
      "정말 이 동행 게시물을 삭제하시겠습니까?",
    ),
    "confirmDeletePlace": MessageLookupByLibrary.simpleMessage(
      "정말 이 장소를 삭제하시겠습니까?",
    ),
    "confirmDeleteReply": MessageLookupByLibrary.simpleMessage(
      "정말 이 답글을 삭제하시겠습니까?",
    ),
    "confirmDeleteSchedule": MessageLookupByLibrary.simpleMessage(
      "정말 이 일정을 삭제하시겠습니까?",
    ),
    "confirmLeaveCompanion": MessageLookupByLibrary.simpleMessage(
      "정말 이 동행 그룹을 탈퇴하시겠습니까?",
    ),
    "confirmPasswordHint": MessageLookupByLibrary.simpleMessage("비밀번호 확인"),
    "contactHint": MessageLookupByLibrary.simpleMessage("연락처 (카카오톡ID 또는 이메일)"),
    "contentLabel": MessageLookupByLibrary.simpleMessage("내용"),
    "createAccountButton": MessageLookupByLibrary.simpleMessage("회원가입하기"),
    "createPostTitle": MessageLookupByLibrary.simpleMessage("새 게시물 작성"),
    "createPostTooltip": MessageLookupByLibrary.simpleMessage("게시물 작성"),
    "currencyExchange": MessageLookupByLibrary.simpleMessage("환전소"),
    "currencyExchangeSyncing": MessageLookupByLibrary.simpleMessage(
      "환전소 위치 동기화 중...",
    ),
    "currentLocation": MessageLookupByLibrary.simpleMessage("현재 위치"),
    "currentLocationInfo": MessageLookupByLibrary.simpleMessage(
      "현재 위치: 대한민국 경상북도 구미시",
    ),
    "currentParticipants": MessageLookupByLibrary.simpleMessage("참여 인원"),
    "currentWeatherInfo": MessageLookupByLibrary.simpleMessage("현재 날씨 정보"),
    "cyclingPaths": MessageLookupByLibrary.simpleMessage("자전거 도로"),
    "dataSyncComplete": MessageLookupByLibrary.simpleMessage("데이터 동기화 완료"),
    "dataSyncFailed": m14,
    "dataSyncMessage": MessageLookupByLibrary.simpleMessage("데이터 동기화 중..."),
    "dataSyncSkipped": MessageLookupByLibrary.simpleMessage(
      "데이터 동기화 건너뜀. 기존 데이터를 로드합니다.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("삭제"),
    "deleteAccountButton": MessageLookupByLibrary.simpleMessage("계정 삭제"),
    "deleteButton": MessageLookupByLibrary.simpleMessage("삭제"),
    "deleteCommentTitle": MessageLookupByLibrary.simpleMessage("댓글 삭제"),
    "deleteCompanionTitle": MessageLookupByLibrary.simpleMessage("동행 삭제"),
    "deleteFailed": m15,
    "deletePlaceTitle": MessageLookupByLibrary.simpleMessage("장소 삭제"),
    "deleteReplyTitle": MessageLookupByLibrary.simpleMessage("답글 삭제"),
    "deleteReview": MessageLookupByLibrary.simpleMessage("리뷰 삭제"),
    "deleteReviewConfirm": MessageLookupByLibrary.simpleMessage(
      "이 리뷰를 삭제하시겠습니까?",
    ),
    "deleteScheduleTitle": MessageLookupByLibrary.simpleMessage("일정 삭제"),
    "deletedComment": MessageLookupByLibrary.simpleMessage("삭제된 댓글입니다."),
    "deletedCommentIndicator": MessageLookupByLibrary.simpleMessage(
      "(삭제된 댓글입니다)",
    ),
    "descriptionHint": MessageLookupByLibrary.simpleMessage(
      "예) 친구와의 여유로운 시간 / 박물관 위주 일정",
    ),
    "destinationLabel": MessageLookupByLibrary.simpleMessage("여행지 *"),
    "destinationPrefix": m16,
    "destinationUndecided": MessageLookupByLibrary.simpleMessage("여행지 미정"),
    "disasterAlertTitle": MessageLookupByLibrary.simpleMessage("재난 문자 알림"),
    "disasterAlerts": MessageLookupByLibrary.simpleMessage("재난 알림"),
    "editButton": MessageLookupByLibrary.simpleMessage("수정"),
    "editCommentHint": MessageLookupByLibrary.simpleMessage("댓글을 수정하세요"),
    "editCommentTitle": MessageLookupByLibrary.simpleMessage("댓글 수정"),
    "editCompanionInfo": MessageLookupByLibrary.simpleMessage("동행 정보 수정"),
    "editCompanionInfoTitle": MessageLookupByLibrary.simpleMessage("동행 정보 수정"),
    "editFailed": MessageLookupByLibrary.simpleMessage("수정 실패"),
    "editPlaceTitle": MessageLookupByLibrary.simpleMessage("장소 수정"),
    "editProfileButton": MessageLookupByLibrary.simpleMessage("프로필 수정"),
    "editProfileTitle": MessageLookupByLibrary.simpleMessage("프로필 편집"),
    "editScheduleTitle": MessageLookupByLibrary.simpleMessage("일정 수정"),
    "editTravelInfo": MessageLookupByLibrary.simpleMessage("여행 정보 수정"),
    "emptyCommentWarning": MessageLookupByLibrary.simpleMessage(
      "댓글 내용을 입력해주세요.",
    ),
    "emptyFieldsWarning": MessageLookupByLibrary.simpleMessage(
      "이름과 주소는 비워둘 수 없습니다.",
    ),
    "emptyPostFieldsWarning": MessageLookupByLibrary.simpleMessage(
      "제목과 내용을 입력해주세요.",
    ),
    "encryptedFacilityWarning": MessageLookupByLibrary.simpleMessage(
      "이 시설은 암호화된 시설입니다.",
    ),
    "encryptedLocation": MessageLookupByLibrary.simpleMessage("암호화된 위치"),
    "endDate": MessageLookupByLibrary.simpleMessage("도착일"),
    "enterCommentHint": MessageLookupByLibrary.simpleMessage("댓글을 입력하세요..."),
    "enterCompanionInfo": MessageLookupByLibrary.simpleMessage("동행 정보 입력"),
    "enterDestination": MessageLookupByLibrary.simpleMessage("여행지를 입력하세요"),
    "enterReplyHint": MessageLookupByLibrary.simpleMessage("답글을 입력하세요..."),
    "enterTitle": MessageLookupByLibrary.simpleMessage("제목을 입력하세요"),
    "enterTripInfo": MessageLookupByLibrary.simpleMessage("여행 정보 입력"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage("오류 발생"),
    "errorText": MessageLookupByLibrary.simpleMessage("오류"),
    "etcCategory": MessageLookupByLibrary.simpleMessage("기타"),
    "exhibitionHalls": MessageLookupByLibrary.simpleMessage("전시관"),
    "failedToAddComment": m17,
    "failedToAddPlace": m18,
    "failedToAddReply": m19,
    "failedToAddReview": m20,
    "failedToDeleteComment": m21,
    "failedToDeleteReply": m22,
    "failedToGetLocation": m23,
    "failedToLoadComments": m24,
    "failedToLoadMarkerIcons": m25,
    "failedToLoadUserInfo": MessageLookupByLibrary.simpleMessage(
      "사용자 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.",
    ),
    "failedToSearchPlace": m26,
    "failedToUpdateComment": m27,
    "failedToUpdateFavorites": MessageLookupByLibrary.simpleMessage(
      "찜 목록 업데이트 중 오류가 발생했습니다. 네트워크를 확인해주세요.",
    ),
    "failedToUpdateReply": m28,
    "failedToUploadImage": MessageLookupByLibrary.simpleMessage(
      "이미지 업로드에 실패했습니다. 다시 시도해주세요.",
    ),
    "favoriteToggleFailed": m29,
    "filterButton": MessageLookupByLibrary.simpleMessage("필터"),
    "filterByCategories": MessageLookupByLibrary.simpleMessage("카테고리별 필터"),
    "findCompanion": MessageLookupByLibrary.simpleMessage("동행자 구해요 👋"),
    "findCompanionTitle": MessageLookupByLibrary.simpleMessage("동행 찾기"),
    "fineDust": MessageLookupByLibrary.simpleMessage("미세먼지"),
    "free": MessageLookupByLibrary.simpleMessage("무료"),
    "freeAdmission": MessageLookupByLibrary.simpleMessage("무료 입장"),
    "freePaid": MessageLookupByLibrary.simpleMessage("무료/유료:"),
    "genderConditionAny": MessageLookupByLibrary.simpleMessage("무관"),
    "genderConditionFemaleOnly": MessageLookupByLibrary.simpleMessage("여성만"),
    "genderConditionLabel": MessageLookupByLibrary.simpleMessage("성별 조건"),
    "genderConditionMaleOnly": MessageLookupByLibrary.simpleMessage("남성만"),
    "genderFemale": MessageLookupByLibrary.simpleMessage("여성"),
    "genderLabel": MessageLookupByLibrary.simpleMessage("성별"),
    "genderMale": MessageLookupByLibrary.simpleMessage("남성"),
    "gettingCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "현재 위치 가져오는 중...",
    ),
    "goToLoginButton": MessageLookupByLibrary.simpleMessage("로그인하기"),
    "guesthouses": MessageLookupByLibrary.simpleMessage("게스트하우스"),
    "hanoks": MessageLookupByLibrary.simpleMessage("한옥"),
    "helpCenterTitle": MessageLookupByLibrary.simpleMessage("도움말 및 문의"),
    "hikingTrails": MessageLookupByLibrary.simpleMessage("등산로"),
    "historicalSites": MessageLookupByLibrary.simpleMessage("유적지"),
    "home": MessageLookupByLibrary.simpleMessage("홈"),
    "homeTab": MessageLookupByLibrary.simpleMessage("홈"),
    "hospital": MessageLookupByLibrary.simpleMessage("병원"),
    "hotels": MessageLookupByLibrary.simpleMessage("호텔"),
    "hotspotByLikes": MessageLookupByLibrary.simpleMessage("인기 핫스팟"),
    "hotspotByPopularity": MessageLookupByLibrary.simpleMessage("인기 핫스팟"),
    "hotspotsTitle": MessageLookupByLibrary.simpleMessage("나만의 핫플레이스"),
    "humidity": MessageLookupByLibrary.simpleMessage("습도"),
    "idHint": MessageLookupByLibrary.simpleMessage("ID"),
    "imageCompressionFailed": MessageLookupByLibrary.simpleMessage(
      "이미지 압축에 실패했습니다.",
    ),
    "imageUploadFailed": m30,
    "imageUploadSuccess": MessageLookupByLibrary.simpleMessage(
      "이미지가 성공적으로 업로드되었습니다!",
    ),
    "indoorCafeRecommendation": MessageLookupByLibrary.simpleMessage(
      "실내 카페 추천",
    ),
    "indoorSports": MessageLookupByLibrary.simpleMessage("실내 스포츠"),
    "initializingMap": MessageLookupByLibrary.simpleMessage("지도를 초기화하는 중..."),
    "installationAgencyLabel": MessageLookupByLibrary.simpleMessage("설치 기관"),
    "invalidAddress": MessageLookupByLibrary.simpleMessage(
      "유효하지 않은 주소입니다. 다시 시도해주세요.",
    ),
    "invalidAddressError": MessageLookupByLibrary.simpleMessage(
      "해당 주소의 좌표를 찾을 수 없습니다.",
    ),
    "isEncryptedLabel": MessageLookupByLibrary.simpleMessage("암호화된 시설인가요?"),
    "isFreeLabel": MessageLookupByLibrary.simpleMessage("무료 입장인가요?"),
    "koreanFood": MessageLookupByLibrary.simpleMessage("한식"),
    "landmark": MessageLookupByLibrary.simpleMessage("랜드마크"),
    "landmarkSyncing": MessageLookupByLibrary.simpleMessage("랜드마크 동기화 중..."),
    "leaderLabel": MessageLookupByLibrary.simpleMessage("리더"),
    "leaveButton": MessageLookupByLibrary.simpleMessage("탈퇴하기"),
    "leaveCompanionButton": MessageLookupByLibrary.simpleMessage("동행 탈퇴"),
    "leaveCompanionFailed": m31,
    "leaveCompanionTitle": MessageLookupByLibrary.simpleMessage("동행 탈퇴"),
    "leftCompanionSuccess": MessageLookupByLibrary.simpleMessage(
      "동행 그룹을 탈퇴했습니다.",
    ),
    "libraries": MessageLookupByLibrary.simpleMessage("도서관"),
    "loadFailed": m32,
    "loading": MessageLookupByLibrary.simpleMessage("로딩 중..."),
    "loadingKakaoPlaces": MessageLookupByLibrary.simpleMessage(
      "카카오 장소 로드 중...",
    ),
    "loadingPlaces": MessageLookupByLibrary.simpleMessage("장소를 로드하는 중..."),
    "loadingPublicWifiHotspots": MessageLookupByLibrary.simpleMessage(
      "공공 Wi-Fi 핫스팟 로드 중...",
    ),
    "loadingText": MessageLookupByLibrary.simpleMessage("로딩 중..."),
    "loadingWifi": MessageLookupByLibrary.simpleMessage("공공 와이파이를 로드하는 중..."),
    "locationFetchError": m33,
    "locationPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "위치 권한이 거부되었습니다.",
    ),
    "locationPermissionDeniedForever": MessageLookupByLibrary.simpleMessage(
      "위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.",
    ),
    "locationServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "위치 서비스가 비활성화되어 있습니다.",
    ),
    "locker": MessageLookupByLibrary.simpleMessage("물품 보관함"),
    "lockerSyncing": MessageLookupByLibrary.simpleMessage("물품 보관함 동기화 중..."),
    "loginButton": MessageLookupByLibrary.simpleMessage("로그인"),
    "loginErrorEmptyFields": MessageLookupByLibrary.simpleMessage(
      "ID와 비밀번호를 입력해주세요.",
    ),
    "loginErrorGeneric": m34,
    "loginErrorIdNotFound": MessageLookupByLibrary.simpleMessage(
      "ID가 존재하지 않습니다.",
    ),
    "loginErrorPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "비밀번호가 일치하지 않습니다.",
    ),
    "loginScreenTitle": MessageLookupByLibrary.simpleMessage("로그인"),
    "logoutButton": MessageLookupByLibrary.simpleMessage("로그아웃"),
    "map": MessageLookupByLibrary.simpleMessage("지도"),
    "mapLoadError": m35,
    "mapLoadingWait": MessageLookupByLibrary.simpleMessage(
      "지도를 불러오는 중입니다. 잠시만 기다려주세요...",
    ),
    "mapScreenTitle": MessageLookupByLibrary.simpleMessage("지도"),
    "mapSearchError": m36,
    "mapTab": MessageLookupByLibrary.simpleMessage("지도"),
    "mapTitle": MessageLookupByLibrary.simpleMessage("지도"),
    "mapView": MessageLookupByLibrary.simpleMessage("지도 보기"),
    "maxAgeLabel": MessageLookupByLibrary.simpleMessage("최대 나이"),
    "maxParticipantsReached": MessageLookupByLibrary.simpleMessage(
      "최대 인원에 도달했습니다.",
    ),
    "minAgeLabel": MessageLookupByLibrary.simpleMessage("최소 나이"),
    "mobileData": MessageLookupByLibrary.simpleMessage(
      "\n모바일 데이터 사용 중입니다. 데이터 소모가 많은 활동은 주의하세요.",
    ),
    "motels": MessageLookupByLibrary.simpleMessage("모텔"),
    "myActivitiesHeader": MessageLookupByLibrary.simpleMessage("내 활동"),
    "myCommentsTitle": MessageLookupByLibrary.simpleMessage("내 댓글"),
    "myFavoritesTitle": MessageLookupByLibrary.simpleMessage("내 즐겨찾기"),
    "myPage": MessageLookupByLibrary.simpleMessage("마이페이지"),
    "myPageScreenTitle": MessageLookupByLibrary.simpleMessage("마이페이지"),
    "myPageTab": MessageLookupByLibrary.simpleMessage("MY"),
    "myPostsTitle": MessageLookupByLibrary.simpleMessage("내 게시물"),
    "myScheduleTitle": MessageLookupByLibrary.simpleMessage("내 일정"),
    "myTravelScheduleTitle": MessageLookupByLibrary.simpleMessage("나의 여행 스케줄"),
    "naturalLandmarks": MessageLookupByLibrary.simpleMessage("자연경관"),
    "newDisasterMessage": MessageLookupByLibrary.simpleMessage("새 재난 문자"),
    "newPlaceAdded": m37,
    "nicknameHint": MessageLookupByLibrary.simpleMessage("닉네임"),
    "noAddressInfo": MessageLookupByLibrary.simpleMessage("주소 정보 없음"),
    "noApplicants": MessageLookupByLibrary.simpleMessage("현재 신청자가 없습니다."),
    "noComments": MessageLookupByLibrary.simpleMessage("코멘트가 없습니다."),
    "noCommentsYet": MessageLookupByLibrary.simpleMessage(
      "아직 댓글이 없습니다. 첫 댓글을 남겨보세요!",
    ),
    "noCompanions": MessageLookupByLibrary.simpleMessage("아직 동행 게시물이 없습니다."),
    "noCompanionsRecruiting": MessageLookupByLibrary.simpleMessage(
      "현재 모집 중인 동행이 없습니다.",
    ),
    "noCompanionsRegistered": MessageLookupByLibrary.simpleMessage(
      "현재 등록된 동행이 없습니다.",
    ),
    "noContent": MessageLookupByLibrary.simpleMessage("내용 없음"),
    "noDisasterMessage": MessageLookupByLibrary.simpleMessage(
      "현재 표시할 재난 문자가 없습니다.",
    ),
    "noHotspots": MessageLookupByLibrary.simpleMessage("인기 장소가 없습니다"),
    "noInternet": MessageLookupByLibrary.simpleMessage(
      "\n인터넷 연결이 없습니다. 오프라인으로 즐길 수 있는 게임이나 미리 다운로드한 콘텐츠를 추천합니다.",
    ),
    "noMyComments": MessageLookupByLibrary.simpleMessage("작성한 댓글이 없습니다."),
    "noMyPosts": MessageLookupByLibrary.simpleMessage("작성한 게시물이 없습니다."),
    "noParticipants": MessageLookupByLibrary.simpleMessage("아직 참여자가 없습니다."),
    "noPlaceFound": MessageLookupByLibrary.simpleMessage("장소를 찾을 수 없습니다."),
    "noPlaceFoundForKeyword": m38,
    "noPosts": MessageLookupByLibrary.simpleMessage("게시물이 없습니다"),
    "noRecentPosts": MessageLookupByLibrary.simpleMessage("아직 최근 게시물이 없습니다."),
    "noReviews": MessageLookupByLibrary.simpleMessage("리뷰 없음"),
    "noReviewsYet": MessageLookupByLibrary.simpleMessage("아직 리뷰가 없습니다."),
    "noSchedulesForDate": MessageLookupByLibrary.simpleMessage(
      "해당 날짜에 등록된 일정이 없습니다.",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("검색 결과가 없습니다."),
    "noSearchResultsForQuery": m39,
    "noTitle": MessageLookupByLibrary.simpleMessage("제목 없음"),
    "none": MessageLookupByLibrary.simpleMessage("없음"),
    "notificationSettingsTitle": MessageLookupByLibrary.simpleMessage("알림 설정"),
    "notificationsTooltip": MessageLookupByLibrary.simpleMessage("알림"),
    "originalPostPrefix": MessageLookupByLibrary.simpleMessage("원본 게시물: "),
    "otherAccommodations": MessageLookupByLibrary.simpleMessage("기타 숙박"),
    "otherAttractions": MessageLookupByLibrary.simpleMessage("기타 관광"),
    "otherCulture": MessageLookupByLibrary.simpleMessage("기타 문화"),
    "otherFood": MessageLookupByLibrary.simpleMessage("기타 음식"),
    "otherLeisure": MessageLookupByLibrary.simpleMessage("기타 레저"),
    "paid": MessageLookupByLibrary.simpleMessage("유료"),
    "paidAdmission": MessageLookupByLibrary.simpleMessage("유료 입장"),
    "parksGardens": MessageLookupByLibrary.simpleMessage("공원/정원"),
    "participantAcceptedSuccess": m40,
    "participantsLabel": MessageLookupByLibrary.simpleMessage("현재 인원"),
    "participantsLoadError": m41,
    "participantsSectionTitle": MessageLookupByLibrary.simpleMessage("참여자"),
    "passwordHint": MessageLookupByLibrary.simpleMessage("비밀번호"),
    "performanceHalls": MessageLookupByLibrary.simpleMessage("공연장"),
    "periodLabel": MessageLookupByLibrary.simpleMessage("기간"),
    "personUnit": MessageLookupByLibrary.simpleMessage("명"),
    "personalScheduleDetailTitle": MessageLookupByLibrary.simpleMessage(
      "개인 일정 상세",
    ),
    "pharmacy": MessageLookupByLibrary.simpleMessage("약국"),
    "pharmacySyncing": MessageLookupByLibrary.simpleMessage("약국 위치 동기화 중..."),
    "phoneChargingStation": MessageLookupByLibrary.simpleMessage("휴대폰 충전소"),
    "placeAddFailed": m42,
    "placeAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "장소가 성공적으로 추가되었습니다!",
    ),
    "placeAddressHint": MessageLookupByLibrary.simpleMessage("주소를 입력하세요"),
    "placeDeleteFailed": m43,
    "placeDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "장소가 성공적으로 삭제되었습니다!",
    ),
    "placeDetailsTitle": MessageLookupByLibrary.simpleMessage("장소 세부 정보"),
    "placeLoadError": m44,
    "placeNameAndAddressRequired": MessageLookupByLibrary.simpleMessage(
      "장소 이름과 주소는 필수입니다.",
    ),
    "placeNameHint": MessageLookupByLibrary.simpleMessage("장소 이름을 입력하세요"),
    "placeNameRequired": MessageLookupByLibrary.simpleMessage("장소 이름 (필수)"),
    "placeNotFound": MessageLookupByLibrary.simpleMessage("장소를 찾을 수 없습니다."),
    "placeUpdateFailed": m45,
    "placeUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "장소가 성공적으로 수정되었습니다!",
    ),
    "policeStation": MessageLookupByLibrary.simpleMessage("경찰서"),
    "policeStationSyncing": MessageLookupByLibrary.simpleMessage(
      "경찰서/파출소 동기화 중...",
    ),
    "postButton": MessageLookupByLibrary.simpleMessage("작성"),
    "postContentHint": MessageLookupByLibrary.simpleMessage("내용을 입력하세요"),
    "postCreateFailed": m46,
    "postCreatedSuccess": MessageLookupByLibrary.simpleMessage(
      "게시물이 성공적으로 작성되었습니다!",
    ),
    "postDetailTitle": MessageLookupByLibrary.simpleMessage("게시물 상세"),
    "postLoadFailed": m47,
    "postTitleHint": MessageLookupByLibrary.simpleMessage("제목을 입력하세요"),
    "profileUpdateFailed": MessageLookupByLibrary.simpleMessage("프로필 업데이트 실패:"),
    "profileUpdateSuccess": MessageLookupByLibrary.simpleMessage(
      "프로필이 성공적으로 업데이트되었습니다!",
    ),
    "publicRestroom": MessageLookupByLibrary.simpleMessage("공중화장실"),
    "publicToiletSyncing": MessageLookupByLibrary.simpleMessage(
      "공중 화장실 동기화 중...",
    ),
    "publicWifi": MessageLookupByLibrary.simpleMessage("공공 와이파이"),
    "publicWifiSyncing": MessageLookupByLibrary.simpleMessage(
      "공공 와이파이 동기화 중...",
    ),
    "publicwifi": MessageLookupByLibrary.simpleMessage("공공와이파이"),
    "rain": MessageLookupByLibrary.simpleMessage("비"),
    "rating": m48,
    "recentPosts": MessageLookupByLibrary.simpleMessage("최근 게시물"),
    "recentPostsTitle": MessageLookupByLibrary.simpleMessage("최근 게시물"),
    "recommendationBasedOnCurrentStatus": MessageLookupByLibrary.simpleMessage(
      "현재 상태 기반 추천",
    ),
    "recommendationText": MessageLookupByLibrary.simpleMessage(
      "비가 오니 실내 활동을 추천드려요",
    ),
    "recommendationTitle": MessageLookupByLibrary.simpleMessage("현재 상태 기반 추천"),
    "recruitCountError": MessageLookupByLibrary.simpleMessage(
      "2~50 사이 숫자를 입력하세요",
    ),
    "recruitCountLabel": MessageLookupByLibrary.simpleMessage("모집 인원 수 *"),
    "recruiting": MessageLookupByLibrary.simpleMessage("모집 중"),
    "recruitmentClosed": MessageLookupByLibrary.simpleMessage("모집 마감"),
    "recruitmentClosedWarning": MessageLookupByLibrary.simpleMessage(
      "모집이 마감되었습니다.",
    ),
    "recruitmentComplete": MessageLookupByLibrary.simpleMessage("모집 완료"),
    "refreshData": MessageLookupByLibrary.simpleMessage("데이터 동기화"),
    "registerCompanionButton": MessageLookupByLibrary.simpleMessage("동행 등록"),
    "registerCompanionTitle": MessageLookupByLibrary.simpleMessage("동행 등록"),
    "registerCompanionTooltip": MessageLookupByLibrary.simpleMessage("동행 등록"),
    "registerFailed": MessageLookupByLibrary.simpleMessage("등록 실패"),
    "registerTripButton": MessageLookupByLibrary.simpleMessage("여행 등록"),
    "registerTripTitle": MessageLookupByLibrary.simpleMessage("여행 등록"),
    "rejectButton": MessageLookupByLibrary.simpleMessage("거절"),
    "rejectRequestFailed": m49,
    "removedFromFavorites": MessageLookupByLibrary.simpleMessage(
      "즐겨찾기에서 제거되었습니다.",
    ),
    "replyAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "답글이 성공적으로 추가되었습니다!",
    ),
    "replyButton": MessageLookupByLibrary.simpleMessage("답글"),
    "replyContentHint": MessageLookupByLibrary.simpleMessage("답글 내용을 입력하세요..."),
    "replyDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "답글이 성공적으로 삭제되었습니다!",
    ),
    "replyEmptyWarning": MessageLookupByLibrary.simpleMessage(
      "답글은 비워둘 수 없습니다.",
    ),
    "replyHint": MessageLookupByLibrary.simpleMessage("답글을 입력하세요..."),
    "replyPrefix": MessageLookupByLibrary.simpleMessage("답글"),
    "replyUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "답글이 성공적으로 수정되었습니다!",
    ),
    "requestRejectedSuccess": MessageLookupByLibrary.simpleMessage(
      "신청이 거절되었습니다.",
    ),
    "requestsLoadError": m50,
    "resorts": MessageLookupByLibrary.simpleMessage("리조트"),
    "restaurant": MessageLookupByLibrary.simpleMessage("음식점"),
    "restaurantSyncing": MessageLookupByLibrary.simpleMessage("음식점 동기화 중..."),
    "reviewAddFailed": m51,
    "reviewAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "리뷰가 성공적으로 추가되었습니다!",
    ),
    "reviewFieldsEmptyWarning": MessageLookupByLibrary.simpleMessage(
      "별점과 댓글을 입력해주세요.",
    ),
    "reviewHint": MessageLookupByLibrary.simpleMessage("리뷰를 작성하세요..."),
    "reviewInputHint": MessageLookupByLibrary.simpleMessage("리뷰를 입력하세요..."),
    "reviewLoadFailed": m52,
    "reviewsTitle": MessageLookupByLibrary.simpleMessage("리뷰"),
    "saveButton": MessageLookupByLibrary.simpleMessage("저장"),
    "scheduleDeleted": MessageLookupByLibrary.simpleMessage("일정이 삭제되었습니다."),
    "scheduleTitleLabel": MessageLookupByLibrary.simpleMessage("제목 *"),
    "search": MessageLookupByLibrary.simpleMessage("검색"),
    "searchButton": MessageLookupByLibrary.simpleMessage("검색"),
    "searchFailed": m53,
    "searchHintText": MessageLookupByLibrary.simpleMessage("검색어를 입력하세요..."),
    "searchMap": MessageLookupByLibrary.simpleMessage("지도 검색"),
    "searchPlaceholder": MessageLookupByLibrary.simpleMessage(
      "장소 이름 또는 주소를 입력하세요",
    ),
    "searchPlacesHint": MessageLookupByLibrary.simpleMessage("장소를 검색하세요..."),
    "searchResultsDisplayed": m54,
    "searching": m55,
    "selectCategoryHint": MessageLookupByLibrary.simpleMessage("카테고리 선택"),
    "selectEndDate": MessageLookupByLibrary.simpleMessage("도착일 선택"),
    "selectImageButton": MessageLookupByLibrary.simpleMessage("이미지 선택"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("언어 선택"),
    "selectLocation": MessageLookupByLibrary.simpleMessage("위치 선택"),
    "selectLocationButton": MessageLookupByLibrary.simpleMessage("위치 선택"),
    "selectLocationTitle": MessageLookupByLibrary.simpleMessage("위치 선택"),
    "selectLocationconfimButton": MessageLookupByLibrary.simpleMessage("확인"),
    "selectStartAndEndDate": MessageLookupByLibrary.simpleMessage(
      "출발일과 도착일을 모두 선택해주세요.",
    ),
    "selectStartDate": MessageLookupByLibrary.simpleMessage("출발일 선택"),
    "setCompanionConditions": MessageLookupByLibrary.simpleMessage("동행 조건 설정"),
    "settingsHeader": MessageLookupByLibrary.simpleMessage("설정"),
    "showOnlyOpenCompanions": MessageLookupByLibrary.simpleMessage(
      "모집 중인 동행만 보기",
    ),
    "signUpButton": MessageLookupByLibrary.simpleMessage("회원가입"),
    "signUpErrorAllFieldsRequired": MessageLookupByLibrary.simpleMessage(
      "모든 필드를 입력해주세요.",
    ),
    "signUpErrorGeneric": m56,
    "signUpErrorIdExists": MessageLookupByLibrary.simpleMessage(
      "이미 존재하는 ID입니다.",
    ),
    "signUpErrorPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "비밀번호가 일치하지 않습니다.",
    ),
    "signUpErrorPasswordTooShort": MessageLookupByLibrary.simpleMessage(
      "비밀번호는 최소 6자 이상이어야 합니다.",
    ),
    "signUpScreenTitle": MessageLookupByLibrary.simpleMessage("회원가입"),
    "snow": MessageLookupByLibrary.simpleMessage("눈"),
    "startDate": MessageLookupByLibrary.simpleMessage("출발일"),
    "startDateBeforeEndDateError": MessageLookupByLibrary.simpleMessage(
      "출발일은 도착일 이전이어야 합니다.",
    ),
    "subcategoryAirport": MessageLookupByLibrary.simpleMessage("공항"),
    "subcategoryBusTerminal": MessageLookupByLibrary.simpleMessage("버스 터미널"),
    "subcategoryCafe": MessageLookupByLibrary.simpleMessage("카페"),
    "subcategoryCamping": MessageLookupByLibrary.simpleMessage("캠핑"),
    "subcategoryChineseFood": MessageLookupByLibrary.simpleMessage("중식"),
    "subcategoryConvenience": MessageLookupByLibrary.simpleMessage("편의시설"),
    "subcategoryCulture": MessageLookupByLibrary.simpleMessage("문화"),
    "subcategoryGuestHouse": MessageLookupByLibrary.simpleMessage("게스트하우스"),
    "subcategoryHistory": MessageLookupByLibrary.simpleMessage("역사"),
    "subcategoryHospital": MessageLookupByLibrary.simpleMessage("병원"),
    "subcategoryHotel": MessageLookupByLibrary.simpleMessage("호텔"),
    "subcategoryJapaneseFood": MessageLookupByLibrary.simpleMessage("일식"),
    "subcategoryKoreanFood": MessageLookupByLibrary.simpleMessage("한식"),
    "subcategoryLabel": MessageLookupByLibrary.simpleMessage("세부 카테고리"),
    "subcategoryLeisure": MessageLookupByLibrary.simpleMessage("레저"),
    "subcategoryMotel": MessageLookupByLibrary.simpleMessage("모텔"),
    "subcategoryNature": MessageLookupByLibrary.simpleMessage("자연"),
    "subcategoryPoliceStation": MessageLookupByLibrary.simpleMessage("경찰서"),
    "subcategoryPort": MessageLookupByLibrary.simpleMessage("항구"),
    "subcategoryPublicInstitution": MessageLookupByLibrary.simpleMessage(
      "공공기관",
    ),
    "subcategoryResort": MessageLookupByLibrary.simpleMessage("리조트"),
    "subcategoryTrainStation": MessageLookupByLibrary.simpleMessage("기차역"),
    "subcategoryWesternFood": MessageLookupByLibrary.simpleMessage("양식"),
    "submitReviewButton": MessageLookupByLibrary.simpleMessage("리뷰 제출"),
    "syncingFirestoreData": MessageLookupByLibrary.simpleMessage(
      "Firestore 데이터 동기화 중...",
    ),
    "temperature": MessageLookupByLibrary.simpleMessage("온도"),
    "themeParks": MessageLookupByLibrary.simpleMessage("테마파크"),
    "titleLabel": MessageLookupByLibrary.simpleMessage("제목 *"),
    "todayEnjoyableDay": MessageLookupByLibrary.simpleMessage(
      "오늘도 즐거운 하루 되세요!",
    ),
    "tripDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "예) 혼자만의 시간도 존중해요 / 저녁엔 근처 맛집 투어할 예정입니다",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("알 수 없음"),
    "unknownPost": MessageLookupByLibrary.simpleMessage("알 수 없는 게시물"),
    "uploadImageTooltip": MessageLookupByLibrary.simpleMessage("이미지 업로드"),
    "uploadingImage": MessageLookupByLibrary.simpleMessage("이미지를 업로드하는 중..."),
    "userNotFound": MessageLookupByLibrary.simpleMessage("사용자 정보를 찾을 수 없습니다."),
    "viewAllCompanionsButton": MessageLookupByLibrary.simpleMessage("모든 동행 보기"),
    "viewMoreCompanions": MessageLookupByLibrary.simpleMessage("더 많은 동행 보기..."),
    "viewMoreHotspots": MessageLookupByLibrary.simpleMessage("더 많은 핫스팟 보기"),
    "viewMorePosts": MessageLookupByLibrary.simpleMessage("더 많은 게시물 보기"),
    "viewMorePostsButton": MessageLookupByLibrary.simpleMessage("더 많은 게시물 보기"),
    "waterSports": MessageLookupByLibrary.simpleMessage("수상 스포츠"),
    "weatherClear": MessageLookupByLibrary.simpleMessage(
      "화창한 날씨입니다! 산책이나 야외 활동을 추천합니다.",
    ),
    "weatherClouds": MessageLookupByLibrary.simpleMessage(
      "흐린 날씨입니다. 가벼운 실내 운동이나 독서를 추천합니다.",
    ),
    "weatherCold": MessageLookupByLibrary.simpleMessage(
      "날씨가 많이 춥습니다! 따뜻하게 입고 목도리, 장갑을 챙기세요.",
    ),
    "weatherCondition": MessageLookupByLibrary.simpleMessage("날씨"),
    "weatherHot": MessageLookupByLibrary.simpleMessage(
      "날씨가 매우 덥습니다! 시원한 음료와 함께 야외 활동을 자제하고 실내 활동을 추천합니다.",
    ),
    "weatherInfo": MessageLookupByLibrary.simpleMessage("날씨 정보"),
    "weatherLoadingError": MessageLookupByLibrary.simpleMessage(
      "날씨 정보를 불러오지 못했습니다.",
    ),
    "weatherRain": MessageLookupByLibrary.simpleMessage(
      "비가 오니 우산을 꼭 챙기고, 실내에서 즐길 수 있는 활동을 찾아보세요.",
    ),
    "weatherSnow": MessageLookupByLibrary.simpleMessage(
      "눈이 오니 미끄럼에 주의하시고, 따뜻한 차 한 잔 어떠세요?",
    ),
    "weatherTooltip": MessageLookupByLibrary.simpleMessage("날씨 정보"),
    "welcomeMessage": MessageLookupByLibrary.simpleMessage("환영합니다,"),
    "westernFood": MessageLookupByLibrary.simpleMessage("양식"),
    "wifiConnected": MessageLookupByLibrary.simpleMessage(
      "\nWi-Fi에 연결되어 있습니다. 데이터 걱정 없이 스트리밍 서비스를 이용해 보세요!",
    ),
    "wifiLoadError": m57,
    "wifiMarkerSnippet": MessageLookupByLibrary.simpleMessage("공공 와이파이"),
    "winterSports": MessageLookupByLibrary.simpleMessage("겨울 스포츠"),
    "writeButton": MessageLookupByLibrary.simpleMessage("작성"),
    "writeReplyTitle": MessageLookupByLibrary.simpleMessage("답글 작성"),
    "writeReviewTitle": MessageLookupByLibrary.simpleMessage("리뷰 작성"),
  };

}

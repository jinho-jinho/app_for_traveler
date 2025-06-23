// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Login`
  String get loginScreenTitle {
    return Intl.message('Login', name: 'loginScreenTitle', desc: '', args: []);
  }

  /// `Sign Up`
  String get signUpScreenTitle {
    return Intl.message(
      'Sign Up',
      name: 'signUpScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get idHint {
    return Intl.message('ID', name: 'idHint', desc: '', args: []);
  }

  /// `Password`
  String get passwordHint {
    return Intl.message('Password', name: 'passwordHint', desc: '', args: []);
  }

  /// `Confirm Password`
  String get confirmPasswordHint {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get nicknameHint {
    return Intl.message('Nickname', name: 'nicknameHint', desc: '', args: []);
  }

  /// `Gender`
  String get genderLabel {
    return Intl.message('Gender', name: 'genderLabel', desc: '', args: []);
  }

  /// `Female`
  String get genderFemale {
    return Intl.message('Female', name: 'genderFemale', desc: '', args: []);
  }

  /// `Male`
  String get genderMale {
    return Intl.message('Male', name: 'genderMale', desc: '', args: []);
  }

  /// `Age`
  String get ageHint {
    return Intl.message('Age', name: 'ageHint', desc: '', args: []);
  }

  /// `Contact (KakaoTalk ID or Email)`
  String get contactHint {
    return Intl.message(
      'Contact (KakaoTalk ID or Email)',
      name: 'contactHint',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginButton {
    return Intl.message('Login', name: 'loginButton', desc: '', args: []);
  }

  /// `Sign Up`
  String get signUpButton {
    return Intl.message('Sign Up', name: 'signUpButton', desc: '', args: []);
  }

  /// `Create Account`
  String get createAccountButton {
    return Intl.message(
      'Create Account',
      name: 'createAccountButton',
      desc: '',
      args: [],
    );
  }

  /// `Go to Login`
  String get goToLoginButton {
    return Intl.message(
      'Go to Login',
      name: 'goToLoginButton',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your ID and password.`
  String get loginErrorEmptyFields {
    return Intl.message(
      'Please enter your ID and password.',
      name: 'loginErrorEmptyFields',
      desc: '',
      args: [],
    );
  }

  /// `ID does not exist.`
  String get loginErrorIdNotFound {
    return Intl.message(
      'ID does not exist.',
      name: 'loginErrorIdNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Password does not match.`
  String get loginErrorPasswordMismatch {
    return Intl.message(
      'Password does not match.',
      name: 'loginErrorPasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Login error: {error}`
  String loginErrorGeneric(String error) {
    return Intl.message(
      'Login error: $error',
      name: 'loginErrorGeneric',
      desc: '',
      args: [error],
    );
  }

  /// `Please fill in all fields.`
  String get signUpErrorAllFieldsRequired {
    return Intl.message(
      'Please fill in all fields.',
      name: 'signUpErrorAllFieldsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match.`
  String get signUpErrorPasswordMismatch {
    return Intl.message(
      'Passwords do not match.',
      name: 'signUpErrorPasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters long.`
  String get signUpErrorPasswordTooShort {
    return Intl.message(
      'Password must be at least 6 characters long.',
      name: 'signUpErrorPasswordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `ID already exists.`
  String get signUpErrorIdExists {
    return Intl.message(
      'ID already exists.',
      name: 'signUpErrorIdExists',
      desc: '',
      args: [],
    );
  }

  /// `Sign up error: {error}`
  String signUpErrorGeneric(String error) {
    return Intl.message(
      'Sign up error: $error',
      name: 'signUpErrorGeneric',
      desc: '',
      args: [error],
    );
  }

  /// `My Page`
  String get myPageScreenTitle {
    return Intl.message(
      'My Page',
      name: 'myPageScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loadingText {
    return Intl.message('Loading...', name: 'loadingText', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfileButton {
    return Intl.message(
      'Edit Profile',
      name: 'editProfileButton',
      desc: '',
      args: [],
    );
  }

  /// `My Activities`
  String get myActivitiesHeader {
    return Intl.message(
      'My Activities',
      name: 'myActivitiesHeader',
      desc: '',
      args: [],
    );
  }

  /// `My Favorites`
  String get myFavoritesTitle {
    return Intl.message(
      'My Favorites',
      name: 'myFavoritesTitle',
      desc: '',
      args: [],
    );
  }

  /// `My Schedule`
  String get myScheduleTitle {
    return Intl.message(
      'My Schedule',
      name: 'myScheduleTitle',
      desc: '',
      args: [],
    );
  }

  /// `My Posts`
  String get myPostsTitle {
    return Intl.message('My Posts', name: 'myPostsTitle', desc: '', args: []);
  }

  /// `No posts.`
  String get noMyPosts {
    return Intl.message('No posts.', name: 'noMyPosts', desc: '', args: []);
  }

  /// `No Title`
  String get noTitle {
    return Intl.message('No Title', name: 'noTitle', desc: '', args: []);
  }

  /// `Author: `
  String get authorPrefix {
    return Intl.message('Author: ', name: 'authorPrefix', desc: '', args: []);
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `My Comments`
  String get myCommentsTitle {
    return Intl.message(
      'My Comments',
      name: 'myCommentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `No comments.`
  String get noMyComments {
    return Intl.message(
      'No comments.',
      name: 'noMyComments',
      desc: '',
      args: [],
    );
  }

  /// `No Content`
  String get noContent {
    return Intl.message('No Content', name: 'noContent', desc: '', args: []);
  }

  /// `Original Post: `
  String get originalPostPrefix {
    return Intl.message(
      'Original Post: ',
      name: 'originalPostPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Post`
  String get unknownPost {
    return Intl.message(
      'Unknown Post',
      name: 'unknownPost',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsHeader {
    return Intl.message('Settings', name: 'settingsHeader', desc: '', args: []);
  }

  /// `Notification Settings`
  String get notificationSettingsTitle {
    return Intl.message(
      'Notification Settings',
      name: 'notificationSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Help Center`
  String get helpCenterTitle {
    return Intl.message(
      'Help Center',
      name: 'helpCenterTitle',
      desc: '',
      args: [],
    );
  }

  /// `About App`
  String get aboutAppTitle {
    return Intl.message('About App', name: 'aboutAppTitle', desc: '', args: []);
  }

  /// `Logout`
  String get logoutButton {
    return Intl.message('Logout', name: 'logoutButton', desc: '', args: []);
  }

  /// `Delete Account`
  String get deleteAccountButton {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccountButton',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfileTitle {
    return Intl.message(
      'Edit Profile',
      name: 'editProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message('Cancel', name: 'cancelButton', desc: '', args: []);
  }

  /// `Profile updated successfully!`
  String get profileUpdateSuccess {
    return Intl.message(
      'Profile updated successfully!',
      name: 'profileUpdateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update profile:`
  String get profileUpdateFailed {
    return Intl.message(
      'Failed to update profile:',
      name: 'profileUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeButton {
    return Intl.message('Close', name: 'closeButton', desc: '', args: []);
  }

  /// `Traveler App`
  String get appTitle {
    return Intl.message('Traveler App', name: 'appTitle', desc: '', args: []);
  }

  /// `Notifications`
  String get notificationsTooltip {
    return Intl.message(
      'Notifications',
      name: 'notificationsTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Weather Info`
  String get weatherTooltip {
    return Intl.message(
      'Weather Info',
      name: 'weatherTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get homeTab {
    return Intl.message('Home', name: 'homeTab', desc: '', args: []);
  }

  /// `Map`
  String get mapTab {
    return Intl.message('Map', name: 'mapTab', desc: '', args: []);
  }

  /// `Board`
  String get boardTab {
    return Intl.message('Board', name: 'boardTab', desc: '', args: []);
  }

  /// `My Page`
  String get myPageTab {
    return Intl.message('My Page', name: 'myPageTab', desc: '', args: []);
  }

  /// `Create Post`
  String get createPostTooltip {
    return Intl.message(
      'Create Post',
      name: 'createPostTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Participants`
  String get currentParticipants {
    return Intl.message(
      'Participants',
      name: 'currentParticipants',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get closedStatus {
    return Intl.message('Closed', name: 'closedStatus', desc: '', args: []);
  }

  /// `Disaster Alert`
  String get disasterAlertTitle {
    return Intl.message(
      'Disaster Alert',
      name: 'disasterAlertTitle',
      desc: '',
      args: [],
    );
  }

  /// `No disaster messages currently.`
  String get noDisasterMessage {
    return Intl.message(
      'No disaster messages currently.',
      name: 'noDisasterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load weather data.`
  String get weatherLoadingError {
    return Intl.message(
      'Failed to load weather data.',
      name: 'weatherLoadingError',
      desc: '',
      args: [],
    );
  }

  /// `Current Weather Information`
  String get currentWeatherInfo {
    return Intl.message(
      'Current Weather Information',
      name: 'currentWeatherInfo',
      desc: '',
      args: [],
    );
  }

  /// `Temperature`
  String get temperature {
    return Intl.message('Temperature', name: 'temperature', desc: '', args: []);
  }

  /// `Weather`
  String get weatherCondition {
    return Intl.message(
      'Weather',
      name: 'weatherCondition',
      desc: '',
      args: [],
    );
  }

  /// `Humidity`
  String get humidity {
    return Intl.message('Humidity', name: 'humidity', desc: '', args: []);
  }

  /// `Fine Dust`
  String get fineDust {
    return Intl.message('Fine Dust', name: 'fineDust', desc: '', args: []);
  }

  /// `Clear sky`
  String get clearSky {
    return Intl.message('Clear sky', name: 'clearSky', desc: '', args: []);
  }

  /// `Clouds`
  String get clouds {
    return Intl.message('Clouds', name: 'clouds', desc: '', args: []);
  }

  /// `Rain`
  String get rain {
    return Intl.message('Rain', name: 'rain', desc: '', args: []);
  }

  /// `Snow`
  String get snow {
    return Intl.message('Snow', name: 'snow', desc: '', args: []);
  }

  /// `Welcome,`
  String get welcomeMessage {
    return Intl.message('Welcome,', name: 'welcomeMessage', desc: '', args: []);
  }

  /// `Currently in Gumi-si, Gyeongsangbuk-do, South Korea`
  String get currentLocationInfo {
    return Intl.message(
      'Currently in Gumi-si, Gyeongsangbuk-do, South Korea',
      name: 'currentLocationInfo',
      desc: '',
      args: [],
    );
  }

  /// `My Hot Places`
  String get hotspotsTitle {
    return Intl.message(
      'My Hot Places',
      name: 'hotspotsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add Place`
  String get addPlaceButton {
    return Intl.message(
      'Add Place',
      name: 'addPlaceButton',
      desc: '',
      args: [],
    );
  }

  /// `Find a Companion`
  String get findCompanionTitle {
    return Intl.message(
      'Find a Companion',
      name: 'findCompanionTitle',
      desc: '',
      args: [],
    );
  }

  /// `No companion posts yet.`
  String get noCompanions {
    return Intl.message(
      'No companion posts yet.',
      name: 'noCompanions',
      desc: '',
      args: [],
    );
  }

  /// `View All Companions`
  String get viewAllCompanionsButton {
    return Intl.message(
      'View All Companions',
      name: 'viewAllCompanionsButton',
      desc: '',
      args: [],
    );
  }

  /// `Recent Posts`
  String get recentPostsTitle {
    return Intl.message(
      'Recent Posts',
      name: 'recentPostsTitle',
      desc: '',
      args: [],
    );
  }

  /// `No recent posts yet.`
  String get noRecentPosts {
    return Intl.message(
      'No recent posts yet.',
      name: 'noRecentPosts',
      desc: '',
      args: [],
    );
  }

  /// `View More Posts`
  String get viewMorePostsButton {
    return Intl.message(
      'View More Posts',
      name: 'viewMorePostsButton',
      desc: '',
      args: [],
    );
  }

  /// `Start date must be before end date.`
  String get startDateBeforeEndDateError {
    return Intl.message(
      'Start date must be before end date.',
      name: 'startDateBeforeEndDateError',
      desc: '',
      args: [],
    );
  }

  /// `Edit failed`
  String get editFailed {
    return Intl.message('Edit failed', name: 'editFailed', desc: '', args: []);
  }

  /// `Edit Schedule`
  String get editScheduleTitle {
    return Intl.message(
      'Edit Schedule',
      name: 'editScheduleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Travel Information`
  String get editTravelInfo {
    return Intl.message(
      'Edit Travel Information',
      name: 'editTravelInfo',
      desc: '',
      args: [],
    );
  }

  /// `Title *`
  String get scheduleTitleLabel {
    return Intl.message(
      'Title *',
      name: 'scheduleTitleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a title`
  String get enterTitle {
    return Intl.message(
      'Please enter a title',
      name: 'enterTitle',
      desc: '',
      args: [],
    );
  }

  /// `Additional Description`
  String get additionalDescriptionLabel {
    return Intl.message(
      'Additional Description',
      name: 'additionalDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g., Relaxing time with friends / Museum-focused itinerary`
  String get descriptionHint {
    return Intl.message(
      'e.g., Relaxing time with friends / Museum-focused itinerary',
      name: 'descriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Destination *`
  String get destinationLabel {
    return Intl.message(
      'Destination *',
      name: 'destinationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a destination`
  String get enterDestination {
    return Intl.message(
      'Please enter a destination',
      name: 'enterDestination',
      desc: '',
      args: [],
    );
  }

  /// `Select Start Date`
  String get selectStartDate {
    return Intl.message(
      'Select Start Date',
      name: 'selectStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get startDate {
    return Intl.message('Start Date', name: 'startDate', desc: '', args: []);
  }

  /// `Select End Date`
  String get selectEndDate {
    return Intl.message(
      'Select End Date',
      name: 'selectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get endDate {
    return Intl.message('End Date', name: 'endDate', desc: '', args: []);
  }

  /// `Complete Edit`
  String get completeEditButton {
    return Intl.message(
      'Complete Edit',
      name: 'completeEditButton',
      desc: '',
      args: [],
    );
  }

  /// `Please select both start and end dates.`
  String get selectStartAndEndDate {
    return Intl.message(
      'Please select both start and end dates.',
      name: 'selectStartAndEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Edit Companion Info`
  String get editCompanionInfoTitle {
    return Intl.message(
      'Edit Companion Info',
      name: 'editCompanionInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Companion Information`
  String get editCompanionInfo {
    return Intl.message(
      'Edit Companion Information',
      name: 'editCompanionInfo',
      desc: '',
      args: [],
    );
  }

  /// `Title *`
  String get titleLabel {
    return Intl.message('Title *', name: 'titleLabel', desc: '', args: []);
  }

  /// `e.g., Prefer quiet travel / Welcome MBTI I types`
  String get companionDescriptionHint {
    return Intl.message(
      'e.g., Prefer quiet travel / Welcome MBTI I types',
      name: 'companionDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Number of Recruits *`
  String get recruitCountLabel {
    return Intl.message(
      'Number of Recruits *',
      name: 'recruitCountLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter a number between 2 and 50`
  String get recruitCountError {
    return Intl.message(
      'Enter a number between 2 and 50',
      name: 'recruitCountError',
      desc: '',
      args: [],
    );
  }

  /// `Set Companion Conditions`
  String get setCompanionConditions {
    return Intl.message(
      'Set Companion Conditions',
      name: 'setCompanionConditions',
      desc: '',
      args: [],
    );
  }

  /// `Gender Condition`
  String get genderConditionLabel {
    return Intl.message(
      'Gender Condition',
      name: 'genderConditionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Any`
  String get genderConditionAny {
    return Intl.message('Any', name: 'genderConditionAny', desc: '', args: []);
  }

  /// `Male Only`
  String get genderConditionMaleOnly {
    return Intl.message(
      'Male Only',
      name: 'genderConditionMaleOnly',
      desc: '',
      args: [],
    );
  }

  /// `Female Only`
  String get genderConditionFemaleOnly {
    return Intl.message(
      'Female Only',
      name: 'genderConditionFemaleOnly',
      desc: '',
      args: [],
    );
  }

  /// `Age Unlimited`
  String get ageUnlimited {
    return Intl.message(
      'Age Unlimited',
      name: 'ageUnlimited',
      desc: '',
      args: [],
    );
  }

  /// `Min Age`
  String get minAgeLabel {
    return Intl.message('Min Age', name: 'minAgeLabel', desc: '', args: []);
  }

  /// `Max Age`
  String get maxAgeLabel {
    return Intl.message('Max Age', name: 'maxAgeLabel', desc: '', args: []);
  }

  /// `Range`
  String get ageConditionRange {
    return Intl.message('Range', name: 'ageConditionRange', desc: '', args: []);
  }

  /// `Registration failed`
  String get registerFailed {
    return Intl.message(
      'Registration failed',
      name: 'registerFailed',
      desc: '',
      args: [],
    );
  }

  /// `Register Trip`
  String get registerTripTitle {
    return Intl.message(
      'Register Trip',
      name: 'registerTripTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter Trip Information`
  String get enterTripInfo {
    return Intl.message(
      'Enter Trip Information',
      name: 'enterTripInfo',
      desc: '',
      args: [],
    );
  }

  /// `e.g., Respect alone time / Planning a food tour nearby in the evening`
  String get tripDescriptionHint {
    return Intl.message(
      'e.g., Respect alone time / Planning a food tour nearby in the evening',
      name: 'tripDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Register Trip`
  String get registerTripButton {
    return Intl.message(
      'Register Trip',
      name: 'registerTripButton',
      desc: '',
      args: [],
    );
  }

  /// `Register Companion`
  String get registerCompanionTooltip {
    return Intl.message(
      'Register Companion',
      name: 'registerCompanionTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Show only recruiting companions`
  String get showOnlyOpenCompanions {
    return Intl.message(
      'Show only recruiting companions',
      name: 'showOnlyOpenCompanions',
      desc: '',
      args: [],
    );
  }

  /// `Destination Undecided`
  String get destinationUndecided {
    return Intl.message(
      'Destination Undecided',
      name: 'destinationUndecided',
      desc: '',
      args: [],
    );
  }

  /// `No companions currently registered.`
  String get noCompanionsRegistered {
    return Intl.message(
      'No companions currently registered.',
      name: 'noCompanionsRegistered',
      desc: '',
      args: [],
    );
  }

  /// `Recruitment Complete`
  String get recruitmentComplete {
    return Intl.message(
      'Recruitment Complete',
      name: 'recruitmentComplete',
      desc: '',
      args: [],
    );
  }

  /// `Recruiting`
  String get recruiting {
    return Intl.message('Recruiting', name: 'recruiting', desc: '', args: []);
  }

  /// `persons`
  String get personUnit {
    return Intl.message('persons', name: 'personUnit', desc: '', args: []);
  }

  /// `User information not found.`
  String get userNotFound {
    return Intl.message(
      'User information not found.',
      name: 'userNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Anonymous`
  String get anonymous {
    return Intl.message('Anonymous', name: 'anonymous', desc: '', args: []);
  }

  /// `Register Companion`
  String get registerCompanionTitle {
    return Intl.message(
      'Register Companion',
      name: 'registerCompanionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter Companion Information`
  String get enterCompanionInfo {
    return Intl.message(
      'Enter Companion Information',
      name: 'enterCompanionInfo',
      desc: '',
      args: [],
    );
  }

  /// `Register Companion`
  String get registerCompanionButton {
    return Intl.message(
      'Register Companion',
      name: 'registerCompanionButton',
      desc: '',
      args: [],
    );
  }

  /// `My Travel Schedule`
  String get myTravelScheduleTitle {
    return Intl.message(
      'My Travel Schedule',
      name: 'myTravelScheduleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add Personal Schedule`
  String get addPersonalScheduleTooltip {
    return Intl.message(
      'Add Personal Schedule',
      name: 'addPersonalScheduleTooltip',
      desc: '',
      args: [],
    );
  }

  /// `No schedules registered for this date.`
  String get noSchedulesForDate {
    return Intl.message(
      'No schedules registered for this date.',
      name: 'noSchedulesForDate',
      desc: '',
      args: [],
    );
  }

  /// `[Companion] {scheduleTitle}`
  String companionSchedulePrefix(Object scheduleTitle) {
    return Intl.message(
      '[Companion] $scheduleTitle',
      name: 'companionSchedulePrefix',
      desc: 'Prefix for companion schedules in the list',
      args: [scheduleTitle],
    );
  }

  /// `Load failed: {error}`
  String loadFailed(Object error) {
    return Intl.message(
      'Load failed: $error',
      name: 'loadFailed',
      desc: 'Error message for failed data loading',
      args: [error],
    );
  }

  /// `Delete Schedule`
  String get deleteScheduleTitle {
    return Intl.message(
      'Delete Schedule',
      name: 'deleteScheduleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this schedule?`
  String get confirmDeleteSchedule {
    return Intl.message(
      'Are you sure you want to delete this schedule?',
      name: 'confirmDeleteSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteButton {
    return Intl.message('Delete', name: 'deleteButton', desc: '', args: []);
  }

  /// `Schedule deleted.`
  String get scheduleDeleted {
    return Intl.message(
      'Schedule deleted.',
      name: 'scheduleDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Delete failed: {error}`
  String deleteFailed(Object error) {
    return Intl.message(
      'Delete failed: $error',
      name: 'deleteFailed',
      desc: 'Error message for failed schedule deletion',
      args: [error],
    );
  }

  /// `Personal Schedule Details`
  String get personalScheduleDetailTitle {
    return Intl.message(
      'Personal Schedule Details',
      name: 'personalScheduleDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get editButton {
    return Intl.message('Edit', name: 'editButton', desc: '', args: []);
  }

  /// `Cannot load schedule.`
  String get cannotLoadSchedule {
    return Intl.message(
      'Cannot load schedule.',
      name: 'cannotLoadSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Additional description: `
  String get additionalDescriptionPrefix {
    return Intl.message(
      'Additional description: ',
      name: 'additionalDescriptionPrefix',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Have a great day!`
  String get todayEnjoyableDay {
    return Intl.message(
      'Have a great day!',
      name: 'todayEnjoyableDay',
      desc: '',
      args: [],
    );
  }

  /// `It's very cold! Dress warmly and bring a scarf and gloves.`
  String get weatherCold {
    return Intl.message(
      'It\'s very cold! Dress warmly and bring a scarf and gloves.',
      name: 'weatherCold',
      desc: '',
      args: [],
    );
  }

  /// `It's very hot! Avoid outdoor activities and stay indoors with a cool drink.`
  String get weatherHot {
    return Intl.message(
      'It\'s very hot! Avoid outdoor activities and stay indoors with a cool drink.',
      name: 'weatherHot',
      desc: '',
      args: [],
    );
  }

  /// `It's raining, so be sure to bring an umbrella and look for indoor activities.`
  String get weatherRain {
    return Intl.message(
      'It\'s raining, so be sure to bring an umbrella and look for indoor activities.',
      name: 'weatherRain',
      desc: '',
      args: [],
    );
  }

  /// `It's snowing, so be careful of slippery roads, and how about a warm cup of tea?`
  String get weatherSnow {
    return Intl.message(
      'It\'s snowing, so be careful of slippery roads, and how about a warm cup of tea?',
      name: 'weatherSnow',
      desc: '',
      args: [],
    );
  }

  /// `It's a clear day! We recommend walking or outdoor activities.`
  String get weatherClear {
    return Intl.message(
      'It\'s a clear day! We recommend walking or outdoor activities.',
      name: 'weatherClear',
      desc: '',
      args: [],
    );
  }

  /// `It's cloudy. We recommend light indoor exercise or reading.`
  String get weatherClouds {
    return Intl.message(
      'It\'s cloudy. We recommend light indoor exercise or reading.',
      name: 'weatherClouds',
      desc: '',
      args: [],
    );
  }

  /// `\nYour battery is charging. How about watching a movie while it charges?`
  String get batteryCharging {
    return Intl.message(
      '\nYour battery is charging. How about watching a movie while it charges?',
      name: 'batteryCharging',
      desc: '',
      args: [],
    );
  }

  /// `\nBattery is low! We recommend bringing a power bank or connecting to power.`
  String get batteryLow {
    return Intl.message(
      '\nBattery is low! We recommend bringing a power bank or connecting to power.',
      name: 'batteryLow',
      desc: '',
      args: [],
    );
  }

  /// `phone charging station`
  String get phoneChargingStation {
    return Intl.message(
      'phone charging station',
      name: 'phoneChargingStation',
      desc: '',
      args: [],
    );
  }

  /// `\nYour battery is half full. We recommend activities that consume less power.`
  String get batteryHalf {
    return Intl.message(
      '\nYour battery is half full. We recommend activities that consume less power.',
      name: 'batteryHalf',
      desc: '',
      args: [],
    );
  }

  /// `\nYou are connected to Wi-Fi. Enjoy streaming services without worrying about data!`
  String get wifiConnected {
    return Intl.message(
      '\nYou are connected to Wi-Fi. Enjoy streaming services without worrying about data!',
      name: 'wifiConnected',
      desc: '',
      args: [],
    );
  }

  /// `\nYou are using mobile data. Be careful with activities that consume a lot of data.`
  String get mobileData {
    return Intl.message(
      '\nYou are using mobile data. Be careful with activities that consume a lot of data.',
      name: 'mobileData',
      desc: '',
      args: [],
    );
  }

  /// `\nNo internet connection. We recommend offline games or pre-downloaded content.`
  String get noInternet {
    return Intl.message(
      '\nNo internet connection. We recommend offline games or pre-downloaded content.',
      name: 'noInternet',
      desc: '',
      args: [],
    );
  }

  /// `public Wi-Fi`
  String get publicWifi {
    return Intl.message('public Wi-Fi', name: 'publicWifi', desc: '', args: []);
  }

  /// `Recommendation Based on Current Status`
  String get recommendationBasedOnCurrentStatus {
    return Intl.message(
      'Recommendation Based on Current Status',
      name: 'recommendationBasedOnCurrentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Map View`
  String get mapView {
    return Intl.message('Map View', name: 'mapView', desc: '', args: []);
  }

  /// `Failed to load posts: {error}`
  String postLoadFailed(Object error) {
    return Intl.message(
      'Failed to load posts: $error',
      name: 'postLoadFailed',
      desc: 'Error message for failed post loading',
      args: [error],
    );
  }

  /// `Create New Post`
  String get createPostTitle {
    return Intl.message(
      'Create New Post',
      name: 'createPostTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter title`
  String get postTitleHint {
    return Intl.message(
      'Enter title',
      name: 'postTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter content`
  String get postContentHint {
    return Intl.message(
      'Enter content',
      name: 'postContentHint',
      desc: '',
      args: [],
    );
  }

  /// `Write`
  String get writeButton {
    return Intl.message('Write', name: 'writeButton', desc: '', args: []);
  }

  /// `Title and content cannot be empty.`
  String get emptyPostFieldsWarning {
    return Intl.message(
      'Title and content cannot be empty.',
      name: 'emptyPostFieldsWarning',
      desc: '',
      args: [],
    );
  }

  /// `Post created successfully!`
  String get postCreatedSuccess {
    return Intl.message(
      'Post created successfully!',
      name: 'postCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create post: {error}`
  String postCreateFailed(Object error) {
    return Intl.message(
      'Failed to create post: $error',
      name: 'postCreateFailed',
      desc: 'Error message for failed post creation',
      args: [error],
    );
  }

  /// `No search results found.`
  String get noSearchResults {
    return Intl.message(
      'No search results found.',
      name: 'noSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `By {authorNickname} on {date}`
  String authorAndDate(Object authorNickname, Object date) {
    return Intl.message(
      'By $authorNickname on $date',
      name: 'authorAndDate',
      desc: 'Format for displaying author and creation date of a post',
      args: [authorNickname, date],
    );
  }

  /// `Board`
  String get boardTitle {
    return Intl.message('Board', name: 'boardTitle', desc: '', args: []);
  }

  /// `Enter search term...`
  String get searchHintText {
    return Intl.message(
      'Enter search term...',
      name: 'searchHintText',
      desc: '',
      args: [],
    );
  }

  /// `Add new post`
  String get addPostTooltip {
    return Intl.message(
      'Add new post',
      name: 'addPostTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Companion not found.`
  String get companionNotFound {
    return Intl.message(
      'Companion not found.',
      name: 'companionNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load companion: {error}`
  String companionLoadError(Object error) {
    return Intl.message(
      'Failed to load companion: $error',
      name: 'companionLoadError',
      desc: 'Error message for failed companion loading',
      args: [error],
    );
  }

  /// `Failed to load comments: {error}`
  String commentsLoadError(Object error) {
    return Intl.message(
      'Failed to load comments: $error',
      name: 'commentsLoadError',
      desc: 'Error message for failed comment loading',
      args: [error],
    );
  }

  /// `Failed to load requests: {error}`
  String requestsLoadError(Object error) {
    return Intl.message(
      'Failed to load requests: $error',
      name: 'requestsLoadError',
      desc: 'Error message for failed request loading',
      args: [error],
    );
  }

  /// `Failed to load participants: {error}`
  String participantsLoadError(Object error) {
    return Intl.message(
      'Failed to load participants: $error',
      name: 'participantsLoadError',
      desc: 'Error message for failed participant loading',
      args: [error],
    );
  }

  /// `Application not possible (closed or full).`
  String get companionApplicationNotPossible {
    return Intl.message(
      'Application not possible (closed or full).',
      name: 'companionApplicationNotPossible',
      desc: '',
      args: [],
    );
  }

  /// `Application sent successfully!`
  String get applicationSentSuccess {
    return Intl.message(
      'Application sent successfully!',
      name: 'applicationSentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send application: {error}`
  String applicationSendError(Object error) {
    return Intl.message(
      'Failed to send application: $error',
      name: 'applicationSendError',
      desc: 'Error message for failed application sending',
      args: [error],
    );
  }

  /// `Application cancelled successfully!`
  String get applicationCancelledSuccess {
    return Intl.message(
      'Application cancelled successfully!',
      name: 'applicationCancelledSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to cancel application: {error}`
  String applicationCancelError(Object error) {
    return Intl.message(
      'Failed to cancel application: $error',
      name: 'applicationCancelError',
      desc: 'Error message for failed application cancellation',
      args: [error],
    );
  }

  /// `Comment cannot be empty.`
  String get emptyCommentWarning {
    return Intl.message(
      'Comment cannot be empty.',
      name: 'emptyCommentWarning',
      desc: '',
      args: [],
    );
  }

  /// `Comment added successfully!`
  String get commentAddedSuccess {
    return Intl.message(
      'Comment added successfully!',
      name: 'commentAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add comment: {error}`
  String commentAddFailed(Object error) {
    return Intl.message(
      'Failed to add comment: $error',
      name: 'commentAddFailed',
      desc: 'Error message for failed comment addition',
      args: [error],
    );
  }

  /// `Delete Comment`
  String get deleteCommentTitle {
    return Intl.message(
      'Delete Comment',
      name: 'deleteCommentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this comment?`
  String get confirmDeleteComment {
    return Intl.message(
      'Are you sure you want to delete this comment?',
      name: 'confirmDeleteComment',
      desc: '',
      args: [],
    );
  }

  /// `Deleted comment.`
  String get deletedComment {
    return Intl.message(
      'Deleted comment.',
      name: 'deletedComment',
      desc: '',
      args: [],
    );
  }

  /// `Comment deleted successfully!`
  String get commentDeletedSuccess {
    return Intl.message(
      'Comment deleted successfully!',
      name: 'commentDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete comment: {error}`
  String commentDeleteFailed(Object error) {
    return Intl.message(
      'Failed to delete comment: $error',
      name: 'commentDeleteFailed',
      desc: 'Error message for failed comment deletion',
      args: [error],
    );
  }

  /// `Edit Comment`
  String get editCommentTitle {
    return Intl.message(
      'Edit Comment',
      name: 'editCommentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit your comment`
  String get editCommentHint {
    return Intl.message(
      'Edit your comment',
      name: 'editCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveButton {
    return Intl.message('Save', name: 'saveButton', desc: '', args: []);
  }

  /// `Comment edited successfully!`
  String get commentEditedSuccess {
    return Intl.message(
      'Comment edited successfully!',
      name: 'commentEditedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to edit comment: {error}`
  String commentEditFailed(Object error) {
    return Intl.message(
      'Failed to edit comment: $error',
      name: 'commentEditFailed',
      desc: 'Error message for failed comment editing',
      args: [error],
    );
  }

  /// `Recruitment is closed.`
  String get recruitmentClosedWarning {
    return Intl.message(
      'Recruitment is closed.',
      name: 'recruitmentClosedWarning',
      desc: '',
      args: [],
    );
  }

  /// `Maximum number of participants reached.`
  String get maxParticipantsReached {
    return Intl.message(
      'Maximum number of participants reached.',
      name: 'maxParticipantsReached',
      desc: '',
      args: [],
    );
  }

  /// `{userName} has been accepted!`
  String participantAcceptedSuccess(Object userName) {
    return Intl.message(
      '$userName has been accepted!',
      name: 'participantAcceptedSuccess',
      desc: 'Message when a participant is accepted',
      args: [userName],
    );
  }

  /// `Failed to accept request: {error}`
  String acceptRequestFailed(Object error) {
    return Intl.message(
      'Failed to accept request: $error',
      name: 'acceptRequestFailed',
      desc: 'Error message for failed request acceptance',
      args: [error],
    );
  }

  /// `Request rejected.`
  String get requestRejectedSuccess {
    return Intl.message(
      'Request rejected.',
      name: 'requestRejectedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to reject request: {error}`
  String rejectRequestFailed(Object error) {
    return Intl.message(
      'Failed to reject request: $error',
      name: 'rejectRequestFailed',
      desc: 'Error message for failed request rejection',
      args: [error],
    );
  }

  /// `Leave Companion`
  String get leaveCompanionTitle {
    return Intl.message(
      'Leave Companion',
      name: 'leaveCompanionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave this companion group?`
  String get confirmLeaveCompanion {
    return Intl.message(
      'Are you sure you want to leave this companion group?',
      name: 'confirmLeaveCompanion',
      desc: '',
      args: [],
    );
  }

  /// `Leave`
  String get leaveButton {
    return Intl.message('Leave', name: 'leaveButton', desc: '', args: []);
  }

  /// `You have left the companion group.`
  String get leftCompanionSuccess {
    return Intl.message(
      'You have left the companion group.',
      name: 'leftCompanionSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to leave companion: {error}`
  String leaveCompanionFailed(Object error) {
    return Intl.message(
      'Failed to leave companion: $error',
      name: 'leaveCompanionFailed',
      desc: 'Error message for failed companion leaving',
      args: [error],
    );
  }

  /// `Delete Companion`
  String get deleteCompanionTitle {
    return Intl.message(
      'Delete Companion',
      name: 'deleteCompanionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this companion post?`
  String get confirmDeleteCompanion {
    return Intl.message(
      'Are you sure you want to delete this companion post?',
      name: 'confirmDeleteCompanion',
      desc: '',
      args: [],
    );
  }

  /// `Companion post deleted successfully!`
  String get companionDeletedSuccess {
    return Intl.message(
      'Companion post deleted successfully!',
      name: 'companionDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete companion: {error}`
  String companionDeleteFailed(Object error) {
    return Intl.message(
      'Failed to delete companion: $error',
      name: 'companionDeleteFailed',
      desc: 'Error message for failed companion deletion',
      args: [error],
    );
  }

  /// `Error`
  String get errorText {
    return Intl.message('Error', name: 'errorText', desc: '', args: []);
  }

  /// `Companion data not found.`
  String get companionDataNotFound {
    return Intl.message(
      'Companion data not found.',
      name: 'companionDataNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Destination: {destination}`
  String destinationPrefix(Object destination) {
    return Intl.message(
      'Destination: $destination',
      name: 'destinationPrefix',
      desc: 'Prefix for the companion\'s destination',
      args: [destination],
    );
  }

  /// `Leader`
  String get leaderLabel {
    return Intl.message('Leader', name: 'leaderLabel', desc: '', args: []);
  }

  /// `Participants`
  String get participantsLabel {
    return Intl.message(
      'Participants',
      name: 'participantsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Period`
  String get periodLabel {
    return Intl.message('Period', name: 'periodLabel', desc: '', args: []);
  }

  /// `Content`
  String get contentLabel {
    return Intl.message('Content', name: 'contentLabel', desc: '', args: []);
  }

  /// `Leave Companion`
  String get leaveCompanionButton {
    return Intl.message(
      'Leave Companion',
      name: 'leaveCompanionButton',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Application`
  String get cancelApplicationButton {
    return Intl.message(
      'Cancel Application',
      name: 'cancelApplicationButton',
      desc: '',
      args: [],
    );
  }

  /// `Apply for Companion`
  String get applyForCompanionButton {
    return Intl.message(
      'Apply for Companion',
      name: 'applyForCompanionButton',
      desc: '',
      args: [],
    );
  }

  /// `Applicants List`
  String get applicantsListTitle {
    return Intl.message(
      'Applicants List',
      name: 'applicantsListTitle',
      desc: '',
      args: [],
    );
  }

  /// `No applicants currently.`
  String get noApplicants {
    return Intl.message(
      'No applicants currently.',
      name: 'noApplicants',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get acceptButton {
    return Intl.message('Accept', name: 'acceptButton', desc: '', args: []);
  }

  /// `Reject`
  String get rejectButton {
    return Intl.message('Reject', name: 'rejectButton', desc: '', args: []);
  }

  /// `Participants`
  String get participantsSectionTitle {
    return Intl.message(
      'Participants',
      name: 'participantsSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `No participants yet.`
  String get noParticipants {
    return Intl.message(
      'No participants yet.',
      name: 'noParticipants',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get commentsSectionTitle {
    return Intl.message(
      'Comments',
      name: 'commentsSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `No comments yet. Be the first to comment!`
  String get noCommentsYet {
    return Intl.message(
      'No comments yet. Be the first to comment!',
      name: 'noCommentsYet',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get replyButton {
    return Intl.message('Reply', name: 'replyButton', desc: '', args: []);
  }

  /// `(This comment has been deleted)`
  String get deletedCommentIndicator {
    return Intl.message(
      '(This comment has been deleted)',
      name: 'deletedCommentIndicator',
      desc: '',
      args: [],
    );
  }

  /// `Write a reply...`
  String get replyHint {
    return Intl.message(
      'Write a reply...',
      name: 'replyHint',
      desc: '',
      args: [],
    );
  }

  /// `Write Reply`
  String get writeReplyTitle {
    return Intl.message(
      'Write Reply',
      name: 'writeReplyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your reply...`
  String get replyContentHint {
    return Intl.message(
      'Enter your reply...',
      name: 'replyContentHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter your comment...`
  String get commentInputHint {
    return Intl.message(
      'Enter your comment...',
      name: 'commentInputHint',
      desc: '',
      args: [],
    );
  }

  /// `Add Comment`
  String get addCommentButton {
    return Intl.message(
      'Add Comment',
      name: 'addCommentButton',
      desc: '',
      args: [],
    );
  }

  /// `Recruitment Closed`
  String get recruitmentClosed {
    return Intl.message(
      'Recruitment Closed',
      name: 'recruitmentClosed',
      desc: '',
      args: [],
    );
  }

  /// `Initializing map...`
  String get initializingMap {
    return Intl.message(
      'Initializing map...',
      name: 'initializingMap',
      desc: '',
      args: [],
    );
  }

  /// `Place not found.`
  String get placeNotFound {
    return Intl.message(
      'Place not found.',
      name: 'placeNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load map: {error}`
  String mapLoadError(Object error) {
    return Intl.message(
      'Failed to load map: $error',
      name: 'mapLoadError',
      desc: 'Error message for map loading failure',
      args: [error],
    );
  }

  /// `Location permissions are denied.`
  String get locationPermissionDenied {
    return Intl.message(
      'Location permissions are denied.',
      name: 'locationPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Location permissions are permanently denied, we cannot request permissions.`
  String get locationPermissionDeniedForever {
    return Intl.message(
      'Location permissions are permanently denied, we cannot request permissions.',
      name: 'locationPermissionDeniedForever',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get current location: {error}`
  String locationFetchError(Object error) {
    return Intl.message(
      'Failed to get current location: $error',
      name: 'locationFetchError',
      desc: 'Error message for current location fetching failure',
      args: [error],
    );
  }

  /// `Loading places...`
  String get loadingPlaces {
    return Intl.message(
      'Loading places...',
      name: 'loadingPlaces',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load places: {error}`
  String placeLoadError(Object error) {
    return Intl.message(
      'Failed to load places: $error',
      name: 'placeLoadError',
      desc: 'Error message for place loading failure',
      args: [error],
    );
  }

  /// `Loading public Wi-Fi...`
  String get loadingWifi {
    return Intl.message(
      'Loading public Wi-Fi...',
      name: 'loadingWifi',
      desc: '',
      args: [],
    );
  }

  /// `Public Wi-Fi`
  String get wifiMarkerSnippet {
    return Intl.message(
      'Public Wi-Fi',
      name: 'wifiMarkerSnippet',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load public Wi-Fi: {error}`
  String wifiLoadError(Object error) {
    return Intl.message(
      'Failed to load public Wi-Fi: $error',
      name: 'wifiLoadError',
      desc: 'Error message for public Wi-Fi loading failure',
      args: [error],
    );
  }

  /// `Subcategory`
  String get subcategoryLabel {
    return Intl.message(
      'Subcategory',
      name: 'subcategoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Free Admission`
  String get freeAdmission {
    return Intl.message(
      'Free Admission',
      name: 'freeAdmission',
      desc: '',
      args: [],
    );
  }

  /// `Paid Admission`
  String get paidAdmission {
    return Intl.message(
      'Paid Admission',
      name: 'paidAdmission',
      desc: '',
      args: [],
    );
  }

  /// `This is an encrypted facility.`
  String get encryptedFacilityWarning {
    return Intl.message(
      'This is an encrypted facility.',
      name: 'encryptedFacilityWarning',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get reviewsTitle {
    return Intl.message('Reviews', name: 'reviewsTitle', desc: '', args: []);
  }

  /// `Add New Place`
  String get addPlaceTitle {
    return Intl.message(
      'Add New Place',
      name: 'addPlaceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter place name`
  String get placeNameHint {
    return Intl.message(
      'Enter place name',
      name: 'placeNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter address`
  String get placeAddressHint {
    return Intl.message(
      'Enter address',
      name: 'placeAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `Address search failed.`
  String get addressSearchFailed {
    return Intl.message(
      'Address search failed.',
      name: 'addressSearchFailed',
      desc: '',
      args: [],
    );
  }

  /// `Encrypted Facility?`
  String get isEncryptedLabel {
    return Intl.message(
      'Encrypted Facility?',
      name: 'isEncryptedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Free Admission?`
  String get isFreeLabel {
    return Intl.message(
      'Free Admission?',
      name: 'isFreeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get addButton {
    return Intl.message('Add', name: 'addButton', desc: '', args: []);
  }

  /// `Name and address cannot be empty.`
  String get emptyFieldsWarning {
    return Intl.message(
      'Name and address cannot be empty.',
      name: 'emptyFieldsWarning',
      desc: '',
      args: [],
    );
  }

  /// `Could not find coordinates for the address.`
  String get invalidAddressError {
    return Intl.message(
      'Could not find coordinates for the address.',
      name: 'invalidAddressError',
      desc: '',
      args: [],
    );
  }

  /// `Place added successfully!`
  String get placeAddedSuccess {
    return Intl.message(
      'Place added successfully!',
      name: 'placeAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add place: {error}`
  String placeAddFailed(Object error) {
    return Intl.message(
      'Failed to add place: $error',
      name: 'placeAddFailed',
      desc: 'Error message for place adding failure',
      args: [error],
    );
  }

  /// `Edit Place`
  String get editPlaceTitle {
    return Intl.message(
      'Edit Place',
      name: 'editPlaceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Place updated successfully!`
  String get placeUpdatedSuccess {
    return Intl.message(
      'Place updated successfully!',
      name: 'placeUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update place: {error}`
  String placeUpdateFailed(Object error) {
    return Intl.message(
      'Failed to update place: $error',
      name: 'placeUpdateFailed',
      desc: 'Error message for place updating failure',
      args: [error],
    );
  }

  /// `Delete Place`
  String get deletePlaceTitle {
    return Intl.message(
      'Delete Place',
      name: 'deletePlaceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this place?`
  String get confirmDeletePlace {
    return Intl.message(
      'Are you sure you want to delete this place?',
      name: 'confirmDeletePlace',
      desc: '',
      args: [],
    );
  }

  /// `Place deleted successfully!`
  String get placeDeletedSuccess {
    return Intl.message(
      'Place deleted successfully!',
      name: 'placeDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete place: {error}`
  String placeDeleteFailed(Object error) {
    return Intl.message(
      'Failed to delete place: $error',
      name: 'placeDeleteFailed',
      desc: 'Error message for place deletion failure',
      args: [error],
    );
  }

  /// `Failed to load reviews: {error}`
  String reviewLoadFailed(Object error) {
    return Intl.message(
      'Failed to load reviews: $error',
      name: 'reviewLoadFailed',
      desc: 'Error message for review loading failure',
      args: [error],
    );
  }

  /// `Please enter a rating and comment.`
  String get reviewFieldsEmptyWarning {
    return Intl.message(
      'Please enter a rating and comment.',
      name: 'reviewFieldsEmptyWarning',
      desc: '',
      args: [],
    );
  }

  /// `Review added successfully!`
  String get reviewAddedSuccess {
    return Intl.message(
      'Review added successfully!',
      name: 'reviewAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add review: {error}`
  String reviewAddFailed(Object error) {
    return Intl.message(
      'Failed to add review: $error',
      name: 'reviewAddFailed',
      desc: 'Error message for review adding failure',
      args: [error],
    );
  }

  /// `Uploading image...`
  String get uploadingImage {
    return Intl.message(
      'Uploading image...',
      name: 'uploadingImage',
      desc: '',
      args: [],
    );
  }

  /// `Image compression failed.`
  String get imageCompressionFailed {
    return Intl.message(
      'Image compression failed.',
      name: 'imageCompressionFailed',
      desc: '',
      args: [],
    );
  }

  /// `Image uploaded successfully!`
  String get imageUploadSuccess {
    return Intl.message(
      'Image uploaded successfully!',
      name: 'imageUploadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload image: {error}`
  String imageUploadFailed(Object error) {
    return Intl.message(
      'Failed to upload image: $error',
      name: 'imageUploadFailed',
      desc: 'Error message for image upload failure',
      args: [error],
    );
  }

  /// `Removed from favorites.`
  String get removedFromFavorites {
    return Intl.message(
      'Removed from favorites.',
      name: 'removedFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Added to favorites!`
  String get addedToFavorites {
    return Intl.message(
      'Added to favorites!',
      name: 'addedToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Failed to toggle favorite: {error}`
  String favoriteToggleFailed(Object error) {
    return Intl.message(
      'Failed to toggle favorite: $error',
      name: 'favoriteToggleFailed',
      desc: 'Error message for favorite toggle failure',
      args: [error],
    );
  }

  /// `Historical Sites`
  String get historicalSites {
    return Intl.message(
      'Historical Sites',
      name: 'historicalSites',
      desc: '',
      args: [],
    );
  }

  /// `Natural Landmarks`
  String get naturalLandmarks {
    return Intl.message(
      'Natural Landmarks',
      name: 'naturalLandmarks',
      desc: '',
      args: [],
    );
  }

  /// `Parks/Gardens`
  String get parksGardens {
    return Intl.message(
      'Parks/Gardens',
      name: 'parksGardens',
      desc: '',
      args: [],
    );
  }

  /// `Theme Parks`
  String get themeParks {
    return Intl.message('Theme Parks', name: 'themeParks', desc: '', args: []);
  }

  /// `Art/Museums`
  String get artMuseums {
    return Intl.message('Art/Museums', name: 'artMuseums', desc: '', args: []);
  }

  /// `Other Attractions`
  String get otherAttractions {
    return Intl.message(
      'Other Attractions',
      name: 'otherAttractions',
      desc: '',
      args: [],
    );
  }

  /// `Korean Food`
  String get koreanFood {
    return Intl.message('Korean Food', name: 'koreanFood', desc: '', args: []);
  }

  /// `Western Food`
  String get westernFood {
    return Intl.message(
      'Western Food',
      name: 'westernFood',
      desc: '',
      args: [],
    );
  }

  /// `Asian Food`
  String get asianFood {
    return Intl.message('Asian Food', name: 'asianFood', desc: '', args: []);
  }

  /// `Cafes/Desserts`
  String get cafesDesserts {
    return Intl.message(
      'Cafes/Desserts',
      name: 'cafesDesserts',
      desc: '',
      args: [],
    );
  }

  /// `Bars/Pubs`
  String get barsPubs {
    return Intl.message('Bars/Pubs', name: 'barsPubs', desc: '', args: []);
  }

  /// `Other Food`
  String get otherFood {
    return Intl.message('Other Food', name: 'otherFood', desc: '', args: []);
  }

  /// `Hotels`
  String get hotels {
    return Intl.message('Hotels', name: 'hotels', desc: '', args: []);
  }

  /// `Motels`
  String get motels {
    return Intl.message('Motels', name: 'motels', desc: '', args: []);
  }

  /// `Guesthouses`
  String get guesthouses {
    return Intl.message('Guesthouses', name: 'guesthouses', desc: '', args: []);
  }

  /// `Hanoks`
  String get hanoks {
    return Intl.message('Hanoks', name: 'hanoks', desc: '', args: []);
  }

  /// `Resorts`
  String get resorts {
    return Intl.message('Resorts', name: 'resorts', desc: '', args: []);
  }

  /// `Other Accommodations`
  String get otherAccommodations {
    return Intl.message(
      'Other Accommodations',
      name: 'otherAccommodations',
      desc: '',
      args: [],
    );
  }

  /// `Performance Halls`
  String get performanceHalls {
    return Intl.message(
      'Performance Halls',
      name: 'performanceHalls',
      desc: '',
      args: [],
    );
  }

  /// `Exhibition Halls`
  String get exhibitionHalls {
    return Intl.message(
      'Exhibition Halls',
      name: 'exhibitionHalls',
      desc: '',
      args: [],
    );
  }

  /// `Libraries`
  String get libraries {
    return Intl.message('Libraries', name: 'libraries', desc: '', args: []);
  }

  /// `Bookstores`
  String get bookstores {
    return Intl.message('Bookstores', name: 'bookstores', desc: '', args: []);
  }

  /// `Cinemas`
  String get cinemas {
    return Intl.message('Cinemas', name: 'cinemas', desc: '', args: []);
  }

  /// `Other Culture`
  String get otherCulture {
    return Intl.message(
      'Other Culture',
      name: 'otherCulture',
      desc: '',
      args: [],
    );
  }

  /// `Hiking Trails`
  String get hikingTrails {
    return Intl.message(
      'Hiking Trails',
      name: 'hikingTrails',
      desc: '',
      args: [],
    );
  }

  /// `Cycling Paths`
  String get cyclingPaths {
    return Intl.message(
      'Cycling Paths',
      name: 'cyclingPaths',
      desc: '',
      args: [],
    );
  }

  /// `Water Sports`
  String get waterSports {
    return Intl.message(
      'Water Sports',
      name: 'waterSports',
      desc: '',
      args: [],
    );
  }

  /// `Winter Sports`
  String get winterSports {
    return Intl.message(
      'Winter Sports',
      name: 'winterSports',
      desc: '',
      args: [],
    );
  }

  /// `Indoor Sports`
  String get indoorSports {
    return Intl.message(
      'Indoor Sports',
      name: 'indoorSports',
      desc: '',
      args: [],
    );
  }

  /// `Other Leisure`
  String get otherLeisure {
    return Intl.message(
      'Other Leisure',
      name: 'otherLeisure',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get mapScreenTitle {
    return Intl.message('Map', name: 'mapScreenTitle', desc: '', args: []);
  }

  /// `Search for places...`
  String get searchPlacesHint {
    return Intl.message(
      'Search for places...',
      name: 'searchPlacesHint',
      desc: '',
      args: [],
    );
  }

  /// `All Categories`
  String get allCategories {
    return Intl.message(
      'All Categories',
      name: 'allCategories',
      desc: '',
      args: [],
    );
  }

  /// `Add Place`
  String get addPlaceTooltip {
    return Intl.message(
      'Add Place',
      name: 'addPlaceTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Write your review...`
  String get reviewHint {
    return Intl.message(
      'Write your review...',
      name: 'reviewHint',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get uploadImageTooltip {
    return Intl.message(
      'Upload Image',
      name: 'uploadImageTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Add Review`
  String get addReviewButton {
    return Intl.message(
      'Add Review',
      name: 'addReviewButton',
      desc: '',
      args: [],
    );
  }

  /// `No reviews yet. Be the first to add one!`
  String get noReviewsYet {
    return Intl.message(
      'No reviews yet. Be the first to add one!',
      name: 'noReviewsYet',
      desc: '',
      args: [],
    );
  }

  /// `Etc.`
  String get etcCategory {
    return Intl.message('Etc.', name: 'etcCategory', desc: '', args: []);
  }

  /// `Category`
  String get categoryLabel {
    return Intl.message('Category', name: 'categoryLabel', desc: '', args: []);
  }

  /// `Address`
  String get addressLabel {
    return Intl.message('Address', name: 'addressLabel', desc: '', args: []);
  }

  /// `Installation Agency`
  String get installationAgencyLabel {
    return Intl.message(
      'Installation Agency',
      name: 'installationAgencyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Post Details`
  String get postDetailTitle {
    return Intl.message(
      'Post Details',
      name: 'postDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get authorLabel {
    return Intl.message('Author', name: 'authorLabel', desc: '', args: []);
  }

  /// `Comments`
  String get commentsTitle {
    return Intl.message('Comments', name: 'commentsTitle', desc: '', args: []);
  }

  /// `Reply to`
  String get replyPrefix {
    return Intl.message('Reply to', name: 'replyPrefix', desc: '', args: []);
  }

  /// `Enter your reply...`
  String get enterReplyHint {
    return Intl.message(
      'Enter your reply...',
      name: 'enterReplyHint',
      desc: '',
      args: [],
    );
  }

  /// `Post`
  String get postButton {
    return Intl.message('Post', name: 'postButton', desc: '', args: []);
  }

  /// `Enter your comment...`
  String get enterCommentHint {
    return Intl.message(
      'Enter your comment...',
      name: 'enterCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load comments: {error}`
  String failedToLoadComments(Object error) {
    return Intl.message(
      'Failed to load comments: $error',
      name: 'failedToLoadComments',
      desc: 'Error message for failed comment loading',
      args: [error],
    );
  }

  /// `Comment cannot be empty.`
  String get commentEmptyWarning {
    return Intl.message(
      'Comment cannot be empty.',
      name: 'commentEmptyWarning',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add comment: {error}`
  String failedToAddComment(Object error) {
    return Intl.message(
      'Failed to add comment: $error',
      name: 'failedToAddComment',
      desc: 'Error message for failed comment adding',
      args: [error],
    );
  }

  /// `Comment updated successfully!`
  String get commentUpdatedSuccess {
    return Intl.message(
      'Comment updated successfully!',
      name: 'commentUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update comment: {error}`
  String failedToUpdateComment(Object error) {
    return Intl.message(
      'Failed to update comment: $error',
      name: 'failedToUpdateComment',
      desc: 'Error message for failed comment updating',
      args: [error],
    );
  }

  /// `Failed to delete comment: {error}`
  String failedToDeleteComment(Object error) {
    return Intl.message(
      'Failed to delete comment: $error',
      name: 'failedToDeleteComment',
      desc: 'Error message for failed comment deletion',
      args: [error],
    );
  }

  /// `Reply cannot be empty.`
  String get replyEmptyWarning {
    return Intl.message(
      'Reply cannot be empty.',
      name: 'replyEmptyWarning',
      desc: '',
      args: [],
    );
  }

  /// `Reply added successfully!`
  String get replyAddedSuccess {
    return Intl.message(
      'Reply added successfully!',
      name: 'replyAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add reply: {error}`
  String failedToAddReply(Object error) {
    return Intl.message(
      'Failed to add reply: $error',
      name: 'failedToAddReply',
      desc: 'Error message for failed reply adding',
      args: [error],
    );
  }

  /// `Reply updated successfully!`
  String get replyUpdatedSuccess {
    return Intl.message(
      'Reply updated successfully!',
      name: 'replyUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update reply: {error}`
  String failedToUpdateReply(Object error) {
    return Intl.message(
      'Failed to update reply: $error',
      name: 'failedToUpdateReply',
      desc: 'Error message for failed reply updating',
      args: [error],
    );
  }

  /// `Delete Reply`
  String get deleteReplyTitle {
    return Intl.message(
      'Delete Reply',
      name: 'deleteReplyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this reply?`
  String get confirmDeleteReply {
    return Intl.message(
      'Are you sure you want to delete this reply?',
      name: 'confirmDeleteReply',
      desc: '',
      args: [],
    );
  }

  /// `Reply deleted successfully!`
  String get replyDeletedSuccess {
    return Intl.message(
      'Reply deleted successfully!',
      name: 'replyDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete reply: {error}`
  String failedToDeleteReply(Object error) {
    return Intl.message(
      'Failed to delete reply: $error',
      name: 'failedToDeleteReply',
      desc: 'Error message for failed reply deletion',
      args: [error],
    );
  }

  /// `No reviews`
  String get noReviews {
    return Intl.message('No reviews', name: 'noReviews', desc: '', args: []);
  }

  /// `Search`
  String get searchButton {
    return Intl.message('Search', name: 'searchButton', desc: '', args: []);
  }

  /// `Filter`
  String get filterButton {
    return Intl.message('Filter', name: 'filterButton', desc: '', args: []);
  }

  /// `Getting current location...`
  String get gettingCurrentLocation {
    return Intl.message(
      'Getting current location...',
      name: 'gettingCurrentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Syncing Firestore data...`
  String get syncingFirestoreData {
    return Intl.message(
      'Syncing Firestore data...',
      name: 'syncingFirestoreData',
      desc: '',
      args: [],
    );
  }

  /// `Loading Kakao places...`
  String get loadingKakaoPlaces {
    return Intl.message(
      'Loading Kakao places...',
      name: 'loadingKakaoPlaces',
      desc: '',
      args: [],
    );
  }

  /// `Loading public Wi-Fi hotspots...`
  String get loadingPublicWifiHotspots {
    return Intl.message(
      'Loading public Wi-Fi hotspots...',
      name: 'loadingPublicWifiHotspots',
      desc: '',
      args: [],
    );
  }

  /// `Location services are disabled.`
  String get locationServiceDisabled {
    return Intl.message(
      'Location services are disabled.',
      name: 'locationServiceDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred`
  String get errorOccurred {
    return Intl.message(
      'Error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `No place found.`
  String get noPlaceFound {
    return Intl.message(
      'No place found.',
      name: 'noPlaceFound',
      desc: '',
      args: [],
    );
  }

  /// `No place found for '{keyword}'.`
  String noPlaceFoundForKeyword(Object keyword) {
    return Intl.message(
      'No place found for \'$keyword\'.',
      name: 'noPlaceFoundForKeyword',
      desc: 'Message when no place is found for a specific keyword',
      args: [keyword],
    );
  }

  /// `Failed to search place: {error}`
  String failedToSearchPlace(Object error) {
    return Intl.message(
      'Failed to search place: $error',
      name: 'failedToSearchPlace',
      desc: 'Error message for failed place search',
      args: [error],
    );
  }

  /// `Encrypted location`
  String get encryptedLocation {
    return Intl.message(
      'Encrypted location',
      name: 'encryptedLocation',
      desc: '',
      args: [],
    );
  }

  /// `Write a Review`
  String get writeReviewTitle {
    return Intl.message(
      'Write a Review',
      name: 'writeReviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your review here...`
  String get reviewInputHint {
    return Intl.message(
      'Enter your review here...',
      name: 'reviewInputHint',
      desc: '',
      args: [],
    );
  }

  /// `Select Image`
  String get selectImageButton {
    return Intl.message(
      'Select Image',
      name: 'selectImageButton',
      desc: '',
      args: [],
    );
  }

  /// `Submit Review`
  String get submitReviewButton {
    return Intl.message(
      'Submit Review',
      name: 'submitReviewButton',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add review: {error}`
  String failedToAddReview(Object error) {
    return Intl.message(
      'Failed to add review: $error',
      name: 'failedToAddReview',
      desc: 'Error message for failed review adding',
      args: [error],
    );
  }

  /// `Filter by Categories`
  String get filterByCategories {
    return Intl.message(
      'Filter by Categories',
      name: 'filterByCategories',
      desc: '',
      args: [],
    );
  }

  /// `Invalid address. Please try again.`
  String get invalidAddress {
    return Intl.message(
      'Invalid address. Please try again.',
      name: 'invalidAddress',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add place: {error}`
  String failedToAddPlace(Object error) {
    return Intl.message(
      'Failed to add place: $error',
      name: 'failedToAddPlace',
      desc: 'Error message for failed place adding',
      args: [error],
    );
  }

  /// `Landmark`
  String get categoryLandmark {
    return Intl.message(
      'Landmark',
      name: 'categoryLandmark',
      desc: '',
      args: [],
    );
  }

  /// `Accommodation`
  String get categoryAccommodation {
    return Intl.message(
      'Accommodation',
      name: 'categoryAccommodation',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant`
  String get categoryRestaurant {
    return Intl.message(
      'Restaurant',
      name: 'categoryRestaurant',
      desc: '',
      args: [],
    );
  }

  /// `Transportation`
  String get categoryTransportation {
    return Intl.message(
      'Transportation',
      name: 'categoryTransportation',
      desc: '',
      args: [],
    );
  }

  /// `Etc`
  String get categoryEtc {
    return Intl.message('Etc', name: 'categoryEtc', desc: '', args: []);
  }

  /// `History`
  String get subcategoryHistory {
    return Intl.message(
      'History',
      name: 'subcategoryHistory',
      desc: '',
      args: [],
    );
  }

  /// `Nature`
  String get subcategoryNature {
    return Intl.message(
      'Nature',
      name: 'subcategoryNature',
      desc: '',
      args: [],
    );
  }

  /// `Culture`
  String get subcategoryCulture {
    return Intl.message(
      'Culture',
      name: 'subcategoryCulture',
      desc: '',
      args: [],
    );
  }

  /// `Leisure`
  String get subcategoryLeisure {
    return Intl.message(
      'Leisure',
      name: 'subcategoryLeisure',
      desc: '',
      args: [],
    );
  }

  /// `Hotel`
  String get subcategoryHotel {
    return Intl.message('Hotel', name: 'subcategoryHotel', desc: '', args: []);
  }

  /// `Motel`
  String get subcategoryMotel {
    return Intl.message('Motel', name: 'subcategoryMotel', desc: '', args: []);
  }

  /// `Guest House`
  String get subcategoryGuestHouse {
    return Intl.message(
      'Guest House',
      name: 'subcategoryGuestHouse',
      desc: '',
      args: [],
    );
  }

  /// `Resort`
  String get subcategoryResort {
    return Intl.message(
      'Resort',
      name: 'subcategoryResort',
      desc: '',
      args: [],
    );
  }

  /// `Camping`
  String get subcategoryCamping {
    return Intl.message(
      'Camping',
      name: 'subcategoryCamping',
      desc: '',
      args: [],
    );
  }

  /// `Korean Food`
  String get subcategoryKoreanFood {
    return Intl.message(
      'Korean Food',
      name: 'subcategoryKoreanFood',
      desc: '',
      args: [],
    );
  }

  /// `Chinese Food`
  String get subcategoryChineseFood {
    return Intl.message(
      'Chinese Food',
      name: 'subcategoryChineseFood',
      desc: '',
      args: [],
    );
  }

  /// `Japanese Food`
  String get subcategoryJapaneseFood {
    return Intl.message(
      'Japanese Food',
      name: 'subcategoryJapaneseFood',
      desc: '',
      args: [],
    );
  }

  /// `Western Food`
  String get subcategoryWesternFood {
    return Intl.message(
      'Western Food',
      name: 'subcategoryWesternFood',
      desc: '',
      args: [],
    );
  }

  /// `Cafe`
  String get subcategoryCafe {
    return Intl.message('Cafe', name: 'subcategoryCafe', desc: '', args: []);
  }

  /// `Bus Terminal`
  String get subcategoryBusTerminal {
    return Intl.message(
      'Bus Terminal',
      name: 'subcategoryBusTerminal',
      desc: '',
      args: [],
    );
  }

  /// `Train Station`
  String get subcategoryTrainStation {
    return Intl.message(
      'Train Station',
      name: 'subcategoryTrainStation',
      desc: '',
      args: [],
    );
  }

  /// `Airport`
  String get subcategoryAirport {
    return Intl.message(
      'Airport',
      name: 'subcategoryAirport',
      desc: '',
      args: [],
    );
  }

  /// `Port`
  String get subcategoryPort {
    return Intl.message('Port', name: 'subcategoryPort', desc: '', args: []);
  }

  /// `Convenience Facilities`
  String get subcategoryConvenience {
    return Intl.message(
      'Convenience Facilities',
      name: 'subcategoryConvenience',
      desc: '',
      args: [],
    );
  }

  /// `Public Institution`
  String get subcategoryPublicInstitution {
    return Intl.message(
      'Public Institution',
      name: 'subcategoryPublicInstitution',
      desc: '',
      args: [],
    );
  }

  /// `Hospital`
  String get subcategoryHospital {
    return Intl.message(
      'Hospital',
      name: 'subcategoryHospital',
      desc: '',
      args: [],
    );
  }

  /// `Police Station`
  String get subcategoryPoliceStation {
    return Intl.message(
      'Police Station',
      name: 'subcategoryPoliceStation',
      desc: '',
      args: [],
    );
  }

  /// `Data synchronization in progress...`
  String get dataSyncMessage {
    return Intl.message(
      'Data synchronization in progress...',
      name: 'dataSyncMessage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get location information: {error}`
  String failedToGetLocation(Object error) {
    return Intl.message(
      'Failed to get location information: $error',
      name: 'failedToGetLocation',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to load marker icons: {error}`
  String failedToLoadMarkerIcons(Object error) {
    return Intl.message(
      'Failed to load marker icons: $error',
      name: 'failedToLoadMarkerIcons',
      desc: '',
      args: [error],
    );
  }

  /// `Data synchronization skipped. Loading existing data.`
  String get dataSyncSkipped {
    return Intl.message(
      'Data synchronization skipped. Loading existing data.',
      name: 'dataSyncSkipped',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing pharmacy locations...`
  String get pharmacySyncing {
    return Intl.message(
      'Synchronizing pharmacy locations...',
      name: 'pharmacySyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing police stations...`
  String get policeStationSyncing {
    return Intl.message(
      'Synchronizing police stations...',
      name: 'policeStationSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing ATM locations...`
  String get atmSyncing {
    return Intl.message(
      'Synchronizing ATM locations...',
      name: 'atmSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing bank locations...`
  String get bankSyncing {
    return Intl.message(
      'Synchronizing bank locations...',
      name: 'bankSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing currency exchange locations...`
  String get currencyExchangeSyncing {
    return Intl.message(
      'Synchronizing currency exchange locations...',
      name: 'currencyExchangeSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing public toilets...`
  String get publicToiletSyncing {
    return Intl.message(
      'Synchronizing public toilets...',
      name: 'publicToiletSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing lockers...`
  String get lockerSyncing {
    return Intl.message(
      'Synchronizing lockers...',
      name: 'lockerSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing public Wi-Fi...`
  String get publicWifiSyncing {
    return Intl.message(
      'Synchronizing public Wi-Fi...',
      name: 'publicWifiSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing cafes...`
  String get cafeSyncing {
    return Intl.message(
      'Synchronizing cafes...',
      name: 'cafeSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing restaurants...`
  String get restaurantSyncing {
    return Intl.message(
      'Synchronizing restaurants...',
      name: 'restaurantSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing landmarks...`
  String get landmarkSyncing {
    return Intl.message(
      'Synchronizing landmarks...',
      name: 'landmarkSyncing',
      desc: '',
      args: [],
    );
  }

  /// `Data synchronization complete`
  String get dataSyncComplete {
    return Intl.message(
      'Data synchronization complete',
      name: 'dataSyncComplete',
      desc: '',
      args: [],
    );
  }

  /// `Data synchronization failed: Please check your network connection or try again later. (Error: {error})`
  String dataSyncFailed(Object error) {
    return Intl.message(
      'Data synchronization failed: Please check your network connection or try again later. (Error: $error)',
      name: 'dataSyncFailed',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while updating favorites. Please check your network.`
  String get failedToUpdateFavorites {
    return Intl.message(
      'An error occurred while updating favorites. Please check your network.',
      name: 'failedToUpdateFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Place Details`
  String get placeDetailsTitle {
    return Intl.message(
      'Place Details',
      name: 'placeDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Address: {address}`
  String address(Object address) {
    return Intl.message(
      'Address: $address',
      name: 'address',
      desc: '',
      args: [address],
    );
  }

  /// `No Address Info`
  String get noAddressInfo {
    return Intl.message(
      'No Address Info',
      name: 'noAddressInfo',
      desc: '',
      args: [],
    );
  }

  /// `Average Rating: {rating}`
  String averageRating(Object rating) {
    return Intl.message(
      'Average Rating: $rating',
      name: 'averageRating',
      desc: '',
      args: [rating],
    );
  }

  /// `Comments:`
  String get comments {
    return Intl.message('Comments:', name: 'comments', desc: '', args: []);
  }

  /// `No comments yet.`
  String get noComments {
    return Intl.message(
      'No comments yet.',
      name: 'noComments',
      desc: '',
      args: [],
    );
  }

  /// `Author: {nickname}`
  String commentAuthor(Object nickname) {
    return Intl.message(
      'Author: $nickname',
      name: 'commentAuthor',
      desc: '',
      args: [nickname],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Delete Review`
  String get deleteReview {
    return Intl.message(
      'Delete Review',
      name: 'deleteReview',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this review?`
  String get deleteReviewConfirm {
    return Intl.message(
      'Are you sure you want to delete this review?',
      name: 'deleteReviewConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Add Comment`
  String get addComment {
    return Intl.message('Add Comment', name: 'addComment', desc: '', args: []);
  }

  /// `Failed to load user information. Please try again later.`
  String get failedToLoadUserInfo {
    return Intl.message(
      'Failed to load user information. Please try again later.',
      name: 'failedToLoadUserInfo',
      desc: '',
      args: [],
    );
  }

  /// `Rating: {rating}`
  String rating(Object rating) {
    return Intl.message(
      'Rating: $rating',
      name: 'rating',
      desc: '',
      args: [rating],
    );
  }

  /// `Attach Photo`
  String get attachPhoto {
    return Intl.message(
      'Attach Photo',
      name: 'attachPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Image upload failed. Please try again.`
  String get failedToUploadImage {
    return Intl.message(
      'Image upload failed. Please try again.',
      name: 'failedToUploadImage',
      desc: '',
      args: [],
    );
  }

  /// `{subcategory} Added`
  String newPlaceAdded(Object subcategory) {
    return Intl.message(
      '$subcategory Added',
      name: 'newPlaceAdded',
      desc: '',
      args: [subcategory],
    );
  }

  /// `Place Name (Required)`
  String get placeNameRequired {
    return Intl.message(
      'Place Name (Required)',
      name: 'placeNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Address (Required, e.g., Daehak-ro 52-1)`
  String get addressRequired {
    return Intl.message(
      'Address (Required, e.g., Daehak-ro 52-1)',
      name: 'addressRequired',
      desc: '',
      args: [],
    );
  }

  /// `Free/Paid:`
  String get freePaid {
    return Intl.message('Free/Paid:', name: 'freePaid', desc: '', args: []);
  }

  /// `Free`
  String get free {
    return Intl.message('Free', name: 'free', desc: '', args: []);
  }

  /// `Paid`
  String get paid {
    return Intl.message('Paid', name: 'paid', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Search Map`
  String get searchMap {
    return Intl.message('Search Map', name: 'searchMap', desc: '', args: []);
  }

  /// `Enter place name or address`
  String get searchPlaceholder {
    return Intl.message(
      'Enter place name or address',
      name: 'searchPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Refresh Data`
  String get refreshData {
    return Intl.message(
      'Refresh Data',
      name: 'refreshData',
      desc: '',
      args: [],
    );
  }

  /// `Select Location`
  String get selectLocation {
    return Intl.message(
      'Select Location',
      name: 'selectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Place name and address are required.`
  String get placeNameAndAddressRequired {
    return Intl.message(
      'Place name and address are required.',
      name: 'placeNameAndAddressRequired',
      desc: '',
      args: [],
    );
  }

  /// `Searching for '{query}'...`
  String searching(Object query) {
    return Intl.message(
      'Searching for \'$query\'...',
      name: 'searching',
      desc: '',
      args: [query],
    );
  }

  /// `Showing results for '{query}': {placeName}`
  String searchResultsDisplayed(Object query, Object placeName) {
    return Intl.message(
      'Showing results for \'$query\': $placeName',
      name: 'searchResultsDisplayed',
      desc: '',
      args: [query, placeName],
    );
  }

  /// `No search results found for '{query}'.`
  String noSearchResultsForQuery(Object query) {
    return Intl.message(
      'No search results found for \'$query\'.',
      name: 'noSearchResultsForQuery',
      desc: '',
      args: [query],
    );
  }

  /// `Map search failed: {error}`
  String mapSearchError(Object error) {
    return Intl.message(
      'Map search failed: $error',
      name: 'mapSearchError',
      desc: '',
      args: [error],
    );
  }

  /// `Search failed: {error}`
  String searchFailed(Object error) {
    return Intl.message(
      'Search failed: $error',
      name: 'searchFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Current Location`
  String get currentLocation {
    return Intl.message(
      'Current Location',
      name: 'currentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Map is loading. Please wait...`
  String get mapLoadingWait {
    return Intl.message(
      'Map is loading. Please wait...',
      name: 'mapLoadingWait',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get mapTitle {
    return Intl.message('Map', name: 'mapTitle', desc: '', args: []);
  }

  /// `Hospital`
  String get hospital {
    return Intl.message('Hospital', name: 'hospital', desc: '', args: []);
  }

  /// `Pharmacy`
  String get pharmacy {
    return Intl.message('Pharmacy', name: 'pharmacy', desc: '', args: []);
  }

  /// `Police Station`
  String get policeStation {
    return Intl.message(
      'Police Station',
      name: 'policeStation',
      desc: '',
      args: [],
    );
  }

  /// `ATM`
  String get atm {
    return Intl.message('ATM', name: 'atm', desc: '', args: []);
  }

  /// `Bank`
  String get bank {
    return Intl.message('Bank', name: 'bank', desc: '', args: []);
  }

  /// `Currency Exchange`
  String get currencyExchange {
    return Intl.message(
      'Currency Exchange',
      name: 'currencyExchange',
      desc: '',
      args: [],
    );
  }

  /// `Public Restroom`
  String get publicRestroom {
    return Intl.message(
      'Public Restroom',
      name: 'publicRestroom',
      desc: '',
      args: [],
    );
  }

  /// `Public Toilet`
  String get publicToilet {
    return Intl.message(
      'Public Toilet',
      name: 'publicToilet',
      desc: '',
      args: [],
    );
  }

  /// `Locker`
  String get locker {
    return Intl.message('Locker', name: 'locker', desc: '', args: []);
  }

  /// `Cafe`
  String get cafe {
    return Intl.message('Cafe', name: 'cafe', desc: '', args: []);
  }

  /// `Restaurant`
  String get restaurant {
    return Intl.message('Restaurant', name: 'restaurant', desc: '', args: []);
  }

  /// `Landmark`
  String get landmark {
    return Intl.message('Landmark', name: 'landmark', desc: '', args: []);
  }

  /// `Add Place`
  String get addPlace {
    return Intl.message('Add Place', name: 'addPlace', desc: '', args: []);
  }

  /// `public wifi`
  String get publicwifi {
    return Intl.message('public wifi', name: 'publicwifi', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Map`
  String get map {
    return Intl.message('Map', name: 'map', desc: '', args: []);
  }

  /// `Board`
  String get board {
    return Intl.message('Board', name: 'board', desc: '', args: []);
  }

  /// `My Page`
  String get myPage {
    return Intl.message('My Page', name: 'myPage', desc: '', args: []);
  }

  /// `Select Category`
  String get categoryTitle {
    return Intl.message(
      'Select Category',
      name: 'categoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Companion Recruitment`
  String get companionRecruitment {
    return Intl.message(
      'Companion Recruitment',
      name: 'companionRecruitment',
      desc: '',
      args: [],
    );
  }

  /// `View More Posts`
  String get viewMorePosts {
    return Intl.message(
      'View More Posts',
      name: 'viewMorePosts',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message('Author', name: 'author', desc: '', args: []);
  }

  /// `Hotspots by Popularity`
  String get hotspotByPopularity {
    return Intl.message(
      'Hotspots by Popularity',
      name: 'hotspotByPopularity',
      desc: '',
      args: [],
    );
  }

  /// `View More Hotspots`
  String get viewMoreHotspots {
    return Intl.message(
      'View More Hotspots',
      name: 'viewMoreHotspots',
      desc: '',
      args: [],
    );
  }

  /// `Weather Info`
  String get weatherInfo {
    return Intl.message(
      'Weather Info',
      name: 'weatherInfo',
      desc: '',
      args: [],
    );
  }

  /// `Disaster Alerts`
  String get disasterAlerts {
    return Intl.message(
      'Disaster Alerts',
      name: 'disasterAlerts',
      desc: '',
      args: [],
    );
  }

  /// `recommendationTitle`
  String get recommendationTitle {
    return Intl.message(
      'recommendationTitle',
      name: 'recommendationTitle',
      desc: '',
      args: [],
    );
  }

  /// `recommendationText`
  String get recommendationText {
    return Intl.message(
      'recommendationText',
      name: 'recommendationText',
      desc: '',
      args: [],
    );
  }

  /// `indoorCafeRecommendation`
  String get indoorCafeRecommendation {
    return Intl.message(
      'indoorCafeRecommendation',
      name: 'indoorCafeRecommendation',
      desc: '',
      args: [],
    );
  }

  /// `hotspotByLikes`
  String get hotspotByLikes {
    return Intl.message(
      'hotspotByLikes',
      name: 'hotspotByLikes',
      desc: '',
      args: [],
    );
  }

  /// `noHotspots`
  String get noHotspots {
    return Intl.message('noHotspots', name: 'noHotspots', desc: '', args: []);
  }

  /// `recentPosts`
  String get recentPosts {
    return Intl.message('recentPosts', name: 'recentPosts', desc: '', args: []);
  }

  /// `noPosts`
  String get noPosts {
    return Intl.message('noPosts', name: 'noPosts', desc: '', args: []);
  }

  /// `Find Your Travel Mate 👋`
  String get findCompanion {
    return Intl.message(
      'Find Your Travel Mate 👋',
      name: 'findCompanion',
      desc: '',
      args: [],
    );
  }

  /// `Currently no companions are recruiting.`
  String get noCompanionsRecruiting {
    return Intl.message(
      'Currently no companions are recruiting.',
      name: 'noCompanionsRecruiting',
      desc: '',
      args: [],
    );
  }

  /// `View more companions...`
  String get viewMoreCompanions {
    return Intl.message(
      'View more companions...',
      name: 'viewMoreCompanions',
      desc: '',
      args: [],
    );
  }

  /// `newDisasterMessage`
  String get newDisasterMessage {
    return Intl.message(
      'newDisasterMessage',
      name: 'newDisasterMessage',
      desc: '',
      args: [],
    );
  }

  /// `selectLanguage`
  String get selectLanguage {
    return Intl.message(
      'selectLanguage',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `addNewPlaceTitle`
  String get addNewPlaceTitle {
    return Intl.message(
      'addNewPlaceTitle',
      name: 'addNewPlaceTitle',
      desc: '',
      args: [],
    );
  }

  /// `selectCategoryHint`
  String get selectCategoryHint {
    return Intl.message(
      'selectCategoryHint',
      name: 'selectCategoryHint',
      desc: '',
      args: [],
    );
  }

  /// `selectLocationButton`
  String get selectLocationButton {
    return Intl.message(
      'selectLocationButton',
      name: 'selectLocationButton',
      desc: '',
      args: [],
    );
  }

  /// `selectLocationTitle`
  String get selectLocationTitle {
    return Intl.message(
      'selectLocationTitle',
      name: 'selectLocationTitle',
      desc: '',
      args: [],
    );
  }

  /// `selectLocationconfimButton`
  String get selectLocationconfimButton {
    return Intl.message(
      'selectLocationconfimButton',
      name: 'selectLocationconfimButton',
      desc: '',
      args: [],
    );
  }

  /// `confirm`
  String get confirmButton {
    return Intl.message('confirm', name: 'confirmButton', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {

    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];

    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ko'),
    ];

  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

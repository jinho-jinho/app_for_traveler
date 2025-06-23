// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

<<<<<<< HEAD
  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{};
=======
  static String m0(error) => "Failed to accept request: ${error}";

  static String m1(address) => "Address: ${address}";

  static String m2(error) => "Failed to cancel application: ${error}";

  static String m3(error) => "Failed to send application: ${error}";

  static String m4(authorNickname, date) => "By ${authorNickname} on ${date}";

  static String m5(rating) => "Average Rating: ${rating}";

  static String m6(error) => "Failed to add comment: ${error}";

  static String m7(nickname) => "Author: ${nickname}";

  static String m8(error) => "Failed to delete comment: ${error}";

  static String m9(error) => "Failed to edit comment: ${error}";

  static String m10(error) => "Failed to load comments: ${error}";

  static String m11(error) => "Failed to delete companion: ${error}";

  static String m12(error) => "Failed to load companion: ${error}";

  static String m13(scheduleTitle) => "[Companion] ${scheduleTitle}";

  static String m14(error) =>
      "Data synchronization failed: Please check your network connection or try again later. (Error: ${error})";

  static String m15(error) => "Delete failed: ${error}";

  static String m16(destination) => "Destination: ${destination}";

  static String m17(error) => "Failed to add comment: ${error}";

  static String m18(error) => "Failed to add place: ${error}";

  static String m19(error) => "Failed to add reply: ${error}";

  static String m20(error) => "Failed to add review: ${error}";

  static String m21(error) => "Failed to delete comment: ${error}";

  static String m22(error) => "Failed to delete reply: ${error}";

  static String m23(error) => "Failed to get location information: ${error}";

  static String m24(error) => "Failed to load comments: ${error}";

  static String m25(error) => "Failed to load marker icons: ${error}";

  static String m26(error) => "Failed to search place: ${error}";

  static String m27(error) => "Failed to update comment: ${error}";

  static String m28(error) => "Failed to update reply: ${error}";

  static String m29(error) => "Failed to toggle favorite: ${error}";

  static String m30(error) => "Failed to upload image: ${error}";

  static String m31(error) => "Failed to leave companion: ${error}";

  static String m32(error) => "Load failed: ${error}";

  static String m33(error) => "Failed to get current location: ${error}";

  static String m34(error) => "Login error: ${error}";

  static String m35(error) => "Failed to load map: ${error}";

  static String m36(error) => "Map search failed: ${error}";

  static String m37(subcategory) => "${subcategory} Added";

  static String m38(keyword) => "No place found for \'${keyword}\'.";

  static String m39(query) => "No search results found for \'${query}\'.";

  static String m40(userName) => "${userName} has been accepted!";

  static String m41(error) => "Failed to load participants: ${error}";

  static String m42(error) => "Failed to add place: ${error}";

  static String m43(error) => "Failed to delete place: ${error}";

  static String m44(error) => "Failed to load places: ${error}";

  static String m45(error) => "Failed to update place: ${error}";

  static String m46(error) => "Failed to create post: ${error}";

  static String m47(error) => "Failed to load posts: ${error}";

  static String m48(rating) => "Rating: ${rating}";

  static String m49(error) => "Failed to reject request: ${error}";

  static String m50(error) => "Failed to load requests: ${error}";

  static String m51(error) => "Failed to add review: ${error}";

  static String m52(error) => "Failed to load reviews: ${error}";

  static String m53(error) => "Search failed: ${error}";

  static String m54(query, placeName) =>
      "Showing results for \'${query}\': ${placeName}";

  static String m55(query) => "Searching for \'${query}\'...";

  static String m56(error) => "Sign up error: ${error}";

  static String m57(error) => "Failed to load public Wi-Fi: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutAppTitle": MessageLookupByLibrary.simpleMessage("About App"),
    "acceptButton": MessageLookupByLibrary.simpleMessage("Accept"),
    "acceptRequestFailed": m0,
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addButton": MessageLookupByLibrary.simpleMessage("Add"),
    "addComment": MessageLookupByLibrary.simpleMessage("Add Comment"),
    "addCommentButton": MessageLookupByLibrary.simpleMessage("Add Comment"),
    "addNewPlaceTitle": MessageLookupByLibrary.simpleMessage(
      "addNewPlaceTitle",
    ),
    "addPersonalScheduleTooltip": MessageLookupByLibrary.simpleMessage(
      "Add Personal Schedule",
    ),
    "addPlace": MessageLookupByLibrary.simpleMessage("Add Place"),
    "addPlaceButton": MessageLookupByLibrary.simpleMessage("Add Place"),
    "addPlaceTitle": MessageLookupByLibrary.simpleMessage("Add New Place"),
    "addPlaceTooltip": MessageLookupByLibrary.simpleMessage("Add Place"),
    "addPostTooltip": MessageLookupByLibrary.simpleMessage("Add new post"),
    "addReviewButton": MessageLookupByLibrary.simpleMessage("Add Review"),
    "addedToFavorites": MessageLookupByLibrary.simpleMessage(
      "Added to favorites!",
    ),
    "additionalDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Additional Description",
    ),
    "additionalDescriptionPrefix": MessageLookupByLibrary.simpleMessage(
      "Additional description: ",
    ),
    "address": m1,
    "addressLabel": MessageLookupByLibrary.simpleMessage("Address"),
    "addressRequired": MessageLookupByLibrary.simpleMessage(
      "Address (Required, e.g., Daehak-ro 52-1)",
    ),
    "addressSearchFailed": MessageLookupByLibrary.simpleMessage(
      "Address search failed.",
    ),
    "ageConditionRange": MessageLookupByLibrary.simpleMessage("Range"),
    "ageHint": MessageLookupByLibrary.simpleMessage("Age"),
    "ageUnlimited": MessageLookupByLibrary.simpleMessage("Age Unlimited"),
    "allCategories": MessageLookupByLibrary.simpleMessage("All Categories"),
    "anonymous": MessageLookupByLibrary.simpleMessage("Anonymous"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Traveler App"),
    "applicantsListTitle": MessageLookupByLibrary.simpleMessage(
      "Applicants List",
    ),
    "applicationCancelError": m2,
    "applicationCancelledSuccess": MessageLookupByLibrary.simpleMessage(
      "Application cancelled successfully!",
    ),
    "applicationSendError": m3,
    "applicationSentSuccess": MessageLookupByLibrary.simpleMessage(
      "Application sent successfully!",
    ),
    "applyForCompanionButton": MessageLookupByLibrary.simpleMessage(
      "Apply for Companion",
    ),
    "artMuseums": MessageLookupByLibrary.simpleMessage("Art/Museums"),
    "asianFood": MessageLookupByLibrary.simpleMessage("Asian Food"),
    "atm": MessageLookupByLibrary.simpleMessage("ATM"),
    "atmSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing ATM locations...",
    ),
    "attachPhoto": MessageLookupByLibrary.simpleMessage("Attach Photo"),
    "author": MessageLookupByLibrary.simpleMessage("Author"),
    "authorAndDate": m4,
    "authorLabel": MessageLookupByLibrary.simpleMessage("Author"),
    "authorPrefix": MessageLookupByLibrary.simpleMessage("Author: "),
    "averageRating": m5,
    "bank": MessageLookupByLibrary.simpleMessage("Bank"),
    "bankSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing bank locations...",
    ),
    "barsPubs": MessageLookupByLibrary.simpleMessage("Bars/Pubs"),
    "batteryCharging": MessageLookupByLibrary.simpleMessage(
      "\nYour battery is charging. How about watching a movie while it charges?",
    ),
    "batteryHalf": MessageLookupByLibrary.simpleMessage(
      "\nYour battery is half full. We recommend activities that consume less power.",
    ),
    "batteryLow": MessageLookupByLibrary.simpleMessage(
      "\nBattery is low! We recommend bringing a power bank or connecting to power.",
    ),
    "board": MessageLookupByLibrary.simpleMessage("Board"),
    "boardTab": MessageLookupByLibrary.simpleMessage("Board"),
    "boardTitle": MessageLookupByLibrary.simpleMessage("Board"),
    "bookstores": MessageLookupByLibrary.simpleMessage("Bookstores"),
    "cafe": MessageLookupByLibrary.simpleMessage("Cafe"),
    "cafeSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing cafes...",
    ),
    "cafesDesserts": MessageLookupByLibrary.simpleMessage("Cafes/Desserts"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelApplicationButton": MessageLookupByLibrary.simpleMessage(
      "Cancel Application",
    ),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotLoadSchedule": MessageLookupByLibrary.simpleMessage(
      "Cannot load schedule.",
    ),
    "categoryAccommodation": MessageLookupByLibrary.simpleMessage(
      "Accommodation",
    ),
    "categoryEtc": MessageLookupByLibrary.simpleMessage("Etc"),
    "categoryLabel": MessageLookupByLibrary.simpleMessage("Category"),
    "categoryLandmark": MessageLookupByLibrary.simpleMessage("Landmark"),
    "categoryRestaurant": MessageLookupByLibrary.simpleMessage("Restaurant"),
    "categoryTitle": MessageLookupByLibrary.simpleMessage("Select Category"),
    "categoryTransportation": MessageLookupByLibrary.simpleMessage(
      "Transportation",
    ),
    "cinemas": MessageLookupByLibrary.simpleMessage("Cinemas"),
    "clearSky": MessageLookupByLibrary.simpleMessage("Clear sky"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeButton": MessageLookupByLibrary.simpleMessage("Close"),
    "closedStatus": MessageLookupByLibrary.simpleMessage("Closed"),
    "clouds": MessageLookupByLibrary.simpleMessage("Clouds"),
    "commentAddFailed": m6,
    "commentAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "Comment added successfully!",
    ),
    "commentAuthor": m7,
    "commentDeleteFailed": m8,
    "commentDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Comment deleted successfully!",
    ),
    "commentEditFailed": m9,
    "commentEditedSuccess": MessageLookupByLibrary.simpleMessage(
      "Comment edited successfully!",
    ),
    "commentEmptyWarning": MessageLookupByLibrary.simpleMessage(
      "Comment cannot be empty.",
    ),
    "commentInputHint": MessageLookupByLibrary.simpleMessage(
      "Enter your comment...",
    ),
    "commentUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Comment updated successfully!",
    ),
    "comments": MessageLookupByLibrary.simpleMessage("Comments:"),
    "commentsLoadError": m10,
    "commentsSectionTitle": MessageLookupByLibrary.simpleMessage("Comments"),
    "commentsTitle": MessageLookupByLibrary.simpleMessage("Comments"),
    "companionApplicationNotPossible": MessageLookupByLibrary.simpleMessage(
      "Application not possible (closed or full).",
    ),
    "companionDataNotFound": MessageLookupByLibrary.simpleMessage(
      "Companion data not found.",
    ),
    "companionDeleteFailed": m11,
    "companionDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Companion post deleted successfully!",
    ),
    "companionDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "e.g., Prefer quiet travel / Welcome MBTI I types",
    ),
    "companionLoadError": m12,
    "companionNotFound": MessageLookupByLibrary.simpleMessage(
      "Companion not found.",
    ),
    "companionRecruitment": MessageLookupByLibrary.simpleMessage(
      "Companion Recruitment",
    ),
    "companionSchedulePrefix": m13,
    "completeEditButton": MessageLookupByLibrary.simpleMessage("Complete Edit"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmButton": MessageLookupByLibrary.simpleMessage("confirm"),
    "confirmDeleteComment": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this comment?",
    ),
    "confirmDeleteCompanion": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this companion post?",
    ),
    "confirmDeletePlace": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this place?",
    ),
    "confirmDeleteReply": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this reply?",
    ),
    "confirmDeleteSchedule": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this schedule?",
    ),
    "confirmLeaveCompanion": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to leave this companion group?",
    ),
    "confirmPasswordHint": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "contactHint": MessageLookupByLibrary.simpleMessage(
      "Contact (KakaoTalk ID or Email)",
    ),
    "contentLabel": MessageLookupByLibrary.simpleMessage("Content"),
    "createAccountButton": MessageLookupByLibrary.simpleMessage(
      "Create Account",
    ),
    "createPostTitle": MessageLookupByLibrary.simpleMessage("Create New Post"),
    "createPostTooltip": MessageLookupByLibrary.simpleMessage("Create Post"),
    "currencyExchange": MessageLookupByLibrary.simpleMessage(
      "Currency Exchange",
    ),
    "currencyExchangeSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing currency exchange locations...",
    ),
    "currentLocation": MessageLookupByLibrary.simpleMessage("Current Location"),
    "currentLocationInfo": MessageLookupByLibrary.simpleMessage(
      "Currently in Gumi-si, Gyeongsangbuk-do, South Korea",
    ),
    "currentParticipants": MessageLookupByLibrary.simpleMessage("Participants"),
    "currentWeatherInfo": MessageLookupByLibrary.simpleMessage(
      "Current Weather Information",
    ),
    "cyclingPaths": MessageLookupByLibrary.simpleMessage("Cycling Paths"),
    "dataSyncComplete": MessageLookupByLibrary.simpleMessage(
      "Data synchronization complete",
    ),
    "dataSyncFailed": m14,
    "dataSyncMessage": MessageLookupByLibrary.simpleMessage(
      "Data synchronization in progress...",
    ),
    "dataSyncSkipped": MessageLookupByLibrary.simpleMessage(
      "Data synchronization skipped. Loading existing data.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAccountButton": MessageLookupByLibrary.simpleMessage(
      "Delete Account",
    ),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteCommentTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Comment",
    ),
    "deleteCompanionTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Companion",
    ),
    "deleteFailed": m15,
    "deletePlaceTitle": MessageLookupByLibrary.simpleMessage("Delete Place"),
    "deleteReplyTitle": MessageLookupByLibrary.simpleMessage("Delete Reply"),
    "deleteReview": MessageLookupByLibrary.simpleMessage("Delete Review"),
    "deleteReviewConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this review?",
    ),
    "deleteScheduleTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Schedule",
    ),
    "deletedComment": MessageLookupByLibrary.simpleMessage("Deleted comment."),
    "deletedCommentIndicator": MessageLookupByLibrary.simpleMessage(
      "(This comment has been deleted)",
    ),
    "descriptionHint": MessageLookupByLibrary.simpleMessage(
      "e.g., Relaxing time with friends / Museum-focused itinerary",
    ),
    "destinationLabel": MessageLookupByLibrary.simpleMessage("Destination *"),
    "destinationPrefix": m16,
    "destinationUndecided": MessageLookupByLibrary.simpleMessage(
      "Destination Undecided",
    ),
    "disasterAlertTitle": MessageLookupByLibrary.simpleMessage(
      "Disaster Alert",
    ),
    "disasterAlerts": MessageLookupByLibrary.simpleMessage("Disaster Alerts"),
    "editButton": MessageLookupByLibrary.simpleMessage("Edit"),
    "editCommentHint": MessageLookupByLibrary.simpleMessage(
      "Edit your comment",
    ),
    "editCommentTitle": MessageLookupByLibrary.simpleMessage("Edit Comment"),
    "editCompanionInfo": MessageLookupByLibrary.simpleMessage(
      "Edit Companion Information",
    ),
    "editCompanionInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Edit Companion Info",
    ),
    "editFailed": MessageLookupByLibrary.simpleMessage("Edit failed"),
    "editPlaceTitle": MessageLookupByLibrary.simpleMessage("Edit Place"),
    "editProfileButton": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "editProfileTitle": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "editScheduleTitle": MessageLookupByLibrary.simpleMessage("Edit Schedule"),
    "editTravelInfo": MessageLookupByLibrary.simpleMessage(
      "Edit Travel Information",
    ),
    "emptyCommentWarning": MessageLookupByLibrary.simpleMessage(
      "Comment cannot be empty.",
    ),
    "emptyFieldsWarning": MessageLookupByLibrary.simpleMessage(
      "Name and address cannot be empty.",
    ),
    "emptyPostFieldsWarning": MessageLookupByLibrary.simpleMessage(
      "Title and content cannot be empty.",
    ),
    "encryptedFacilityWarning": MessageLookupByLibrary.simpleMessage(
      "This is an encrypted facility.",
    ),
    "encryptedLocation": MessageLookupByLibrary.simpleMessage(
      "Encrypted location",
    ),
    "endDate": MessageLookupByLibrary.simpleMessage("End Date"),
    "enterCommentHint": MessageLookupByLibrary.simpleMessage(
      "Enter your comment...",
    ),
    "enterCompanionInfo": MessageLookupByLibrary.simpleMessage(
      "Enter Companion Information",
    ),
    "enterDestination": MessageLookupByLibrary.simpleMessage(
      "Please enter a destination",
    ),
    "enterReplyHint": MessageLookupByLibrary.simpleMessage(
      "Enter your reply...",
    ),
    "enterTitle": MessageLookupByLibrary.simpleMessage("Please enter a title"),
    "enterTripInfo": MessageLookupByLibrary.simpleMessage(
      "Enter Trip Information",
    ),
    "errorOccurred": MessageLookupByLibrary.simpleMessage("Error occurred"),
    "errorText": MessageLookupByLibrary.simpleMessage("Error"),
    "etcCategory": MessageLookupByLibrary.simpleMessage("Etc."),
    "exhibitionHalls": MessageLookupByLibrary.simpleMessage("Exhibition Halls"),
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
      "Failed to load user information. Please try again later.",
    ),
    "failedToSearchPlace": m26,
    "failedToUpdateComment": m27,
    "failedToUpdateFavorites": MessageLookupByLibrary.simpleMessage(
      "An error occurred while updating favorites. Please check your network.",
    ),
    "failedToUpdateReply": m28,
    "failedToUploadImage": MessageLookupByLibrary.simpleMessage(
      "Image upload failed. Please try again.",
    ),
    "favoriteToggleFailed": m29,
    "filterButton": MessageLookupByLibrary.simpleMessage("Filter"),
    "filterByCategories": MessageLookupByLibrary.simpleMessage(
      "Filter by Categories",
    ),
    "findCompanion": MessageLookupByLibrary.simpleMessage(
      "Find Your Travel Mate 👋",
    ),
    "findCompanionTitle": MessageLookupByLibrary.simpleMessage(
      "Find a Companion",
    ),
    "fineDust": MessageLookupByLibrary.simpleMessage("Fine Dust"),
    "free": MessageLookupByLibrary.simpleMessage("Free"),
    "freeAdmission": MessageLookupByLibrary.simpleMessage("Free Admission"),
    "freePaid": MessageLookupByLibrary.simpleMessage("Free/Paid:"),
    "genderConditionAny": MessageLookupByLibrary.simpleMessage("Any"),
    "genderConditionFemaleOnly": MessageLookupByLibrary.simpleMessage(
      "Female Only",
    ),
    "genderConditionLabel": MessageLookupByLibrary.simpleMessage(
      "Gender Condition",
    ),
    "genderConditionMaleOnly": MessageLookupByLibrary.simpleMessage(
      "Male Only",
    ),
    "genderFemale": MessageLookupByLibrary.simpleMessage("Female"),
    "genderLabel": MessageLookupByLibrary.simpleMessage("Gender"),
    "genderMale": MessageLookupByLibrary.simpleMessage("Male"),
    "gettingCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "Getting current location...",
    ),
    "goToLoginButton": MessageLookupByLibrary.simpleMessage("Go to Login"),
    "guesthouses": MessageLookupByLibrary.simpleMessage("Guesthouses"),
    "hanoks": MessageLookupByLibrary.simpleMessage("Hanoks"),
    "helpCenterTitle": MessageLookupByLibrary.simpleMessage("Help Center"),
    "hikingTrails": MessageLookupByLibrary.simpleMessage("Hiking Trails"),
    "historicalSites": MessageLookupByLibrary.simpleMessage("Historical Sites"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "homeTab": MessageLookupByLibrary.simpleMessage("Home"),
    "hospital": MessageLookupByLibrary.simpleMessage("Hospital"),
    "hotels": MessageLookupByLibrary.simpleMessage("Hotels"),
    "hotspotByLikes": MessageLookupByLibrary.simpleMessage("hotspotByLikes"),
    "hotspotByPopularity": MessageLookupByLibrary.simpleMessage(
      "Hotspots by Popularity",
    ),
    "hotspotsTitle": MessageLookupByLibrary.simpleMessage("My Hot Places"),
    "humidity": MessageLookupByLibrary.simpleMessage("Humidity"),
    "idHint": MessageLookupByLibrary.simpleMessage("ID"),
    "imageCompressionFailed": MessageLookupByLibrary.simpleMessage(
      "Image compression failed.",
    ),
    "imageUploadFailed": m30,
    "imageUploadSuccess": MessageLookupByLibrary.simpleMessage(
      "Image uploaded successfully!",
    ),
    "indoorCafeRecommendation": MessageLookupByLibrary.simpleMessage(
      "indoorCafeRecommendation",
    ),
    "indoorSports": MessageLookupByLibrary.simpleMessage("Indoor Sports"),
    "initializingMap": MessageLookupByLibrary.simpleMessage(
      "Initializing map...",
    ),
    "installationAgencyLabel": MessageLookupByLibrary.simpleMessage(
      "Installation Agency",
    ),
    "invalidAddress": MessageLookupByLibrary.simpleMessage(
      "Invalid address. Please try again.",
    ),
    "invalidAddressError": MessageLookupByLibrary.simpleMessage(
      "Could not find coordinates for the address.",
    ),
    "isEncryptedLabel": MessageLookupByLibrary.simpleMessage(
      "Encrypted Facility?",
    ),
    "isFreeLabel": MessageLookupByLibrary.simpleMessage("Free Admission?"),
    "koreanFood": MessageLookupByLibrary.simpleMessage("Korean Food"),
    "landmark": MessageLookupByLibrary.simpleMessage("Landmark"),
    "landmarkSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing landmarks...",
    ),
    "leaderLabel": MessageLookupByLibrary.simpleMessage("Leader"),
    "leaveButton": MessageLookupByLibrary.simpleMessage("Leave"),
    "leaveCompanionButton": MessageLookupByLibrary.simpleMessage(
      "Leave Companion",
    ),
    "leaveCompanionFailed": m31,
    "leaveCompanionTitle": MessageLookupByLibrary.simpleMessage(
      "Leave Companion",
    ),
    "leftCompanionSuccess": MessageLookupByLibrary.simpleMessage(
      "You have left the companion group.",
    ),
    "libraries": MessageLookupByLibrary.simpleMessage("Libraries"),
    "loadFailed": m32,
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "loadingKakaoPlaces": MessageLookupByLibrary.simpleMessage(
      "Loading Kakao places...",
    ),
    "loadingPlaces": MessageLookupByLibrary.simpleMessage("Loading places..."),
    "loadingPublicWifiHotspots": MessageLookupByLibrary.simpleMessage(
      "Loading public Wi-Fi hotspots...",
    ),
    "loadingText": MessageLookupByLibrary.simpleMessage("Loading..."),
    "loadingWifi": MessageLookupByLibrary.simpleMessage(
      "Loading public Wi-Fi...",
    ),
    "locationFetchError": m33,
    "locationPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Location permissions are denied.",
    ),
    "locationPermissionDeniedForever": MessageLookupByLibrary.simpleMessage(
      "Location permissions are permanently denied, we cannot request permissions.",
    ),
    "locationServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "Location services are disabled.",
    ),
    "locker": MessageLookupByLibrary.simpleMessage("Locker"),
    "lockerSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing lockers...",
    ),
    "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
    "loginErrorEmptyFields": MessageLookupByLibrary.simpleMessage(
      "Please enter your ID and password.",
    ),
    "loginErrorGeneric": m34,
    "loginErrorIdNotFound": MessageLookupByLibrary.simpleMessage(
      "ID does not exist.",
    ),
    "loginErrorPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "Password does not match.",
    ),
    "loginScreenTitle": MessageLookupByLibrary.simpleMessage("Login"),
    "logoutButton": MessageLookupByLibrary.simpleMessage("Logout"),
    "map": MessageLookupByLibrary.simpleMessage("Map"),
    "mapLoadError": m35,
    "mapLoadingWait": MessageLookupByLibrary.simpleMessage(
      "Map is loading. Please wait...",
    ),
    "mapScreenTitle": MessageLookupByLibrary.simpleMessage("Map"),
    "mapSearchError": m36,
    "mapTab": MessageLookupByLibrary.simpleMessage("Map"),
    "mapTitle": MessageLookupByLibrary.simpleMessage("Map"),
    "mapView": MessageLookupByLibrary.simpleMessage("Map View"),
    "maxAgeLabel": MessageLookupByLibrary.simpleMessage("Max Age"),
    "maxParticipantsReached": MessageLookupByLibrary.simpleMessage(
      "Maximum number of participants reached.",
    ),
    "minAgeLabel": MessageLookupByLibrary.simpleMessage("Min Age"),
    "mobileData": MessageLookupByLibrary.simpleMessage(
      "\nYou are using mobile data. Be careful with activities that consume a lot of data.",
    ),
    "motels": MessageLookupByLibrary.simpleMessage("Motels"),
    "myActivitiesHeader": MessageLookupByLibrary.simpleMessage("My Activities"),
    "myCommentsTitle": MessageLookupByLibrary.simpleMessage("My Comments"),
    "myFavoritesTitle": MessageLookupByLibrary.simpleMessage("My Favorites"),
    "myPage": MessageLookupByLibrary.simpleMessage("My Page"),
    "myPageScreenTitle": MessageLookupByLibrary.simpleMessage("My Page"),
    "myPageTab": MessageLookupByLibrary.simpleMessage("My Page"),
    "myPostsTitle": MessageLookupByLibrary.simpleMessage("My Posts"),
    "myScheduleTitle": MessageLookupByLibrary.simpleMessage("My Schedule"),
    "myTravelScheduleTitle": MessageLookupByLibrary.simpleMessage(
      "My Travel Schedule",
    ),
    "naturalLandmarks": MessageLookupByLibrary.simpleMessage(
      "Natural Landmarks",
    ),
    "newDisasterMessage": MessageLookupByLibrary.simpleMessage(
      "newDisasterMessage",
    ),
    "newPlaceAdded": m37,
    "nicknameHint": MessageLookupByLibrary.simpleMessage("Nickname"),
    "noAddressInfo": MessageLookupByLibrary.simpleMessage("No Address Info"),
    "noApplicants": MessageLookupByLibrary.simpleMessage(
      "No applicants currently.",
    ),
    "noComments": MessageLookupByLibrary.simpleMessage("No comments yet."),
    "noCommentsYet": MessageLookupByLibrary.simpleMessage(
      "No comments yet. Be the first to comment!",
    ),
    "noCompanions": MessageLookupByLibrary.simpleMessage(
      "No companion posts yet.",
    ),
    "noCompanionsRecruiting": MessageLookupByLibrary.simpleMessage(
      "Currently no companions are recruiting.",
    ),
    "noCompanionsRegistered": MessageLookupByLibrary.simpleMessage(
      "No companions currently registered.",
    ),
    "noContent": MessageLookupByLibrary.simpleMessage("No Content"),
    "noDisasterMessage": MessageLookupByLibrary.simpleMessage(
      "No disaster messages currently.",
    ),
    "noHotspots": MessageLookupByLibrary.simpleMessage("noHotspots"),
    "noInternet": MessageLookupByLibrary.simpleMessage(
      "\nNo internet connection. We recommend offline games or pre-downloaded content.",
    ),
    "noMyComments": MessageLookupByLibrary.simpleMessage("No comments."),
    "noMyPosts": MessageLookupByLibrary.simpleMessage("No posts."),
    "noParticipants": MessageLookupByLibrary.simpleMessage(
      "No participants yet.",
    ),
    "noPlaceFound": MessageLookupByLibrary.simpleMessage("No place found."),
    "noPlaceFoundForKeyword": m38,
    "noPosts": MessageLookupByLibrary.simpleMessage("noPosts"),
    "noRecentPosts": MessageLookupByLibrary.simpleMessage(
      "No recent posts yet.",
    ),
    "noReviews": MessageLookupByLibrary.simpleMessage("No reviews"),
    "noReviewsYet": MessageLookupByLibrary.simpleMessage(
      "No reviews yet. Be the first to add one!",
    ),
    "noSchedulesForDate": MessageLookupByLibrary.simpleMessage(
      "No schedules registered for this date.",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No search results found.",
    ),
    "noSearchResultsForQuery": m39,
    "noTitle": MessageLookupByLibrary.simpleMessage("No Title"),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "notificationSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Notification Settings",
    ),
    "notificationsTooltip": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "originalPostPrefix": MessageLookupByLibrary.simpleMessage(
      "Original Post: ",
    ),
    "otherAccommodations": MessageLookupByLibrary.simpleMessage(
      "Other Accommodations",
    ),
    "otherAttractions": MessageLookupByLibrary.simpleMessage(
      "Other Attractions",
    ),
    "otherCulture": MessageLookupByLibrary.simpleMessage("Other Culture"),
    "otherFood": MessageLookupByLibrary.simpleMessage("Other Food"),
    "otherLeisure": MessageLookupByLibrary.simpleMessage("Other Leisure"),
    "paid": MessageLookupByLibrary.simpleMessage("Paid"),
    "paidAdmission": MessageLookupByLibrary.simpleMessage("Paid Admission"),
    "parksGardens": MessageLookupByLibrary.simpleMessage("Parks/Gardens"),
    "participantAcceptedSuccess": m40,
    "participantsLabel": MessageLookupByLibrary.simpleMessage("Participants"),
    "participantsLoadError": m41,
    "participantsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Participants",
    ),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Password"),
    "performanceHalls": MessageLookupByLibrary.simpleMessage(
      "Performance Halls",
    ),
    "periodLabel": MessageLookupByLibrary.simpleMessage("Period"),
    "personUnit": MessageLookupByLibrary.simpleMessage("persons"),
    "personalScheduleDetailTitle": MessageLookupByLibrary.simpleMessage(
      "Personal Schedule Details",
    ),
    "pharmacy": MessageLookupByLibrary.simpleMessage("Pharmacy"),
    "pharmacySyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing pharmacy locations...",
    ),
    "phoneChargingStation": MessageLookupByLibrary.simpleMessage(
      "phone charging station",
    ),
    "placeAddFailed": m42,
    "placeAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "Place added successfully!",
    ),
    "placeAddressHint": MessageLookupByLibrary.simpleMessage("Enter address"),
    "placeDeleteFailed": m43,
    "placeDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Place deleted successfully!",
    ),
    "placeDetailsTitle": MessageLookupByLibrary.simpleMessage("Place Details"),
    "placeLoadError": m44,
    "placeNameAndAddressRequired": MessageLookupByLibrary.simpleMessage(
      "Place name and address are required.",
    ),
    "placeNameHint": MessageLookupByLibrary.simpleMessage("Enter place name"),
    "placeNameRequired": MessageLookupByLibrary.simpleMessage(
      "Place Name (Required)",
    ),
    "placeNotFound": MessageLookupByLibrary.simpleMessage("Place not found."),
    "placeUpdateFailed": m45,
    "placeUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Place updated successfully!",
    ),
    "policeStation": MessageLookupByLibrary.simpleMessage("Police Station"),
    "policeStationSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing police stations...",
    ),
    "postButton": MessageLookupByLibrary.simpleMessage("Post"),
    "postContentHint": MessageLookupByLibrary.simpleMessage("Enter content"),
    "postCreateFailed": m46,
    "postCreatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Post created successfully!",
    ),
    "postDetailTitle": MessageLookupByLibrary.simpleMessage("Post Details"),
    "postLoadFailed": m47,
    "postTitleHint": MessageLookupByLibrary.simpleMessage("Enter title"),
    "profileUpdateFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to update profile:",
    ),
    "profileUpdateSuccess": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully!",
    ),
    "publicRestroom": MessageLookupByLibrary.simpleMessage("Public Restroom"),
    "publicToilet": MessageLookupByLibrary.simpleMessage("Public Toilet"),
    "publicToiletSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing public toilets...",
    ),
    "publicWifi": MessageLookupByLibrary.simpleMessage("public Wi-Fi"),
    "publicWifiSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing public Wi-Fi...",
    ),
    "publicwifi": MessageLookupByLibrary.simpleMessage("public wifi"),
    "rain": MessageLookupByLibrary.simpleMessage("Rain"),
    "rating": m48,
    "recentPosts": MessageLookupByLibrary.simpleMessage("recentPosts"),
    "recentPostsTitle": MessageLookupByLibrary.simpleMessage("Recent Posts"),
    "recommendationBasedOnCurrentStatus": MessageLookupByLibrary.simpleMessage(
      "Recommendation Based on Current Status",
    ),
    "recommendationText": MessageLookupByLibrary.simpleMessage(
      "recommendationText",
    ),
    "recommendationTitle": MessageLookupByLibrary.simpleMessage(
      "recommendationTitle",
    ),
    "recruitCountError": MessageLookupByLibrary.simpleMessage(
      "Enter a number between 2 and 50",
    ),
    "recruitCountLabel": MessageLookupByLibrary.simpleMessage(
      "Number of Recruits *",
    ),
    "recruiting": MessageLookupByLibrary.simpleMessage("Recruiting"),
    "recruitmentClosed": MessageLookupByLibrary.simpleMessage(
      "Recruitment Closed",
    ),
    "recruitmentClosedWarning": MessageLookupByLibrary.simpleMessage(
      "Recruitment is closed.",
    ),
    "recruitmentComplete": MessageLookupByLibrary.simpleMessage(
      "Recruitment Complete",
    ),
    "refreshData": MessageLookupByLibrary.simpleMessage("Refresh Data"),
    "registerCompanionButton": MessageLookupByLibrary.simpleMessage(
      "Register Companion",
    ),
    "registerCompanionTitle": MessageLookupByLibrary.simpleMessage(
      "Register Companion",
    ),
    "registerCompanionTooltip": MessageLookupByLibrary.simpleMessage(
      "Register Companion",
    ),
    "registerFailed": MessageLookupByLibrary.simpleMessage(
      "Registration failed",
    ),
    "registerTripButton": MessageLookupByLibrary.simpleMessage("Register Trip"),
    "registerTripTitle": MessageLookupByLibrary.simpleMessage("Register Trip"),
    "rejectButton": MessageLookupByLibrary.simpleMessage("Reject"),
    "rejectRequestFailed": m49,
    "removedFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Removed from favorites.",
    ),
    "replyAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "Reply added successfully!",
    ),
    "replyButton": MessageLookupByLibrary.simpleMessage("Reply"),
    "replyContentHint": MessageLookupByLibrary.simpleMessage(
      "Enter your reply...",
    ),
    "replyDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Reply deleted successfully!",
    ),
    "replyEmptyWarning": MessageLookupByLibrary.simpleMessage(
      "Reply cannot be empty.",
    ),
    "replyHint": MessageLookupByLibrary.simpleMessage("Write a reply..."),
    "replyPrefix": MessageLookupByLibrary.simpleMessage("Reply to"),
    "replyUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Reply updated successfully!",
    ),
    "requestRejectedSuccess": MessageLookupByLibrary.simpleMessage(
      "Request rejected.",
    ),
    "requestsLoadError": m50,
    "resorts": MessageLookupByLibrary.simpleMessage("Resorts"),
    "restaurant": MessageLookupByLibrary.simpleMessage("Restaurant"),
    "restaurantSyncing": MessageLookupByLibrary.simpleMessage(
      "Synchronizing restaurants...",
    ),
    "reviewAddFailed": m51,
    "reviewAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "Review added successfully!",
    ),
    "reviewFieldsEmptyWarning": MessageLookupByLibrary.simpleMessage(
      "Please enter a rating and comment.",
    ),
    "reviewHint": MessageLookupByLibrary.simpleMessage("Write your review..."),
    "reviewInputHint": MessageLookupByLibrary.simpleMessage(
      "Enter your review here...",
    ),
    "reviewLoadFailed": m52,
    "reviewsTitle": MessageLookupByLibrary.simpleMessage("Reviews"),
    "saveButton": MessageLookupByLibrary.simpleMessage("Save"),
    "scheduleDeleted": MessageLookupByLibrary.simpleMessage(
      "Schedule deleted.",
    ),
    "scheduleTitleLabel": MessageLookupByLibrary.simpleMessage("Title *"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchButton": MessageLookupByLibrary.simpleMessage("Search"),
    "searchFailed": m53,
    "searchHintText": MessageLookupByLibrary.simpleMessage(
      "Enter search term...",
    ),
    "searchMap": MessageLookupByLibrary.simpleMessage("Search Map"),
    "searchPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Enter place name or address",
    ),
    "searchPlacesHint": MessageLookupByLibrary.simpleMessage(
      "Search for places...",
    ),
    "searchResultsDisplayed": m54,
    "searching": m55,
    "selectCategoryHint": MessageLookupByLibrary.simpleMessage(
      "selectCategoryHint",
    ),
    "selectEndDate": MessageLookupByLibrary.simpleMessage("Select End Date"),
    "selectImageButton": MessageLookupByLibrary.simpleMessage("Select Image"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("selectLanguage"),
    "selectLocation": MessageLookupByLibrary.simpleMessage("Select Location"),
    "selectLocationButton": MessageLookupByLibrary.simpleMessage(
      "selectLocationButton",
    ),
    "selectLocationTitle": MessageLookupByLibrary.simpleMessage(
      "selectLocationTitle",
    ),
    "selectLocationconfimButton": MessageLookupByLibrary.simpleMessage(
      "selectLocationconfimButton",
    ),
    "selectStartAndEndDate": MessageLookupByLibrary.simpleMessage(
      "Please select both start and end dates.",
    ),
    "selectStartDate": MessageLookupByLibrary.simpleMessage(
      "Select Start Date",
    ),
    "setCompanionConditions": MessageLookupByLibrary.simpleMessage(
      "Set Companion Conditions",
    ),
    "settingsHeader": MessageLookupByLibrary.simpleMessage("Settings"),
    "showOnlyOpenCompanions": MessageLookupByLibrary.simpleMessage(
      "Show only recruiting companions",
    ),
    "signUpButton": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "signUpErrorAllFieldsRequired": MessageLookupByLibrary.simpleMessage(
      "Please fill in all fields.",
    ),
    "signUpErrorGeneric": m56,
    "signUpErrorIdExists": MessageLookupByLibrary.simpleMessage(
      "ID already exists.",
    ),
    "signUpErrorPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match.",
    ),
    "signUpErrorPasswordTooShort": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters long.",
    ),
    "signUpScreenTitle": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "snow": MessageLookupByLibrary.simpleMessage("Snow"),
    "startDate": MessageLookupByLibrary.simpleMessage("Start Date"),
    "startDateBeforeEndDateError": MessageLookupByLibrary.simpleMessage(
      "Start date must be before end date.",
    ),
    "subcategoryAirport": MessageLookupByLibrary.simpleMessage("Airport"),
    "subcategoryBusTerminal": MessageLookupByLibrary.simpleMessage(
      "Bus Terminal",
    ),
    "subcategoryCafe": MessageLookupByLibrary.simpleMessage("Cafe"),
    "subcategoryCamping": MessageLookupByLibrary.simpleMessage("Camping"),
    "subcategoryChineseFood": MessageLookupByLibrary.simpleMessage(
      "Chinese Food",
    ),
    "subcategoryConvenience": MessageLookupByLibrary.simpleMessage(
      "Convenience Facilities",
    ),
    "subcategoryCulture": MessageLookupByLibrary.simpleMessage("Culture"),
    "subcategoryGuestHouse": MessageLookupByLibrary.simpleMessage(
      "Guest House",
    ),
    "subcategoryHistory": MessageLookupByLibrary.simpleMessage("History"),
    "subcategoryHospital": MessageLookupByLibrary.simpleMessage("Hospital"),
    "subcategoryHotel": MessageLookupByLibrary.simpleMessage("Hotel"),
    "subcategoryJapaneseFood": MessageLookupByLibrary.simpleMessage(
      "Japanese Food",
    ),
    "subcategoryKoreanFood": MessageLookupByLibrary.simpleMessage(
      "Korean Food",
    ),
    "subcategoryLabel": MessageLookupByLibrary.simpleMessage("Subcategory"),
    "subcategoryLeisure": MessageLookupByLibrary.simpleMessage("Leisure"),
    "subcategoryMotel": MessageLookupByLibrary.simpleMessage("Motel"),
    "subcategoryNature": MessageLookupByLibrary.simpleMessage("Nature"),
    "subcategoryPoliceStation": MessageLookupByLibrary.simpleMessage(
      "Police Station",
    ),
    "subcategoryPort": MessageLookupByLibrary.simpleMessage("Port"),
    "subcategoryPublicInstitution": MessageLookupByLibrary.simpleMessage(
      "Public Institution",
    ),
    "subcategoryResort": MessageLookupByLibrary.simpleMessage("Resort"),
    "subcategoryTrainStation": MessageLookupByLibrary.simpleMessage(
      "Train Station",
    ),
    "subcategoryWesternFood": MessageLookupByLibrary.simpleMessage(
      "Western Food",
    ),
    "submitReviewButton": MessageLookupByLibrary.simpleMessage("Submit Review"),
    "syncingFirestoreData": MessageLookupByLibrary.simpleMessage(
      "Syncing Firestore data...",
    ),
    "temperature": MessageLookupByLibrary.simpleMessage("Temperature"),
    "themeParks": MessageLookupByLibrary.simpleMessage("Theme Parks"),
    "titleLabel": MessageLookupByLibrary.simpleMessage("Title *"),
    "todayEnjoyableDay": MessageLookupByLibrary.simpleMessage(
      "Have a great day!",
    ),
    "tripDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "e.g., Respect alone time / Planning a food tour nearby in the evening",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownPost": MessageLookupByLibrary.simpleMessage("Unknown Post"),
    "uploadImageTooltip": MessageLookupByLibrary.simpleMessage("Upload Image"),
    "uploadingImage": MessageLookupByLibrary.simpleMessage(
      "Uploading image...",
    ),
    "userNotFound": MessageLookupByLibrary.simpleMessage(
      "User information not found.",
    ),
    "viewAllCompanionsButton": MessageLookupByLibrary.simpleMessage(
      "View All Companions",
    ),
    "viewMoreCompanions": MessageLookupByLibrary.simpleMessage(
      "View more companions...",
    ),
    "viewMoreHotspots": MessageLookupByLibrary.simpleMessage(
      "View More Hotspots",
    ),
    "viewMorePosts": MessageLookupByLibrary.simpleMessage("View More Posts"),
    "viewMorePostsButton": MessageLookupByLibrary.simpleMessage(
      "View More Posts",
    ),
    "waterSports": MessageLookupByLibrary.simpleMessage("Water Sports"),
    "weatherClear": MessageLookupByLibrary.simpleMessage(
      "It\'s a clear day! We recommend walking or outdoor activities.",
    ),
    "weatherClouds": MessageLookupByLibrary.simpleMessage(
      "It\'s cloudy. We recommend light indoor exercise or reading.",
    ),
    "weatherCold": MessageLookupByLibrary.simpleMessage(
      "It\'s very cold! Dress warmly and bring a scarf and gloves.",
    ),
    "weatherCondition": MessageLookupByLibrary.simpleMessage("Weather"),
    "weatherHot": MessageLookupByLibrary.simpleMessage(
      "It\'s very hot! Avoid outdoor activities and stay indoors with a cool drink.",
    ),
    "weatherInfo": MessageLookupByLibrary.simpleMessage("Weather Info"),
    "weatherLoadingError": MessageLookupByLibrary.simpleMessage(
      "Failed to load weather data.",
    ),
    "weatherRain": MessageLookupByLibrary.simpleMessage(
      "It\'s raining, so be sure to bring an umbrella and look for indoor activities.",
    ),
    "weatherSnow": MessageLookupByLibrary.simpleMessage(
      "It\'s snowing, so be careful of slippery roads, and how about a warm cup of tea?",
    ),
    "weatherTooltip": MessageLookupByLibrary.simpleMessage("Weather Info"),
    "welcomeMessage": MessageLookupByLibrary.simpleMessage("Welcome,"),
    "westernFood": MessageLookupByLibrary.simpleMessage("Western Food"),
    "wifiConnected": MessageLookupByLibrary.simpleMessage(
      "\nYou are connected to Wi-Fi. Enjoy streaming services without worrying about data!",
    ),
    "wifiLoadError": m57,
    "wifiMarkerSnippet": MessageLookupByLibrary.simpleMessage("Public Wi-Fi"),
    "winterSports": MessageLookupByLibrary.simpleMessage("Winter Sports"),
    "writeButton": MessageLookupByLibrary.simpleMessage("Write"),
    "writeReplyTitle": MessageLookupByLibrary.simpleMessage("Write Reply"),
    "writeReviewTitle": MessageLookupByLibrary.simpleMessage("Write a Review"),
  };
>>>>>>> 3e6f6c7 (translate end)
}

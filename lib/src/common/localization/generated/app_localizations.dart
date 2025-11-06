import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// Locale code
  ///
  /// In en, this message translates to:
  /// **'en_US'**
  String get localeCode;

  /// Language code
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get languageCode;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Color Pool Puzzle'**
  String get title;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @starred.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get starred;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @exception.
  ///
  /// In en, this message translates to:
  /// **'Exception'**
  String get exception;

  /// No description provided for @anErrorHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get anErrorHasOccurred;

  /// No description provided for @anExceptionHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'An exception has occurred'**
  String get anExceptionHasOccurred;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get tryAgainLater;

  /// No description provided for @invalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidFormat;

  /// No description provided for @timeOutExceeded.
  ///
  /// In en, this message translates to:
  /// **'Time out exceeded'**
  String get timeOutExceeded;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @unimplemented.
  ///
  /// In en, this message translates to:
  /// **'Unimplemented'**
  String get unimplemented;

  /// No description provided for @notImplementedYet.
  ///
  /// In en, this message translates to:
  /// **'Not implemented yet'**
  String get notImplementedYet;

  /// No description provided for @unsupportedOperation.
  ///
  /// In en, this message translates to:
  /// **'Unsupported operation'**
  String get unsupportedOperation;

  /// No description provided for @fileSystemException.
  ///
  /// In en, this message translates to:
  /// **'File system error'**
  String get fileSystemException;

  /// No description provided for @assertionError.
  ///
  /// In en, this message translates to:
  /// **'Assertion error'**
  String get assertionError;

  /// No description provided for @badStateError.
  ///
  /// In en, this message translates to:
  /// **'Bad state error'**
  String get badStateError;

  /// No description provided for @badRequest.
  ///
  /// In en, this message translates to:
  /// **'Bad request'**
  String get badRequest;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @notAcceptable.
  ///
  /// In en, this message translates to:
  /// **'Not acceptable'**
  String get notAcceptable;

  /// No description provided for @requestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout'**
  String get requestTimeout;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get tooManyRequests;

  /// No description provided for @internalServerError.
  ///
  /// In en, this message translates to:
  /// **'Internal server error'**
  String get internalServerError;

  /// No description provided for @badGateway.
  ///
  /// In en, this message translates to:
  /// **'Bad gateway'**
  String get badGateway;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get serviceUnavailable;

  /// No description provided for @gatewayTimeout.
  ///
  /// In en, this message translates to:
  /// **'Gateway timeout'**
  String get gatewayTimeout;

  /// No description provided for @unknownServerError.
  ///
  /// In en, this message translates to:
  /// **'Unknown server error'**
  String get unknownServerError;

  /// No description provided for @anUnknownErrorWasReceivedFromTheServer.
  ///
  /// In en, this message translates to:
  /// **'An unknown error was received from the server'**
  String get anUnknownErrorWasReceivedFromTheServer;

  /// No description provided for @logOutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutButton;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @exitButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @copyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// No description provided for @moveButton.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveButton;

  /// No description provided for @renameButton.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameButton;

  /// No description provided for @uploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadButton;

  /// No description provided for @downloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadButton;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @shareLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get shareLinkButton;

  /// No description provided for @removeFromStarredButton.
  ///
  /// In en, this message translates to:
  /// **'Remove from starred'**
  String get removeFromStarredButton;

  /// No description provided for @addToStarredButton.
  ///
  /// In en, this message translates to:
  /// **'Add to starred'**
  String get addToStarredButton;

  /// No description provided for @moveToTrashButton.
  ///
  /// In en, this message translates to:
  /// **'Move to trash'**
  String get moveToTrashButton;

  /// No description provided for @restoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreButton;

  /// No description provided for @profileButton.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileButton;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language selection'**
  String get languageSelection;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @authenticate.
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get authenticate;

  /// No description provided for @authenticated.
  ///
  /// In en, this message translates to:
  /// **'Authenticated'**
  String get authenticated;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @database.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @usefulLinks.
  ///
  /// In en, this message translates to:
  /// **'Useful links'**
  String get usefulLinks;

  /// No description provided for @logOutDescription.
  ///
  /// In en, this message translates to:
  /// **'You will be logged out from your account'**
  String get logOutDescription;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get currentVersion;

  /// No description provided for @latestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest version'**
  String get latestVersion;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @currentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentLabel;

  /// No description provided for @currentUser.
  ///
  /// In en, this message translates to:
  /// **'Current user'**
  String get currentUser;

  /// No description provided for @applicationVersion.
  ///
  /// In en, this message translates to:
  /// **'Application version'**
  String get applicationVersion;

  /// No description provided for @applicationInformation.
  ///
  /// In en, this message translates to:
  /// **'Application information'**
  String get applicationInformation;

  /// No description provided for @conectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get conectedDevices;

  /// No description provided for @renewalDate.
  ///
  /// In en, this message translates to:
  /// **'Renewal date'**
  String get renewalDate;

  /// No description provided for @apiDomain.
  ///
  /// In en, this message translates to:
  /// **'API domain'**
  String get apiDomain;

  /// No description provided for @noPlan.
  ///
  /// In en, this message translates to:
  /// **'No plan'**
  String get noPlan;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @ofSeparator.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofSeparator;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

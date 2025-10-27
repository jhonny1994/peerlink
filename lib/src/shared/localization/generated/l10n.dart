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

  /// `===== App Level =====`
  String get _comment_app {
    return Intl.message(
      '===== App Level =====',
      name: '_comment_app',
      desc: '',
      args: [],
    );
  }

  /// `PeerLink`
  String get appTitle {
    return Intl.message('PeerLink', name: 'appTitle', desc: '', args: []);
  }

  /// `Secure P2P file transfer`
  String get appTagline {
    return Intl.message(
      'Secure P2P file transfer',
      name: 'appTagline',
      desc: '',
      args: [],
    );
  }

  /// `===== Home Screen =====`
  String get _comment_home {
    return Intl.message(
      '===== Home Screen =====',
      name: '_comment_home',
      desc: '',
      args: [],
    );
  }

  /// `PeerLink`
  String get homeTitle {
    return Intl.message('PeerLink', name: 'homeTitle', desc: '', args: []);
  }

  /// `Send File`
  String get sendFile {
    return Intl.message('Send File', name: 'sendFile', desc: '', args: []);
  }

  /// `Receive File`
  String get receiveFile {
    return Intl.message(
      'Receive File',
      name: 'receiveFile',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Transfers are encrypted and peer-to-peer.\nNo cloud storage. Max 100MB per file.`
  String get homeInfoText {
    return Intl.message(
      'Transfers are encrypted and peer-to-peer.\nNo cloud storage. Max 100MB per file.',
      name: 'homeInfoText',
      desc: '',
      args: [],
    );
  }

  /// `===== Transfer Progress =====`
  String get _comment_transfer {
    return Intl.message(
      '===== Transfer Progress =====',
      name: '_comment_transfer',
      desc: '',
      args: [],
    );
  }

  /// `Sending file...`
  String get sendingFile {
    return Intl.message(
      'Sending file...',
      name: 'sendingFile',
      desc: '',
      args: [],
    );
  }

  /// `Receiving file...`
  String get receivingFile {
    return Intl.message(
      'Receiving file...',
      name: 'receivingFile',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Transfer`
  String get cancelTransfer {
    return Intl.message(
      'Cancel Transfer',
      name: 'cancelTransfer',
      desc: '',
      args: [],
    );
  }

  /// `===== Sender Flow =====`
  String get _comment_sender {
    return Intl.message(
      '===== Sender Flow =====',
      name: '_comment_sender',
      desc: '',
      args: [],
    );
  }

  /// `Select File`
  String get selectFile {
    return Intl.message('Select File', name: 'selectFile', desc: '', args: []);
  }

  /// `Share Code`
  String get shareCode {
    return Intl.message('Share Code', name: 'shareCode', desc: '', args: []);
  }

  /// `Sending File`
  String get sendingFileTitle {
    return Intl.message(
      'Sending File',
      name: 'sendingFileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Transfer Complete`
  String get transferComplete {
    return Intl.message(
      'Transfer Complete',
      name: 'transferComplete',
      desc: '',
      args: [],
    );
  }

  /// `File sent successfully!`
  String get fileSentSuccessfully {
    return Intl.message(
      'File sent successfully!',
      name: 'fileSentSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Copy Code`
  String get copyCode {
    return Intl.message('Copy Code', name: 'copyCode', desc: '', args: []);
  }

  /// `Code copied to clipboard`
  String get codeCopied {
    return Intl.message(
      'Code copied to clipboard',
      name: 'codeCopied',
      desc: '',
      args: [],
    );
  }

  /// `Share this code with the receiver`
  String get shareThisCode {
    return Intl.message(
      'Share this code with the receiver',
      name: 'shareThisCode',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for receiver to connect...`
  String get waitingForReceiver {
    return Intl.message(
      'Waiting for receiver to connect...',
      name: 'waitingForReceiver',
      desc: '',
      args: [],
    );
  }

  /// `Drag and drop file here`
  String get dragDropFile {
    return Intl.message(
      'Drag and drop file here',
      name: 'dragDropFile',
      desc: '',
      args: [],
    );
  }

  /// `Drop file to select`
  String get dropFileHere {
    return Intl.message(
      'Drop file to select',
      name: 'dropFileHere',
      desc: '',
      args: [],
    );
  }

  /// `or click the button below to browse`
  String get orClickToSelect {
    return Intl.message(
      'or click the button below to browse',
      name: 'orClickToSelect',
      desc: '',
      args: [],
    );
  }

  /// `===== Receiver Flow =====`
  String get _comment_receiver {
    return Intl.message(
      '===== Receiver Flow =====',
      name: '_comment_receiver',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code`
  String get enterCode {
    return Intl.message('Enter Code', name: 'enterCode', desc: '', args: []);
  }

  /// `Accept File`
  String get acceptFile {
    return Intl.message('Accept File', name: 'acceptFile', desc: '', args: []);
  }

  /// `Receiving File`
  String get receivingFileTitle {
    return Intl.message(
      'Receiving File',
      name: 'receivingFileTitle',
      desc: '',
      args: [],
    );
  }

  /// `File received successfully!`
  String get fileReceivedSuccessfully {
    return Intl.message(
      'File received successfully!',
      name: 'fileReceivedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Enter the 6-digit code from sender`
  String get enterCodePrompt {
    return Intl.message(
      'Enter the 6-digit code from sender',
      name: 'enterCodePrompt',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR Code`
  String get scanQrCode {
    return Intl.message('Scan QR Code', name: 'scanQrCode', desc: '', args: []);
  }

  /// `Point camera at the QR code shown by sender`
  String get scanQrCodePrompt {
    return Intl.message(
      'Point camera at the QR code shown by sender',
      name: 'scanQrCodePrompt',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message('OR', name: 'or', desc: '', args: []);
  }

  /// `Accept this file?`
  String get acceptFilePrompt {
    return Intl.message(
      'Accept this file?',
      name: 'acceptFilePrompt',
      desc: '',
      args: [],
    );
  }

  /// `===== Settings =====`
  String get _comment_settings {
    return Intl.message(
      '===== Settings =====',
      name: '_comment_settings',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message('Settings', name: 'settingsTitle', desc: '', args: []);
  }

  /// `Settings - Coming in Phase 7`
  String get settingsComingSoon {
    return Intl.message(
      'Settings - Coming in Phase 7',
      name: 'settingsComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Customize your PeerLink experience with theme and display preferences.`
  String get settingsInfo {
    return Intl.message(
      'Customize your PeerLink experience with theme and display preferences.',
      name: 'settingsInfo',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `Light Theme`
  String get themeLight {
    return Intl.message('Light Theme', name: 'themeLight', desc: '', args: []);
  }

  /// `Use light theme`
  String get themeLightDesc {
    return Intl.message(
      'Use light theme',
      name: 'themeLightDesc',
      desc: '',
      args: [],
    );
  }

  /// `Dark Theme`
  String get themeDark {
    return Intl.message('Dark Theme', name: 'themeDark', desc: '', args: []);
  }

  /// `Use dark theme`
  String get themeDarkDesc {
    return Intl.message(
      'Use dark theme',
      name: 'themeDarkDesc',
      desc: '',
      args: [],
    );
  }

  /// `System Default`
  String get themeSystem {
    return Intl.message(
      'System Default',
      name: 'themeSystem',
      desc: '',
      args: [],
    );
  }

  /// `Follow system theme`
  String get themeSystemDesc {
    return Intl.message(
      'Follow system theme',
      name: 'themeSystemDesc',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `PeerLink`
  String get appName {
    return Intl.message('PeerLink', name: 'appName', desc: '', args: []);
  }

  /// `Open Source Licenses`
  String get licenses {
    return Intl.message(
      'Open Source Licenses',
      name: 'licenses',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `===== Common Actions =====`
  String get _comment_actions {
    return Intl.message(
      '===== Common Actions =====',
      name: '_comment_actions',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Dismiss`
  String get dismiss {
    return Intl.message('Dismiss', name: 'dismiss', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `===== Error Messages =====`
  String get _comment_errors {
    return Intl.message(
      '===== Error Messages =====',
      name: '_comment_errors',
      desc: '',
      args: [],
    );
  }

  /// `File is larger than the 100MB limit.`
  String get errorFileTooLarge {
    return Intl.message(
      'File is larger than the 100MB limit.',
      name: 'errorFileTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the 6-digit code`
  String get errorCodeRequired {
    return Intl.message(
      'Please enter the 6-digit code',
      name: 'errorCodeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Code must be exactly 6 digits`
  String get errorCodeInvalid {
    return Intl.message(
      'Code must be exactly 6 digits',
      name: 'errorCodeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Camera permission is required to scan QR codes`
  String get errorCameraPermissionDenied {
    return Intl.message(
      'Camera permission is required to scan QR codes',
      name: 'errorCameraPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Camera permission permanently denied. Please enable it in device settings.`
  String get errorCameraPermissionPermanentlyDenied {
    return Intl.message(
      'Camera permission permanently denied. Please enable it in device settings.',
      name: 'errorCameraPermissionPermanentlyDenied',
      desc: '',
      args: [],
    );
  }

  /// `Connection timed out. Please check your network and try again.`
  String get errorConnectionTimeout {
    return Intl.message(
      'Connection timed out. Please check your network and try again.',
      name: 'errorConnectionTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Could not connect to the other device. Please verify the code.`
  String get errorCouldNotConnect {
    return Intl.message(
      'Could not connect to the other device. Please verify the code.',
      name: 'errorCouldNotConnect',
      desc: '',
      args: [],
    );
  }

  /// `Transfer stalled and was cancelled. Please try again.`
  String get errorTransferStalled {
    return Intl.message(
      'Transfer stalled and was cancelled. Please try again.',
      name: 'errorTransferStalled',
      desc: '',
      args: [],
    );
  }

  /// `File verification failed. The file may be corrupt. Please try sending again.`
  String get errorFileVerificationFailed {
    return Intl.message(
      'File verification failed. The file may be corrupt. Please try sending again.',
      name: 'errorFileVerificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Connection failed. The free service limit may have been reached. Please try again later.`
  String get errorTurnQuotaExceeded {
    return Intl.message(
      'Connection failed. The free service limit may have been reached. Please try again later.',
      name: 'errorTurnQuotaExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Camera permission is required to scan QR codes. Please grant permission in settings.`
  String get errorCameraPermission {
    return Intl.message(
      'Camera permission is required to scan QR codes. Please grant permission in settings.',
      name: 'errorCameraPermission',
      desc: '',
      args: [],
    );
  }

  /// `Storage permission is required to save files. Please grant permission in settings.`
  String get errorStoragePermission {
    return Intl.message(
      'Storage permission is required to save files. Please grant permission in settings.',
      name: 'errorStoragePermission',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied. Please check app permissions in settings.`
  String get errorPermissionDenied {
    return Intl.message(
      'Permission denied. Please check app permissions in settings.',
      name: 'errorPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Network error. Please check your internet connection and try again.`
  String get errorNetwork {
    return Intl.message(
      'Network error. Please check your internet connection and try again.',
      name: 'errorNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Session expired or invalid. Please generate a new code and try again.`
  String get errorSessionExpired {
    return Intl.message(
      'Session expired or invalid. Please generate a new code and try again.',
      name: 'errorSessionExpired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid code. Please check the code and try again.`
  String get errorInvalidCode {
    return Intl.message(
      'Invalid code. Please check the code and try again.',
      name: 'errorInvalidCode',
      desc: '',
      args: [],
    );
  }

  /// `Service temporarily unavailable. Please try again in a moment.`
  String get errorServiceUnavailable {
    return Intl.message(
      'Service temporarily unavailable. Please try again in a moment.',
      name: 'errorServiceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred. Please try again.`
  String get errorUnexpected {
    return Intl.message(
      'An unexpected error occurred. Please try again.',
      name: 'errorUnexpected',
      desc: '',
      args: [],
    );
  }

  /// `Unable to access file path. Please try again.`
  String get errorFilePathUnavailable {
    return Intl.message(
      'Unable to access file path. Please try again.',
      name: 'errorFilePathUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Selected file does not exist. Please try again.`
  String get errorFileNotFound {
    return Intl.message(
      'Selected file does not exist. Please try again.',
      name: 'errorFileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while picking the file`
  String get errorFilePickerFailed {
    return Intl.message(
      'An error occurred while picking the file',
      name: 'errorFilePickerFailed',
      desc: '',
      args: [],
    );
  }

  /// `===== File Size Units =====`
  String get _comment_units {
    return Intl.message(
      '===== File Size Units =====',
      name: '_comment_units',
      desc: '',
      args: [],
    );
  }

  /// `B`
  String get unitBytes {
    return Intl.message('B', name: 'unitBytes', desc: '', args: []);
  }

  /// `KB`
  String get unitKilobytes {
    return Intl.message('KB', name: 'unitKilobytes', desc: '', args: []);
  }

  /// `MB`
  String get unitMegabytes {
    return Intl.message('MB', name: 'unitMegabytes', desc: '', args: []);
  }

  /// `===== Placeholder Screens =====`
  String get _comment_placeholders {
    return Intl.message(
      '===== Placeholder Screens =====',
      name: '_comment_placeholders',
      desc: '',
      args: [],
    );
  }

  /// `Coming Soon`
  String get comingSoon {
    return Intl.message('Coming Soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Sender File Picker - Coming Soon`
  String get senderFilePickerPlaceholder {
    return Intl.message(
      'Sender File Picker - Coming Soon',
      name: 'senderFilePickerPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Sender Code Display - Coming Soon`
  String get senderCodePlaceholder {
    return Intl.message(
      'Sender Code Display - Coming Soon',
      name: 'senderCodePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Sender Progress - Coming Soon`
  String get senderProgressPlaceholder {
    return Intl.message(
      'Sender Progress - Coming Soon',
      name: 'senderProgressPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Receiver Code Entry - Coming Soon`
  String get receiverCodeEntryPlaceholder {
    return Intl.message(
      'Receiver Code Entry - Coming Soon',
      name: 'receiverCodeEntryPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Receiver Accept/Decline - Coming Soon`
  String get receiverAcceptPlaceholder {
    return Intl.message(
      'Receiver Accept/Decline - Coming Soon',
      name: 'receiverAcceptPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Receiver Progress - Coming Soon`
  String get receiverProgressPlaceholder {
    return Intl.message(
      'Receiver Progress - Coming Soon',
      name: 'receiverProgressPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `===== Loading States =====`
  String get _comment_loading {
    return Intl.message(
      '===== Loading States =====',
      name: '_comment_loading',
      desc: '',
      args: [],
    );
  }

  /// `Please wait...`
  String get pleaseWait {
    return Intl.message(
      'Please wait...',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
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

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

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(_current != null,
        'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(instance != null,
        'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `All System Settings`
  String get allSystemSettings {
    return Intl.message(
      'All System Settings',
      name: 'allSystemSettings',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Customize how your theme looks on your device`
  String get customizeTheme {
    return Intl.message(
      'Customize how your theme looks on your device',
      name: 'customizeTheme',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Select your language`
  String get selectLanguage {
    return Intl.message(
      'Select your language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Two-factor Authentication`
  String get twoFactorAuth {
    return Intl.message(
      'Two-factor Authentication',
      name: 'twoFactorAuth',
      desc: '',
      args: [],
    );
  }

  /// `Keep your account secure by enabling 2FA via mail`
  String get twoFactorDescription {
    return Intl.message(
      'Keep your account secure by enabling 2FA via mail',
      name: 'twoFactorDescription',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Push Notifications`
  String get mobilePushNotifications {
    return Intl.message(
      'Mobile Push Notifications',
      name: 'mobilePushNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive push notification`
  String get receivePushNotification {
    return Intl.message(
      'Receive push notification',
      name: 'receivePushNotification',
      desc: '',
      args: [],
    );
  }

  /// `Desktop Notification`
  String get desktopNotification {
    return Intl.message(
      'Desktop Notification',
      name: 'desktopNotification',
      desc: '',
      args: [],
    );
  }

  /// `Receive push notification in desktop`
  String get desktopPushDescription {
    return Intl.message(
      'Receive push notification in desktop',
      name: 'desktopPushDescription',
      desc: '',
      args: [],
    );
  }

  /// `Email Notifications`
  String get emailNotifications {
    return Intl.message(
      'Email Notifications',
      name: 'emailNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive email notification`
  String get receiveEmailNotification {
    return Intl.message(
      'Receive email notification',
      name: 'receiveEmailNotification',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message(
      'System',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get french {
    return Intl.message(
      'French',
      name: 'french',
      desc: '',
      args: [],
    );
  }

  /// `Robert Allen`
  String get robertAllen {
    return Intl.message(
      'Robert Allen',
      name: 'robertAllen',
      desc: '',
      args: [],
    );
  }

  /// `Junior Full Stack Developer`
  String get juniorFullStackDeveloper {
    return Intl.message(
      'Junior Full Stack Developer',
      name: 'juniorFullStackDeveloper',
      desc: '',
      args: [],
    );
  }

  /// `Total Employee`
  String get totalEmployee {
    return Intl.message(
      'Total Employee',
      name: 'totalEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Today Attendance`
  String get todayAttendance {
    return Intl.message(
      'Today Attendance',
      name: 'todayAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Pending Time Off`
  String get pendingTimeOff {
    return Intl.message(
      'Pending Time Off',
      name: 'pendingTimeOff',
      desc: '',
      args: [],
    );
  }

  /// `Total Departments`
  String get totalDepartments {
    return Intl.message(
      'Total Departments',
      name: 'totalDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Attendance Overview`
  String get attendanceOverview {
    return Intl.message(
      'Attendance Overview',
      name: 'attendanceOverview',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message(
      'Day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message(
      'Month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `Recent Events`
  String get recentEvents {
    return Intl.message(
      'Recent Events',
      name: 'recentEvents',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message(
      'View All',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }

  /// `Updated Server Logs`
  String get updatedServerLogs {
    return Intl.message(
      'Updated Server Logs',
      name: 'updatedServerLogs',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message(
      'Just now',
      name: 'justNow',
      desc: '',
      args: [],
    );
  }

  /// `Send Mail to HR and Admin`
  String get sendMailToHrAndAdmin {
    return Intl.message(
      'Send Mail to HR and Admin',
      name: 'sendMailToHrAndAdmin',
      desc: '',
      args: [],
    );
  }

  /// `min ago`
  String get minAgo {
    return Intl.message(
      'min ago',
      name: 'minAgo',
      desc: '',
      args: [],
    );
  }

  /// `Backup Files EOD`
  String get backupFilesEOD {
    return Intl.message(
      'Backup Files EOD',
      name: 'backupFilesEOD',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message(
      'Calendar',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message(
      'Messages',
      name: 'messages',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menu {
    return Intl.message(
      'Menu',
      name: 'menu',
      desc: '',
      args: [],
    );
  }

  /// `Employees`
  String get employees {
    return Intl.message(
      'Employees',
      name: 'employees',
      desc: '',
      args: [],
    );
  }

  /// `Employee Name`
  String get employeeName {
    return Intl.message(
      'Employee Name',
      name: 'employeeName',
      desc: '',
      args: [],
    );
  }

  /// `Employee ID`
  String get employeeId {
    return Intl.message(
      'Employee ID',
      name: 'employeeId',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get department {
    return Intl.message(
      'Department',
      name: 'department',
      desc: '',
      args: [],
    );
  }

  /// `Designation`
  String get designation {
    return Intl.message(
      'Designation',
      name: 'designation',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get action {
    return Intl.message(
      'Action',
      name: 'action',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Add New Employee`
  String get addNewEmployee {
    return Intl.message(
      'Add New Employee',
      name: 'addNewEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Total Employees`
  String get totalEmployees {
    return Intl.message(
      'Total Employees',
      name: 'totalEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Active Employees`
  String get activeEmployees {
    return Intl.message(
      'Active Employees',
      name: 'activeEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Recent Activities`
  String get recentActivities {
    return Intl.message(
      'Recent Activities',
      name: 'recentActivities',
      desc: '',
      args: [],
    );
  }

  /// `Pagination`
  String get pagination {
    return Intl.message(
      'Pagination',
      name: 'pagination',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get nextPage {
    return Intl.message(
      'Next',
      name: 'nextPage',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previousPage {
    return Intl.message(
      'Previous',
      name: 'previousPage',
      desc: '',
      args: [],
    );
  }

  /// `Page {current} of {total}`
  String pageOf(Object current, Object total) {
    return Intl.message(
      'Page $current of $total',
      name: 'pageOf',
      desc: '',
      args: [current, total],
    );
  }

  /// `Items per page`
  String get itemsPerPage {
    return Intl.message(
      'Items per page',
      name: 'itemsPerPage',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get inactive {
    return Intl.message(
      'Inactive',
      name: 'inactive',
      desc: '',
      args: [],
    );
  }

  /// `Contract`
  String get contract {
    return Intl.message(
      'Contract',
      name: 'contract',
      desc: '',
      args: [],
    );
  }

  /// `Full-time`
  String get fullTime {
    return Intl.message(
      'Full-time',
      name: 'fullTime',
      desc: '',
      args: [],
    );
  }

  /// `Part-time`
  String get partTime {
    return Intl.message(
      'Part-time',
      name: 'partTime',
      desc: '',
      args: [],
    );
  }

  /// `Remote`
  String get remote {
    return Intl.message(
      'Remote',
      name: 'remote',
      desc: '',
      args: [],
    );
  }

  /// `No employees found`
  String get noEmployeesFound {
    return Intl.message(
      'No employees found',
      name: 'noEmployeesFound',
      desc: '',
      args: [],
    );
  }

  /// `Select Department`
  String get selectDepartment {
    return Intl.message(
      'Select Department',
      name: 'selectDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Select Designation`
  String get selectDesignation {
    return Intl.message(
      'Select Designation',
      name: 'selectDesignation',
      desc: '',
      args: [],
    );
  }

  /// `Select Type`
  String get selectType {
    return Intl.message(
      'Select Type',
      name: 'selectType',
      desc: '',
      args: [],
    );
  }

  /// `Clear Filters`
  String get clearFilters {
    return Intl.message(
      'Clear Filters',
      name: 'clearFilters',
      desc: '',
      args: [],
    );
  }

  /// `Showing`
  String get showing {
    return Intl.message(
      'Showing',
      name: 'showing',
      desc: '',
      args: [],
    );
  }

  /// `to`
  String get to {
    return Intl.message(
      'to',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `out of`
  String get outOf {
    return Intl.message(
      'out of',
      name: 'outOf',
      desc: '',
      args: [],
    );
  }

  /// `records`
  String get records {
    return Intl.message(
      'records',
      name: 'records',
      desc: '',
      args: [],
    );
  }

  /// `...`
  String get ellipsis {
    return Intl.message(
      '...',
      name: 'ellipsis',
      desc: '',
      args: [],
    );
  }

  /// `Check-In Time`
  String get checkInTime {
    return Intl.message(
      'Check-In Time',
      name: 'checkInTime',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Actions`
  String get actions {
    return Intl.message(
      'Actions',
      name: 'actions',
      desc: '',
      args: [],
    );
  }

  /// `On Time`
  String get onTime {
    return Intl.message(
      'On Time',
      name: 'onTime',
      desc: '',
      args: [],
    );
  }

  /// `Late`
  String get late {
    return Intl.message(
      'Late',
      name: 'late',
      desc: '',
      args: [],
    );
  }

  /// `No attendance records found`
  String get noAttendanceRecords {
    return Intl.message(
      'No attendance records found',
      name: 'noAttendanceRecords',
      desc: '',
      args: [],
    );
  }

  /// `Add Employee`
  String get addEmployee {
    return Intl.message(
      'Add Employee',
      name: 'addEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get personalInformation {
    return Intl.message(
      'Personal Information',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Professional Information`
  String get professionalInformation {
    return Intl.message(
      'Professional Information',
      name: 'professionalInformation',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message(
      'First Name',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get lastName {
    return Intl.message(
      'Last Name',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number`
  String get mobileNumber {
    return Intl.message(
      'Mobile Number',
      name: 'mobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get emailAddress {
    return Intl.message(
      'Email Address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Date of Birth`
  String get dateOfBirth {
    return Intl.message(
      'Date of Birth',
      name: 'dateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Marital Status`
  String get maritalStatus {
    return Intl.message(
      'Marital Status',
      name: 'maritalStatus',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message(
      'Nationality',
      name: 'nationality',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `State`
  String get state {
    return Intl.message(
      'State',
      name: 'state',
      desc: '',
      args: [],
    );
  }

  /// `ZIP Code`
  String get zipCode {
    return Intl.message(
      'ZIP Code',
      name: 'zipCode',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop`
  String get dragAndDrop {
    return Intl.message(
      'Drag & Drop',
      name: 'dragAndDrop',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message(
      'or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `choose file`
  String get chooseFile {
    return Intl.message(
      'choose file',
      name: 'chooseFile',
      desc: '',
      args: [],
    );
  }

  /// `Supported formats: .jpeg, .png, .pdf`
  String get supportedFormats {
    return Intl.message(
      'Supported formats: .jpeg, .png, .pdf',
      name: 'supportedFormats',
      desc: '',
      args: [],
    );
  }

  /// `Employee Type`
  String get employeeType {
    return Intl.message(
      'Employee Type',
      name: 'employeeType',
      desc: '',
      args: [],
    );
  }

  /// `Working Days`
  String get workingDays {
    return Intl.message(
      'Working Days',
      name: 'workingDays',
      desc: '',
      args: [],
    );
  }

  /// `Joining Date`
  String get joiningDate {
    return Intl.message(
      'Joining Date',
      name: 'joiningDate',
      desc: '',
      args: [],
    );
  }

  /// `Office Location`
  String get officeLocation {
    return Intl.message(
      'Office Location',
      name: 'officeLocation',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get userName {
    return Intl.message(
      'User Name',
      name: 'userName',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `to upload`
  String get toUpload {
    return Intl.message(
      'to upload',
      name: 'toUpload',
      desc: '',
      args: [],
    );
  }

  /// `Employee Profile`
  String get employeeProfile {
    return Intl.message(
      'Employee Profile',
      name: 'employeeProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Request Leave`
  String get requestLeave {
    return Intl.message(
      'Request Leave',
      name: 'requestLeave',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message(
      'Duration',
      name: 'duration',
      desc: '',
      args: [],
    );
  }

  /// `Holidays`
  String get holidays {
    return Intl.message(
      'Holidays',
      name: 'holidays',
      desc: '',
      args: [],
    );
  }

  /// `Holidays List`
  String get holidaysList {
    return Intl.message(
      'Holidays List',
      name: 'holidaysList',
      desc: '',
      args: [],
    );
  }

  /// `No holidays found for this period`
  String get noHolidays {
    return Intl.message(
      'No holidays found for this period',
      name: 'noHolidays',
      desc: '',
      args: [],
    );
  }

  /// `Add Holiday`
  String get addHoliday {
    return Intl.message(
      'Add Holiday',
      name: 'addHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Name`
  String get holidayName {
    return Intl.message(
      'Holiday Name',
      name: 'holidayName',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Date`
  String get holidayDate {
    return Intl.message(
      'Holiday Date',
      name: 'holidayDate',
      desc: '',
      args: [],
    );
  }

  /// `Enter holiday name`
  String get enterHolidayName {
    return Intl.message(
      'Enter holiday name',
      name: 'enterHolidayName',
      desc: '',
      args: [],
    );
  }

  /// `Enter description (optional)`
  String get enterDescription {
    return Intl.message(
      'Enter description (optional)',
      name: 'enterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Type`
  String get holidayType {
    return Intl.message(
      'Holiday Type',
      name: 'holidayType',
      desc: '',
      args: [],
    );
  }

  /// `Recurring yearly`
  String get recurringYearly {
    return Intl.message(
      'Recurring yearly',
      name: 'recurringYearly',
      desc: '',
      args: [],
    );
  }

  /// `Holiday name is required`
  String get holidayNameRequired {
    return Intl.message(
      'Holiday name is required',
      name: 'holidayNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Holiday added successfully`
  String get holidayAddedSuccessfully {
    return Intl.message(
      'Holiday added successfully',
      name: 'holidayAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Holiday deleted successfully`
  String get holidayDeletedSuccessfully {
    return Intl.message(
      'Holiday deleted successfully',
      name: 'holidayDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get confirmDelete {
    return Intl.message(
      'Confirm Delete',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this holiday?`
  String get deleteHolidayConfirmation {
    return Intl.message(
      'Are you sure you want to delete this holiday?',
      name: 'deleteHolidayConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Recurring`
  String get recurring {
    return Intl.message(
      'Recurring',
      name: 'recurring',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Yearly Recurring Holiday`
  String get yearlyRecurring {
    return Intl.message(
      'Yearly Recurring Holiday',
      name: 'yearlyRecurring',
      desc: '',
      args: [],
    );
  }

  /// `First Occurrence`
  String get firstOccurrence {
    return Intl.message(
      'First Occurrence',
      name: 'firstOccurrence',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Information`
  String get holidayInfo {
    return Intl.message(
      'Holiday Information',
      name: 'holidayInfo',
      desc: '',
      args: [],
    );
  }

  /// `Holiday Details`
  String get holidayDetails {
    return Intl.message(
      'Holiday Details',
      name: 'holidayDetails',
      desc: '',
      args: [],
    );
  }

  /// `This is a public holiday. All employees are entitled to a day off with regular pay. If you need to work on this day, please contact HR for overtime approval.`
  String get publicHolidayInfo {
    return Intl.message(
      'This is a public holiday. All employees are entitled to a day off with regular pay. If you need to work on this day, please contact HR for overtime approval.',
      name: 'publicHolidayInfo',
      desc: '',
      args: [],
    );
  }

  /// `This is a company holiday. Regular employees are entitled to a day off. Specific departments may have different arrangements. Please check with your manager.`
  String get companyHolidayInfo {
    return Intl.message(
      'This is a company holiday. Regular employees are entitled to a day off. Specific departments may have different arrangements. Please check with your manager.',
      name: 'companyHolidayInfo',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all required fields`
  String get pleaseFillRequiredFields {
    return Intl.message(
      'Please fill in all required fields',
      name: 'pleaseFillRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming`
  String get upcoming {
    return Intl.message(
      'Upcoming',
      name: 'upcoming',
      desc: '',
      args: [],
    );
  }

  /// `Past Holidays`
  String get pastHolidays {
    return Intl.message(
      'Past Holidays',
      name: 'pastHolidays',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
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

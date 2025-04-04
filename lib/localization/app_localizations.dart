import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/intl/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode?.isEmpty ?? false ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String getString(String key) {
    switch(key) {
      case "settings": return settings;
      case "allSystemSettings": return allSystemSettings;
      case "appearance": return appearance;
      case "customizeTheme": return customizeTheme;
      case "language": return language;
      case "selectLanguage": return selectLanguage;
      case "twoFactorAuth": return twoFactorAuth;
      case "twoFactorDescription": return twoFactorDescription;
      case "mobilePushNotifications": return mobilePushNotifications;
      case "receivePushNotification": return receivePushNotification;
      case "desktopNotification": return desktopNotification;
      case "desktopPushDescription": return desktopPushDescription;
      case "emailNotifications": return emailNotifications;
      case "receiveEmailNotification": return receiveEmailNotification;
      case "juniorFullStackDeveloper": return juniorFullStackDeveloper;
      case "light": return light;
      case "dark": return dark;
      case "system": return system;
      case "home": return home;
      case "calendar": return calendar;
      case "add": return add;
      case "messages": return messages;
      case "menu": return menu;
      case "english": return english;
      case "french": return french;
      case "employees": return employees;
      case "employeeName": return employeeName;
      case "employeeId": return employeeId;
      case "department": return department;
      case "designation": return designation;
      case "type": return type;
      case "action": return action;
      case "search": return search;
      case "addNewEmployee": return addNewEmployee;
      case "filter": return filter;
      case "view": return view;
      case "edit": return edit;
      case "delete": return delete;
      case "totalEmployee": return totalEmployee;
      case "todayAttendance": return todayAttendance;
      case "pendingTimeOff": return pendingTimeOff;
      case "totalDepartments": return totalDepartments;
      case "attendanceOverview": return attendanceOverview;
      case "day": return day;
      case "month": return month;
      case "year": return year;
      case "recentEvents": return recentEvents;
      case "viewAll": return viewAll;
      case "updatedServerLogs": return updatedServerLogs;
      case "sendMailToHRAndAdmin": return sendMailToHRAndAdmin;
      case "backupFilesEOD": return backupFilesEOD;
      case "justNow": return justNow;
      case "minAgo": return minAgo;
      case "pagination": return pagination;
      case "nextPage": return nextPage;
      case "previousPage": return previousPage;
      case "pageOf": return pageOf;
      case "itemsPerPage": return itemsPerPage;
      case "active": return active;
      case "inactive": return inactive;
      case "contract": return contract;
      case "fullTime": return fullTime;
      case "partTime": return partTime;
      case "remote": return remote;
      case "noEmployeesFound": return noEmployeesFound;
      case "selectDepartment": return selectDepartment;
      case "selectDesignation": return selectDesignation;
      case "selectType": return selectType;
      case "clearFilters": return clearFilters;
      case "showingRecords": return showingRecords;
      case "outOf": return outOf;
      case "records": return records;
      case "showing": return showing;
      case "to": return to;
      case "ellipsis": return ellipsis;
      default: return key;
    }
  }
  String get showingRecords => Intl.message('Showing {start} to {end} out of {total} records', name: 'showingRecords');
  String get outOf => Intl.message('out of', name: 'outOf');
  String get records => Intl.message('records', name: 'records');
  String get showing => Intl.message('Showing', name: 'showing');
  String get to => Intl.message('to', name: 'to');
  String get ellipsis => Intl.message('...', name: 'ellipsis');
  String get pagination => Intl.message('Pagination', name: 'pagination');
  String get nextPage => Intl.message('Next', name: 'nextPage');
  String get previousPage => Intl.message('Previous', name: 'previousPage');
  String get pageOf => Intl.message('Page {current} of {total}', name: 'pageOf');
  String get itemsPerPage => Intl.message('Items per page', name: 'itemsPerPage');
  String get active => Intl.message('Active', name: 'active');
  String get inactive => Intl.message('Inactive', name: 'inactive');
  String get contract => Intl.message('Contract', name: 'contract');
  String get fullTime => Intl.message('Full-time', name: 'fullTime');
  String get partTime => Intl.message('Part-time', name: 'partTime');
  String get remote => Intl.message('Remote', name: 'remote');
  String get noEmployeesFound => Intl.message('No employees found', name: 'noEmployeesFound');
  String get selectDepartment => Intl.message('Select Department', name: 'selectDepartment');
  String get selectDesignation => Intl.message('Select Designation', name: 'selectDesignation');
  String get selectType => Intl.message('Select Type', name: 'selectType');
  String get clearFilters => Intl.message('Clear Filters', name: 'clearFilters');
  String get totalEmployee => Intl.message('Total Employee', name: 'totalEmployee');
  String get todayAttendance => Intl.message('Today Attendance', name: 'todayAttendance');
  String get pendingTimeOff => Intl.message('Pending Time Off', name: 'pendingTimeOff');
  String get totalDepartments => Intl.message('Total Departments', name: 'totalDepartments');
  String get attendanceOverview => Intl.message('Attendance Overview', name: 'attendanceOverview');
  String get day => Intl.message('Day', name: 'day');
  String get month => Intl.message('Month', name: 'month');
  String get year => Intl.message('Year', name: 'year');
  String get recentEvents => Intl.message('Recent Events', name: 'recentEvents');
  String get viewAll => Intl.message('View All', name: 'viewAll');
  String get updatedServerLogs => Intl.message('Updated Server Logs', name: 'updatedServerLogs');
  String get sendMailToHRAndAdmin => Intl.message('Send Mail to HR and Admin', name: 'sendMailToHRAndAdmin');
  String get backupFilesEOD => Intl.message('Backup Files EOD', name: 'backupFilesEOD');
  String get justNow => Intl.message('Just now', name: 'justNow');
  String get minAgo => Intl.message('min ago', name: 'minAgo');
  String get juniorFullStackDeveloper => Intl.message('Junior Full Stack Developer', name: 'juniorFullStackDeveloper');
  String get employees => Intl.message('Employees', name: 'employees');
  String get employeeName => Intl.message('Employee Name', name: 'employeeName');
  String get employeeId => Intl.message('Employee ID', name: 'employeeId');
  String get department => Intl.message('Department', name: 'department');
  String get designation => Intl.message('Designation', name: 'designation');
  String get type => Intl.message('Type', name: 'type');
  String get action => Intl.message('Action', name: 'action');
  String get search => Intl.message('Search', name: 'search');
  String get addNewEmployee => Intl.message('Add New Employee', name: 'addNewEmployee');
  String get filter => Intl.message('Filter', name: 'filter');
  String get view => Intl.message('View', name: 'view');
  String get edit => Intl.message('Edit', name: 'edit');
  String get delete => Intl.message('Delete', name: 'delete');
  String get totalEmployees => Intl.message('Total Employees', name: 'totalEmployees');
  String get activeEmployees => Intl.message('Active Employees', name: 'activeEmployees');
  String get recentActivities => Intl.message('Recent Activities', name: 'recentActivities');
  String get settings => Intl.message('Settings', name: 'settings');
  String get allSystemSettings => Intl.message('All System Settings', name: 'allSystemSettings');
  String get appearance => Intl.message('Appearance', name: 'appearance');
  String get customizeTheme => Intl.message('Customize how your theme looks on your device', name: 'customizeTheme');
  String get language => Intl.message('Language', name: 'language');
  String get selectLanguage => Intl.message('Select your language', name: 'selectLanguage');
  String get twoFactorAuthentication => Intl.message('Two-factor Authentication', name: 'twoFactorAuthentication');
  String get enable2FA => Intl.message('Keep your account secure by enabling 2FA via mail', name: 'enable2FA');
  String get mobilePushNotifications => Intl.message('Mobile Push Notifications', name: 'mobilePushNotifications');
  String get receivePushNotification => Intl.message('Receive push notification', name: 'receivePushNotification');
  String get desktopNotification => Intl.message('Desktop Notification', name: 'desktopNotification');
  String get receiveDesktopNotification => Intl.message('Receive push notification in desktop', name: 'receiveDesktopNotification');
  String get emailNotifications => Intl.message('Email Notifications', name: 'emailNotifications');
  String get receiveEmailNotification => Intl.message('Receive email notification', name: 'receiveEmailNotification');
  String get light => Intl.message('Light', name: 'light');
  String get dark => Intl.message('Dark', name: 'dark');
  String get system => Intl.message('System', name: 'system');
  String get home => Intl.message('Home', name: 'home');
  String get calendar => Intl.message('Calendar', name: 'calendar');
  String get add => Intl.message('Add', name: 'add');
  String get messages => Intl.message('Messages', name: 'messages');
  String get menu => Intl.message('Menu', name: 'menu');
  String get english => Intl.message('English', name: 'english');
  String get french => Intl.message('French', name: 'french');
  String get twoFactorDescription => Intl.message('Keep your account secure by enabling 2FA via mail', name: 'twoFactorDescription');
  String get desktopPushDescription => Intl.message('Receive push notification in desktop', name: 'desktopPushDescription');
  String get twoFactorAuth => Intl.message('Two-factor Authentication', name: 'twoFactorAuth');

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
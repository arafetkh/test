import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/intl/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode?.isEmpty ?? false
        ? locale.languageCode
        : locale.toString();
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
    switch (key) {
      case "settings":
        return settings;
      case "allSystemSettings":
        return allSystemSettings;
      case "appearance":
        return appearance;
      case "customizeTheme":
        return customizeTheme;
      case "language":
        return language;
      case "selectLanguage":
        return selectLanguage;
      case "twoFactorAuth":
        return twoFactorAuth;
      case "twoFactorDescription":
        return twoFactorDescription;
      case "mobilePushNotifications":
        return mobilePushNotifications;
      case "receivePushNotification":
        return receivePushNotification;
      case "desktopNotification":
        return desktopNotification;
      case "desktopPushDescription":
        return desktopPushDescription;
      case "emailNotifications":
        return emailNotifications;
      case "receiveEmailNotification":
        return receiveEmailNotification;
      case "juniorFullStackDeveloper":
        return juniorFullStackDeveloper;
      case "light":
        return light;
      case "dark":
        return dark;
      case "system":
        return system;
      case "home":
        return home;
      case "calendar":
        return calendar;
      case "add":
        return add;
      case "messages":
        return messages;
      case "menu":
        return menu;
      case "english":
        return english;
      case "french":
        return french;
      case "employees":
        return employees;
      case "employeeName":
        return employeeName;
      case "employeeId":
        return employeeId;
      case "department":
        return department;
      case "designation":
        return designation;
      case "type":
        return type;
      case "action":
        return action;
      case "search":
        return search;
      case "addNewEmployee":
        return addNewEmployee;
      case "filter":
        return filter;
      case "view":
        return view;
      case "edit":
        return edit;
      case "delete":
        return delete;
      case "totalEmployee":
        return totalEmployee;
      case "todayAttendance":
        return todayAttendance;
      case "pendingTimeOff":
        return pendingTimeOff;
      case "totalDepartments":
        return totalDepartments;
      case "attendanceOverview":
        return attendanceOverview;
      case "day":
        return day;
      case "month":
        return month;
      case "year":
        return year;
      case "recentEvents":
        return recentEvents;
      case "viewAll":
        return viewAll;
      case "updatedServerLogs":
        return updatedServerLogs;
      case "sendMailToHRAndAdmin":
        return sendMailToHRAndAdmin;
      case "backupFilesEOD":
        return backupFilesEOD;
      case "justNow":
        return justNow;
      case "minAgo":
        return minAgo;
      case "pagination":
        return pagination;
      case "nextPage":
        return nextPage;
      case "previousPage":
        return previousPage;
      case "pageOf":
        return pageOf;
      case "itemsPerPage":
        return itemsPerPage;
      case "active":
        return active;
      case "inactive":
        return inactive;
      case "contract":
        return contract;
      case "fullTime":
        return fullTime;
      case "partTime":
        return partTime;
      case "remote":
        return remote;
      case "noEmployeesFound":
        return noEmployeesFound;
      case "selectDepartment":
        return selectDepartment;
      case "selectDesignation":
        return selectDesignation;
      case "selectType":
        return selectType;
      case "clearFilters":
        return clearFilters;
      case "showingRecords":
        return showingRecords;
      case "outOf":
        return outOf;
      case "records":
        return records;
      case "showing":
        return showing;
      case "to":
        return to;
      case "ellipsis":
        return ellipsis;
      case "checkInTime":
        return checkInTime;
      case "status":
        return status;
      case "actions":
        return actions;
      case "onTime":
        return onTime;
      case "late":
        return late;
      case "noAttendanceRecords":
        return noAttendanceRecords;
      case "addEmployee":
        return addEmployee;
      case "personalInformation":
        return personalInformation;
      case "professionalInformation":
        return professionalInformation;
      case "firstName":
        return firstName;
      case "lastName":
        return lastName;
      case "mobileNumber":
        return mobileNumber;
      case "emailAddress":
        return emailAddress;
      case "dateOfBirth":
        return dateOfBirth;
      case "maritalStatus":
        return maritalStatus;
      case "gender":
        return gender;
      case "nationality":
        return nationality;
      case "address":
        return address;
      case "city":
        return city;
      case "state":
        return state;
      case "zipCode":
        return zipCode;
      case "dragAndDrop":
        return dragAndDrop;
      case "or":
        return or;
      case "chooseFile":
        return chooseFile;
      case "supportedFormats":
        return supportedFormats;
      case "employeeType":
        return employeeType;
      case "workingDays":
        return workingDays;
      case "joiningDate":
        return joiningDate;
      case "officeLocation":
        return officeLocation;
      case "userName":
        return userName;
      case "cancel":
        return cancel;
      case "back":
        return back;
      case "next":
        return next;
      case "apply":
        return apply;
      case "toUpload":
        return toUpload;
      case "holidays":
        return holidays;
      case "holidaysList":
        return holidaysList;
      case "noHolidays":
        return noHolidays;
      case "addHoliday":
        return addHoliday;
      case "holidayName":
        return holidayName;
      case "holidayDate":
        return holidayDate;
      case "enterHolidayName":
        return enterHolidayName;
      case "enterDescription":
        return enterDescription;
      case "description":
        return description;
      case "holidayType":
        return holidayType;
      case "recurringYearly":
        return recurringYearly;
      case "holidayNameRequired":
        return holidayNameRequired;
      case "holidayAddedSuccessfully":
        return holidayAddedSuccessfully;
      case "holidayDeletedSuccessfully":
        return holidayDeletedSuccessfully;
      case "confirmDelete":
        return confirmDelete;
      case "deleteHolidayConfirmation":
        return deleteHolidayConfirmation;
      case "recurring":
        return recurring;
      case "today":
        return today;
      case "date":
        return date;
      case "yearlyRecurring":
        return yearlyRecurring;
      case "firstOccurrence":
        return firstOccurrence;
      case "holidayInfo":
        return holidayInfo;
      case "holidayDetails":
        return holidayDetails;
      case "publicHolidayInfo":
        return publicHolidayInfo;
      case "companyHolidayInfo":
        return companyHolidayInfo;
      case "pleaseFillRequiredFields":
        return pleaseFillRequiredFields;
      case "upcoming":
        return upcoming;
      case "pastHolidays":
        return pastHolidays;
      case "members":
        return members;
      case "noDepartmentsFound":
        return noDepartmentsFound;
      case "departmentName":
        return departmentName;
      case "enterDepartmentName":
        return enterDepartmentName;
      case "departmentNameRequired":
        return departmentNameRequired;
      case "departmentAddedSuccessfully":
        return departmentAddedSuccessfully;
        case "addDepartment":
        return addDepartment;
      default:
        return key;
    }
  }

  String get addDepartment => Intl.message('Add Department', name: 'addDepartment');
  String get departmentName => Intl.message('Department Name', name: 'departmentName');
  String get enterDepartmentName => Intl.message('Enter department name', name: 'enterDepartmentName');
  String get departmentNameRequired => Intl.message('Department name is required', name: 'departmentNameRequired');
  String get departmentAddedSuccessfully => Intl.message('Department added successfully', name: 'departmentAddedSuccessfully');
  String get noDepartmentsFound =>
      Intl.message('No departments found', name: 'noDepartmentsFound');
  String get members =>
      Intl.message('Members', name: 'members');

  String get addEmployee => Intl.message('Add Employee', name: 'addEmployee');

  String get personalInformation =>
      Intl.message('Personal Information', name: 'personalInformation');

  String get professionalInformation =>
      Intl.message('Professional Information', name: 'professionalInformation');

  String get firstName => Intl.message('First Name', name: 'firstName');

  String get lastName => Intl.message('Last Name', name: 'lastName');

  String get mobileNumber =>
      Intl.message('Mobile Number', name: 'mobileNumber');

  String get emailAddress =>
      Intl.message('Email Address', name: 'emailAddress');

  String get dateOfBirth => Intl.message('Date of Birth', name: 'dateOfBirth');

  String get maritalStatus =>
      Intl.message('Marital Status', name: 'maritalStatus');

  String get gender => Intl.message('Gender', name: 'gender');

  String get nationality => Intl.message('Nationality', name: 'nationality');

  String get address => Intl.message('Address', name: 'address');

  String get city => Intl.message('City', name: 'city');

  String get state => Intl.message('State', name: 'state');

  String get zipCode => Intl.message('ZIP Code', name: 'zipCode');

  String get dragAndDrop => Intl.message('Drag & Drop', name: 'dragAndDrop');

  String get or => Intl.message('or', name: 'or');

  String get chooseFile => Intl.message('choose file', name: 'chooseFile');

  String get supportedFormats =>
      Intl.message('Supported formats: .jpeg, .png, .pdf',
          name: 'supportedFormats');

  String get employeeType =>
      Intl.message('Employee Type', name: 'employeeType');

  String get workingDays => Intl.message('Working Days', name: 'workingDays');

  String get joiningDate => Intl.message('Joining Date', name: 'joiningDate');

  String get officeLocation =>
      Intl.message('Office Location', name: 'officeLocation');

  String get userName => Intl.message('User Name', name: 'userName');

  String get cancel => Intl.message('Cancel', name: 'cancel');

  String get back => Intl.message('Back', name: 'back');

  String get next => Intl.message('Next', name: 'next');

  String get apply => Intl.message('Apply', name: 'apply');

  String get toUpload => Intl.message('to upload', name: 'toUpload');
  String get checkInTime => Intl.message('Check-In Time', name: 'checkInTime');
  String get status => Intl.message('Status', name: 'status');
  String get actions => Intl.message('Actions', name: 'actions');
  String get onTime => Intl.message('On Time', name: 'onTime');
  String get late => Intl.message('Late', name: 'late');
  String get noAttendanceRecords =>
      Intl.message('No attendance records found', name: 'noAttendanceRecords');

  String get showingRecords =>
      Intl.message('Showing {start} to {end} out of {total} records',
          name: 'showingRecords');
  String get outOf => Intl.message('out of', name: 'outOf');
  String get records => Intl.message('records', name: 'records');
  String get showing => Intl.message('Showing', name: 'showing');
  String get to => Intl.message('to', name: 'to');
  String get ellipsis => Intl.message('...', name: 'ellipsis');
  String get pagination => Intl.message('Pagination', name: 'pagination');
  String get nextPage => Intl.message('Next', name: 'nextPage');
  String get previousPage => Intl.message('Previous', name: 'previousPage');

  String get pageOf =>
      Intl.message('Page {current} of {total}', name: 'pageOf');

  String get itemsPerPage =>
      Intl.message('Items per page', name: 'itemsPerPage');
  String get active => Intl.message('Active', name: 'active');
  String get inactive => Intl.message('Inactive', name: 'inactive');
  String get contract => Intl.message('Contract', name: 'contract');
  String get fullTime => Intl.message('Full-time', name: 'fullTime');
  String get partTime => Intl.message('Part-time', name: 'partTime');
  String get remote => Intl.message('Remote', name: 'remote');

  String get noEmployeesFound =>
      Intl.message('No employees found', name: 'noEmployeesFound');

  String get selectDepartment =>
      Intl.message('Select Department', name: 'selectDepartment');

  String get selectDesignation =>
      Intl.message('Select Designation', name: 'selectDesignation');
  String get selectType => Intl.message('Select Type', name: 'selectType');

  String get clearFilters =>
      Intl.message('Clear Filters', name: 'clearFilters');

  String get totalEmployee =>
      Intl.message('Total Employee', name: 'totalEmployee');

  String get todayAttendance =>
      Intl.message('Today Attendance', name: 'todayAttendance');

  String get pendingTimeOff =>
      Intl.message('Pending Time Off', name: 'pendingTimeOff');

  String get totalDepartments =>
      Intl.message('Total Departments', name: 'totalDepartments');

  String get attendanceOverview =>
      Intl.message('Attendance Overview', name: 'attendanceOverview');
  String get day => Intl.message('Day', name: 'day');
  String get month => Intl.message('Month', name: 'month');
  String get year => Intl.message('Year', name: 'year');

  String get recentEvents =>
      Intl.message('Recent Events', name: 'recentEvents');
  String get viewAll => Intl.message('View All', name: 'viewAll');

  String get updatedServerLogs =>
      Intl.message('Updated Server Logs', name: 'updatedServerLogs');

  String get sendMailToHRAndAdmin =>
      Intl.message('Send Mail to HR and Admin', name: 'sendMailToHRAndAdmin');

  String get backupFilesEOD =>
      Intl.message('Backup Files EOD', name: 'backupFilesEOD');
  String get justNow => Intl.message('Just now', name: 'justNow');
  String get minAgo => Intl.message('min ago', name: 'minAgo');

  String get juniorFullStackDeveloper =>
      Intl.message('Junior Full Stack Developer',
          name: 'juniorFullStackDeveloper');
  String get employees => Intl.message('Employees', name: 'employees');

  String get employeeName =>
      Intl.message('Employee Name', name: 'employeeName');
  String get employeeId => Intl.message('Employee ID', name: 'employeeId');
  String get department => Intl.message('Department', name: 'department');
  String get designation => Intl.message('Designation', name: 'designation');
  String get type => Intl.message('Type', name: 'type');
  String get action => Intl.message('Action', name: 'action');
  String get search => Intl.message('Search', name: 'search');

  String get addNewEmployee =>
      Intl.message('Add New Employee', name: 'addNewEmployee');
  String get filter => Intl.message('Filter', name: 'filter');
  String get view => Intl.message('View', name: 'view');
  String get edit => Intl.message('Edit', name: 'edit');
  String get delete => Intl.message('Delete', name: 'delete');

  String get totalEmployees =>
      Intl.message('Total Employees', name: 'totalEmployees');

  String get activeEmployees =>
      Intl.message('Active Employees', name: 'activeEmployees');

  String get recentActivities =>
      Intl.message('Recent Activities', name: 'recentActivities');
  String get settings => Intl.message('Settings', name: 'settings');

  String get allSystemSettings =>
      Intl.message('All System Settings', name: 'allSystemSettings');
  String get appearance => Intl.message('Appearance', name: 'appearance');

  String get customizeTheme =>
      Intl.message('Customize how your theme looks on your device',
          name: 'customizeTheme');
  String get language => Intl.message('Language', name: 'language');

  String get selectLanguage =>
      Intl.message('Select your language', name: 'selectLanguage');

  String get twoFactorAuthentication =>
      Intl.message('Two-factor Authentication',
          name: 'twoFactorAuthentication');

  String get enable2FA =>
      Intl.message('Keep your account secure by enabling 2FA via mail',
          name: 'enable2FA');

  String get mobilePushNotifications =>
      Intl.message('Mobile Push Notifications',
          name: 'mobilePushNotifications');

  String get receivePushNotification =>
      Intl.message('Receive push notification',
          name: 'receivePushNotification');

  String get desktopNotification =>
      Intl.message('Desktop Notification', name: 'desktopNotification');

  String get receiveDesktopNotification =>
      Intl.message('Receive push notification in desktop',
          name: 'receiveDesktopNotification');

  String get emailNotifications =>
      Intl.message('Email Notifications', name: 'emailNotifications');

  String get receiveEmailNotification =>
      Intl.message('Receive email notification',
          name: 'receiveEmailNotification');
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

  String get twoFactorDescription =>
      Intl.message('Keep your account secure by enabling 2FA via mail',
          name: 'twoFactorDescription');

  String get desktopPushDescription =>
      Intl.message('Receive push notification in desktop',
          name: 'desktopPushDescription');

  String get twoFactorAuth =>
      Intl.message('Two-factor Authentication', name: 'twoFactorAuth');

  //holidays
  String get holidays => Intl.message('Holidays', name: 'holidays');
  String get holidaysList =>
      Intl.message('Holidays List', name: 'holidaysList');
  String get noHolidays =>
      Intl.message('No holidays found for this period', name: 'noHolidays');
  String get addHoliday => Intl.message('Add Holiday', name: 'addHoliday');
  String get holidayName => Intl.message('Holiday Name', name: 'holidayName');
  String get holidayDate => Intl.message('Holiday Date', name: 'holidayDate');
  String get enterHolidayName =>
      Intl.message('Enter holiday name', name: 'enterHolidayName');
  String get enterDescription =>
      Intl.message('Enter description (optional)', name: 'enterDescription');
  String get description => Intl.message('Description', name: 'description');
  String get holidayType => Intl.message('Holiday Type', name: 'holidayType');
  String get recurringYearly =>
      Intl.message('Recurring yearly', name: 'recurringYearly');
  String get holidayNameRequired =>
      Intl.message('Holiday name is required', name: 'holidayNameRequired');
  String get holidayAddedSuccessfully =>
      Intl.message('Holiday added successfully',
          name: 'holidayAddedSuccessfully');
  String get holidayDeletedSuccessfully =>
      Intl.message('Holiday deleted successfully',
          name: 'holidayDeletedSuccessfully');
  String get confirmDelete =>
      Intl.message('Confirm Delete', name: 'confirmDelete');
  String get deleteHolidayConfirmation =>
      Intl.message('Are you sure you want to delete this holiday?',
          name: 'deleteHolidayConfirmation');
  String get recurring => Intl.message('Recurring', name: 'recurring');
  String get today => Intl.message('Today', name: 'today');
  String get date => Intl.message('Date', name: 'date');
  String get yearlyRecurring =>
      Intl.message('Yearly Recurring Holiday', name: 'yearlyRecurring');
  String get firstOccurrence =>
      Intl.message('First Occurrence', name: 'firstOccurrence');
  String get holidayInfo =>
      Intl.message('Holiday Information', name: 'holidayInfo');
  String get holidayDetails =>
      Intl.message('Holiday Details', name: 'holidayDetails');
  String get publicHolidayInfo => Intl.message(
      'This is a public holiday. All employees are entitled to a day off with regular pay. If you need to work on this day, please contact HR for overtime approval.',
      name: 'publicHolidayInfo');
  String get companyHolidayInfo => Intl.message(
      'This is a company holiday. Regular employees are entitled to a day off. Specific departments may have different arrangements. Please check with your manager.',
      name: 'companyHolidayInfo');
  String get pleaseFillRequiredFields =>
      Intl.message('Please fill in all required fields',
          name: 'pleaseFillRequiredFields');
  String get upcoming => Intl.message('Upcoming', name: 'upcoming');
  String get pastHolidays =>
      Intl.message('Past Holidays', name: 'pastHolidays');
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

import 'package:flutter/material.dart';
import 'package:in_out/data/employees_data.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/provider/language_provider.dart';
import 'package:in_out/services/NationalityService.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/LandscapeUserProfileHeader.dart';
import 'package:provider/provider.dart';
// Import our nationality service

class AddEmployeeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onEmployeeAdded;

  const AddEmployeeScreen({
    super.key,
    this.onEmployeeAdded,
  });

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  // Selected values for dropdowns
  String? _selectedMaritalStatus;
  String? _selectedGender;
  String? _selectedNationality;
  String? _selectedCity;
  String? _selectedState;
  String? _selectedZipCode;
  String? _selectedEmployeeType;
  String? _selectedDepartment;
  String? _selectedWorkingDays;
  String? _selectedOfficeLocation;

  // Birth date and joining date
  DateTime? _dateOfBirth;
  DateTime? _joiningDate;

  bool _isPersonalInfoActive = true;
  bool _isProfessionalInfoActive = false;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _formIsValid = false;

  // Nationality lists
  List<String> _nationalities = [];
  final _nationalityService = NationalityService();
  bool _nationalitiesLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Initialize default values for dropdowns
    _selectedEmployeeType = 'Full-time';
    _selectedDepartment = 'IT';
    _selectedWorkingDays = 'Monday-Friday';
    _selectedOfficeLocation = 'Headquarters';
    _joiningDate = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load nationalities in didChangeDependencies instead of initState
    if (!_nationalitiesLoaded) {
      _loadNationalities();
      _nationalitiesLoaded = true;
    }
  }

  Future<void> _loadNationalities() async {
    // Get language from provider
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final String languageCode = languageProvider.currentLanguage;

    // Load nationalities using our service
    final nationalities =
        await _nationalityService.getNationalitiesByLanguage(languageCode);

    if (mounted) {
      setState(() {
        _nationalities = nationalities;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _employeeIdController.dispose();
    _userNameController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 50;
    });
  }

  void _toggleTab(bool isPersonal) {
    setState(() {
      _isPersonalInfoActive = isPersonal;
      _isProfessionalInfoActive = !isPersonal;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate
          ? (_dateOfBirth ?? DateTime(2000))
          : (_joiningDate ?? DateTime.now()),
      firstDate: isBirthDate ? DateTime(1950) : DateTime(2000),
      lastDate: isBirthDate ? DateTime.now() : DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = picked;
        } else {
          _joiningDate = picked;
        }
      });
    }
  }

  void _validateForm() {
    if (_isPersonalInfoActive) {
      // Validate personal info
      _formIsValid = _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty;
    } else {
      // Validate professional info
      _formIsValid = _employeeIdController.text.isNotEmpty &&
          _userNameController.text.isNotEmpty;
    }
  }

  void _createEmployee() {
    // Only proceed if we're on the professional tab and data is valid
    if (!_isProfessionalInfoActive) {
      _toggleTab(false);
      return;
    }

    // Validate form
    _validateForm();
    if (!_formIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    // Create employee data
    final String fullName =
        '${_firstNameController.text} ${_lastNameController.text}';
    final String initials = _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty
        ? '${_firstNameController.text[0]}${_lastNameController.text[0]}'
        : 'NN';

    final newEmployee = {
      'name': fullName,
      'avatar': initials,
      'avatarColor': Colors.blue.shade100,
      'textColor': Colors.blue.shade800,
      'id': _employeeIdController.text,
      'department': _selectedDepartment ?? 'IT',
      'designation': _userNameController.text,
      'type': _selectedEmployeeType ?? 'Full-time',
    };

    // Call the callback if it exists
    if (widget.onEmployeeAdded != null) {
      widget.onEmployeeAdded!(newEmployee);
    }

    // Add to employee list directly if needed
    employees.add(newEmployee);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Employee added successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            LandscapeUserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {},
            ),

            // Title and breadcrumb
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenHeight * 0.01,
              ),
              child: Row(
                children: [
                  Text(
                    localizations.getString('addEmployee'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.016,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    '/ ${localizations.getString('employees')} / ${localizations.getString('addEmployee')}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.012,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                margin: EdgeInsets.all(screenWidth * 0.01),
                decoration: BoxDecoration(
                  color: AdaptiveColors.cardColor(context),
                  borderRadius: BorderRadius.circular(screenWidth * 0.005),
                  boxShadow: [
                    BoxShadow(
                      color: AdaptiveColors.shadowColor(context),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Tabs for Personal/Professional Information
                    _buildTabs(context, screenWidth, screenHeight),

                    // Form
                    Expanded(
                      child: Form(
                        key: _formKey,
                        onChanged: () {
                          _validateForm();
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.all(screenWidth * 0.01),
                          child: _isPersonalInfoActive
                              ? _buildPersonalInfoForm(
                                  context, screenWidth, screenHeight)
                              : _buildProfessionalInfoForm(
                                  context, screenWidth, screenHeight),
                        ),
                      ),
                    ),

                    // Action buttons at the bottom
                    _buildActionButtons(context, screenWidth, screenHeight),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(
      BuildContext context, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AdaptiveColors.borderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _toggleTab(true),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _isPersonalInfoActive
                          ? const Color(0xFF2E7D32)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: _isPersonalInfoActive
                          ? const Color(0xFF2E7D32)
                          : AdaptiveColors.secondaryTextColor(context),
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.005),
                    Text(
                      localizations.getString('personalInformation'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.01,
                        fontWeight: _isPersonalInfoActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _isPersonalInfoActive
                            ? const Color(0xFF2E7D32)
                            : AdaptiveColors.secondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Professional Information Tab
          Expanded(
            child: InkWell(
              onTap: () => _toggleTab(false),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _isProfessionalInfoActive
                          ? const Color(0xFF2E7D32)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work,
                      color: _isProfessionalInfoActive
                          ? const Color(0xFF2E7D32)
                          : AdaptiveColors.secondaryTextColor(context),
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.005),
                    Text(
                      localizations.getString('professionalInformation'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.01,
                        fontWeight: _isProfessionalInfoActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _isProfessionalInfoActive
                            ? const Color(0xFF2E7D32)
                            : AdaptiveColors.secondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm(
      BuildContext context, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);
    final fieldHeight = screenHeight * 0.065; // Consistent field height

    return Column(
      children: [
        // First row: First Name and Last Name
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _firstNameController,
                localizations.getString('firstName'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildTextField(
                context,
                _lastNameController,
                localizations.getString('lastName'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Second row: Mobile Number and Email
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _mobileNumberController,
                localizations.getString('mobileNumber'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildTextField(
                context,
                _emailController,
                localizations.getString('emailAddress'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Third row: Date of Birth and Marital Status
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                localizations.getString('dateOfBirth'),
                screenWidth,
                screenHeight,
                isBirthDate: true,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('maritalStatus'),
                ['Single', 'Married', 'Divorced', 'Widowed'],
                _selectedMaritalStatus,
                (value) {
                  setState(() {
                    _selectedMaritalStatus = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Fourth row: Gender and Nationality
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('gender'),
                ['Male', 'Female', 'Other'],
                _selectedGender,
                (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('nationality'),
                _nationalities.isEmpty ? ['Loading...'] : _nationalities,
                _selectedNationality,
                (value) {
                  setState(() {
                    _selectedNationality = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Fifth row: Address
        _buildTextField(
          context,
          _addressController,
          localizations.getString('address'),
          screenWidth,
          screenHeight,
          fieldHeight: fieldHeight,
        ),
        SizedBox(height: screenHeight * 0.02),

        // Sixth row: City, State and Zip Code
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('city'),
                [
                  'New York',
                  'Los Angeles',
                  'Chicago',
                  'Houston',
                  'Phoenix',
                  'Other'
                ],
                _selectedCity,
                (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('state'),
                ['NY', 'CA', 'IL', 'TX', 'AZ', 'Other'],
                _selectedState,
                (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('zipCode'),
                ['10001', '90001', '60601', '77001', '85001', 'Other'],
                _selectedZipCode,
                (value) {
                  setState(() {
                    _selectedZipCode = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Image upload area
        Container(
          height: screenHeight * 0.2,
          decoration: BoxDecoration(
            border: Border.all(
              color: AdaptiveColors.borderColor(context),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.005),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.03,
                  height: screenWidth * 0.03,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.upload_file,
                    color: const Color(0xFF2E7D32),
                    size: screenWidth * 0.015,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '${localizations.getString('dragAndDrop')} ${localizations.getString('or')} ${localizations.getString('chooseFile')} ${localizations.getString('toUpload')}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.009,
                    color: AdaptiveColors.primaryTextColor(context),
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  localizations.getString('supportedFormats'),
                  style: TextStyle(
                    fontSize: screenWidth * 0.007,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoForm(
      BuildContext context, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);
    final fieldHeight = screenHeight * 0.065; // Consistent field height

    return Column(
      children: [
        // First row: Employee ID and User Name
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _employeeIdController,
                localizations.getString('employeeId'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildTextField(
                context,
                _userNameController,
                localizations.getString('userName'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Second row: Employee Type and Department
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('employeeType'),
                ['Full-time', 'Part-time', 'Contract', 'Remote'],
                _selectedEmployeeType,
                (value) {
                  setState(() {
                    _selectedEmployeeType = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('department'),
                [
                  'HR',
                  'IT',
                  'Finance',
                  'Marketing',
                  'Sales',
                  'Design',
                  'Development'
                ],
                _selectedDepartment,
                (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Third row: Working Days and Joining Date
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('workingDays'),
                ['Monday-Friday', 'Monday-Saturday', 'Custom'],
                _selectedWorkingDays,
                (value) {
                  setState(() {
                    _selectedWorkingDays = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDateField(
                context,
                localizations.getString('joiningDate'),
                screenWidth,
                screenHeight,
                isBirthDate: false,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Fourth row: Office Location
        _buildDropdown(
          context,
          localizations.getString('officeLocation'),
          ['Office', 'Remote'],
          _selectedOfficeLocation,
          (value) {
            setState(() {
              _selectedOfficeLocation = value;
            });
          },
          screenWidth,
          screenHeight,
          fieldHeight: fieldHeight,
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller,
      String label,
      double screenWidth,
      double screenHeight,
      {double? fieldHeight}) {
    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: AdaptiveColors.borderColor(context),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.005),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.01,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
          // Change from never to auto to keep the label visible
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.01,
            vertical: fieldHeight != null
                ? fieldHeight / 2 - screenWidth * 0.01
                : screenHeight * 0.015,
          ),
        ),
        style: TextStyle(
          fontSize: screenWidth * 0.01,
          color: AdaptiveColors.primaryTextColor(context),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context,
      String label,
      double screenWidth,
      double screenHeight,
      {required bool isBirthDate, double? fieldHeight}) {
    final DateTime? dateValue = isBirthDate ? _dateOfBirth : _joiningDate;
    final String displayText = dateValue != null
        ? '${dateValue.day.toString().padLeft(2, '0')}/${dateValue.month
        .toString().padLeft(2, '0')}/${dateValue.year}'
        : label;

    return InkWell(
      onTap: () => _selectDate(context, isBirthDate),
      child: Container(
        height: fieldHeight,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.01,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AdaptiveColors.borderColor(context),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.005),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayText,
              style: TextStyle(
                fontSize: screenWidth * 0.01,
                color: dateValue != null
                    ? AdaptiveColors.primaryTextColor(context)
                    : AdaptiveColors.secondaryTextColor(context),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: AdaptiveColors.secondaryTextColor(context),
              size: screenWidth * 0.012,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context,
      String label,
      List<String> items,
      String? selectedValue,
      Function(String?) onChanged,
      double screenWidth,
      double screenHeight,
      {double? fieldHeight}) {
    return Container(
      height: fieldHeight,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AdaptiveColors.borderColor(context),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.005),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.01,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AdaptiveColors.secondaryTextColor(context),
            size: screenWidth * 0.012,
          ),
          isExpanded: true,
          dropdownColor: AdaptiveColors.cardColor(context),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: screenWidth * 0.01,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);
    final buttonHeight = screenHeight * 0.05; // Consistent button height

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.01),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AdaptiveColors.borderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel/Back button
          OutlinedButton(
            onPressed: () {
              if (_isProfessionalInfoActive) {
                _toggleTab(true);
              } else {
                Navigator.pop(context);
              }
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(screenWidth * 0.08, buttonHeight),
              side: BorderSide(color: AdaptiveColors.borderColor(context)),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.003),
              ),
            ),
            child: Text(
              _isPersonalInfoActive
                  ? localizations.getString('cancel')
                  : localizations.getString('back'),
              style: TextStyle(
                fontSize: screenWidth * 0.009,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.01),

          // Next/Apply button
          ElevatedButton(
            onPressed: () {
              if (_isPersonalInfoActive) {
                // Move to professional information tab
                _toggleTab(false);
              } else {
                // Create and save employee
                _createEmployee();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(screenWidth * 0.08, buttonHeight),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.003),
              ),
            ),
            child: Text(
              _isPersonalInfoActive
                  ? localizations.getString('next')
                  : localizations.getString('apply'),
              style: TextStyle(
                fontSize: screenWidth * 0.009,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

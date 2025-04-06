import 'package:flutter/material.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/LandscapeUserProfileHeader.dart';
import 'package:in_out/localization/app_localizations.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  // Controllers pour les champs de texte
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Valeurs sélectionnées pour les dropdown
  String? _selectedMaritalStatus;
  String? _selectedGender;
  String? _selectedNationality;
  String? _selectedCity;
  String? _selectedState;
  String? _selectedZipCode;

  // Date de naissance
  DateTime? _dateOfBirth;

  bool _isPersonalInfoActive = true;
  bool _isProfessionalInfoActive = false;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
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

            // Titre et fil d'Ariane
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
                    '/ ${localizations.getString('allEmployees')} / ${localizations.getString('addEmployee')}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.012,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu principal
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
                    // Onglets Personal/Professional Information
                    _buildTabs(context, screenWidth, screenHeight),

                    // Formulaire
                    Expanded(
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

                    // Boutons d'action en bas
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
          // Tab Personal Information
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

          // Tab Professional Information
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

    return Column(
      children: [
        // Première rangée: Prénom et Nom
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _firstNameController,
                localizations.getString('firstName'),
                screenWidth,
                screenHeight,
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
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Deuxième rangée: Téléphone et Email
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _mobileNumberController,
                localizations.getString('mobileNumber'),
                screenWidth,
                screenHeight,
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
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Troisième rangée: Date de naissance et État civil
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                localizations.getString('dateOfBirth'),
                screenWidth,
                screenHeight,
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
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Quatrième rangée: Genre et Nationalité
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
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('nationality'),
                [
                  'American',
                  'British',
                  'Canadian',
                  'French',
                  'German',
                  'Other'
                ],
                _selectedNationality,
                (value) {
                  setState(() {
                    _selectedNationality = value;
                  });
                },
                screenWidth,
                screenHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Cinquième rangée: Adresse
        _buildTextField(
          context,
          _addressController,
          localizations.getString('address'),
          screenWidth,
          screenHeight,
        ),
        SizedBox(height: screenHeight * 0.02),

        // Sixième rangée: Ville, État et Code postal
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
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Zone de dépôt d'image
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

    return Column(
      children: [
        // Première rangée: ID employé et nom d'utilisateur
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                TextEditingController(),
                localizations.getString('employeeId'),
                screenWidth,
                screenHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildTextField(
                context,
                TextEditingController(),
                localizations.getString('userName'),
                screenWidth,
                screenHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Deuxième rangée: Type employé et département
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('employeeType'),
                ['Full-time', 'Part-time', 'Contract', 'Remote'],
                null,
                (value) {},
                screenWidth,
                screenHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('department'),
                ['HR', 'IT', 'Finance', 'Marketing', 'Sales', 'Operations'],
                null,
                (value) {},
                screenWidth,
                screenHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Troisième rangée: Jours de travail et date d'arrivée
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('workingDays'),
                ['Monday-Friday', 'Monday-Saturday', 'Custom'],
                null,
                (value) {},
                screenWidth,
                screenHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDateField(
                context,
                localizations.getString('joiningDate'),
                screenWidth,
                screenHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Quatrième rangée: Emplacement du bureau
        _buildDropdown(
          context,
          localizations.getString('officeLocation'),
          ['Headquarters', 'Branch A', 'Branch B', 'Remote'],
          null,
          (value) {},
          screenWidth,
          screenHeight,
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
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
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.01,
            vertical: screenHeight * 0.015,
          ),
        ),
        style: TextStyle(
          fontSize: screenWidth * 0.01,
          color: AdaptiveColors.primaryTextColor(context),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    double screenWidth,
    double screenHeight,
  ) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.01,
          vertical: screenHeight * 0.015,
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
              _dateOfBirth != null
                  ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                  : label,
              style: TextStyle(
                fontSize: screenWidth * 0.01,
                color: _dateOfBirth != null
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

  Widget _buildDropdown(
    BuildContext context,
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
        vertical: selectedValue != null ? screenHeight * 0.005 : 0,
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
          // Bouton Annuler/Retour
          OutlinedButton(
            onPressed: () {
              if (_isProfessionalInfoActive) {
                _toggleTab(true);
              } else {
                Navigator.pop(context);
              }
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AdaptiveColors.borderColor(context)),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
                vertical: screenHeight * 0.01,
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

          // Bouton Next/Apply
          ElevatedButton(
            onPressed: () {
              if (_isPersonalInfoActive) {
                // Passer à l'onglet information professionnelle
                _toggleTab(false);
              } else {
                // Soumettre le formulaire
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
                vertical: screenHeight * 0.01,
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

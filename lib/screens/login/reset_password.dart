import 'package:flutter/material.dart';

import 'password_success_dialog.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Controllers for password fields
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Focus nodes
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Password visibility toggles
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Form validation
  bool _isFormValid = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Add listeners to check when form is valid
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  // Validate password form
  void _validateForm() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    bool isValid = false;
    String error = '';
    bool hasError = false;

    // Check if passwords are entered
    if (password.isNotEmpty && confirmPassword.isNotEmpty) {
      // Check if passwords match
      if (password != confirmPassword) {
        hasError = true;
        error = 'Passwords do not match';
      }
      // Check password strength (at least 8 characters)
      else if (password.length < 8) {
        hasError = true;
        error = 'Password must be at least 8 characters';
      } else {
        isValid = true;
      }
    }

    setState(() {
      _isFormValid = isValid;
      _hasError = hasError;
      _errorMessage = error;
    });
  }

  // Reset password
  void _resetPassword() {
    showPasswordSuccessDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen dimensions to make sizes responsive
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenHeight * 0.018;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black54, size: screenHeight * 0.025),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
            'Back',
            style: TextStyle(
                color: Colors.black54,
                fontSize: baseFontSize,
                fontWeight: FontWeight.normal
            )
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.025),
              Text(
                'Create New Password',
                style: TextStyle(
                  fontSize: baseFontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Your identity has been verified. Please set your new password.',
                style: TextStyle(
                  fontSize: baseFontSize * 0.875,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenHeight * 0.035),

              // New Password Field
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: baseFontSize * 0.9),
                  labelStyle: TextStyle(color: Colors.black54, fontSize: baseFontSize),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                  ),
                  errorBorder: _hasError ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ) : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: screenHeight * 0.025,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onEditingComplete: () => _confirmPasswordFocusNode.requestFocus(),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: baseFontSize * 0.9),
                  labelStyle: TextStyle(color: Colors.black54, fontSize: baseFontSize),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                  ),
                  errorBorder: _hasError ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ) : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: screenHeight * 0.025,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              if (_hasError)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: baseFontSize * 0.875
                    ),
                  ),
                ),

              SizedBox(height: screenHeight * 0.03),

              // Password requirements
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: baseFontSize * 0.875,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    _passwordRequirementItem(
                      'At least 8 characters',
                      _passwordController.text.length >= 8,
                      baseFontSize,
                    ),
                    _passwordRequirementItem(
                      'Passwords match',
                      _passwordController.text.isNotEmpty &&
                          _passwordController.text == _confirmPasswordController.text,
                      baseFontSize,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _resetPassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    textStyle: TextStyle(
                      fontSize: baseFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reset Password'),
                ),
              ),

              const Spacer(),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Powered By ',
                        style: TextStyle(
                          fontSize: baseFontSize * 0.875,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Sotupub',
                        style: TextStyle(
                          fontSize: baseFontSize * 0.875,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF7240),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create password requirement items
  Widget _passwordRequirementItem(String text, bool isMet, double baseFontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green.shade800 : Colors.grey,
            size: baseFontSize * 1.2,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: baseFontSize * 0.8,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
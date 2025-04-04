import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/Login_screens/reset_password.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  // Controllers for each OTP digit - changed to 6
  final List<TextEditingController> _controllers = List.generate(
      6,
          (index) => TextEditingController()
  );

  // Focus nodes for each OTP field - changed to 6
  final List<FocusNode> _focusNodes = List.generate(
      6,
          (index) => FocusNode()
  );

  // Track if OTP is filled
  bool _isOtpFilled = false;

  // Error state
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Add listeners to check when all fields are filled
    for (var controller in _controllers) {
      controller.addListener(_checkOtpFilled);
    }
  }

  // Check if all OTP fields are filled
  void _checkOtpFilled() {
    bool filled = true;
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        filled = false;
        break;
      }
    }

    if (filled != _isOtpFilled) {
      setState(() {
        _isOtpFilled = filled;
        if (_hasError) _hasError = false;
      });
    }
  }

  // Verify OTP
  void _verifyOtp() {
    // Get the full OTP
    final otp = _controllers.map((c) => c.text).join();

    // Replace with your actual OTP verification logic
    // Updated for 6-digit OTP - "123456" is the correct OTP
    if (otp == "123456") {
      // Navigate to reset password page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: widget.email),
        ),
      );
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Incorrect OTP. Please try again.';
      });
    }
  }

  // Resend OTP
  void _resendOtp() {
    // Implement resend OTP logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP resent to ${widget.email}',
          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018))),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen dimensions to make sizes responsive
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenHeight * 0.018;
    // Adjust field size to accommodate 6 digits
    final otpFieldSize = screenWidth * 0.12;

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
                'Enter OTP',
                style: TextStyle(
                  fontSize: baseFontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'We have sent a code to your registered email address.',
                style: TextStyle(
                  fontSize: baseFontSize * 0.875,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenHeight * 0.035),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                      (index) => SizedBox(
                    width: otpFieldSize,
                    height: otpFieldSize,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: baseFontSize * 1.5,
                        // Ensure text is centered horizontally
                        fontWeight: FontWeight.w500,
                      ),
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _controllers[index].text.isNotEmpty
                            ? Colors.green.withOpacity(0.1)
                            : Colors.white,
                        // Center the content by adjusting content padding
                        contentPadding: EdgeInsets.zero,
                        // Ensure the border is symmetric
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Colors.green.shade800,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
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

              SizedBox(height: screenHeight * 0.01),

              Center(
                child: TextButton(
                  onPressed: _resendOtp,
                  child: Text(
                    'Didn\'t receive the code? Resend',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: baseFontSize * 0.875,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOtpFilled ? _verifyOtp : null,
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
                  child: const Text('Verify OTP'),
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

  @override
  void dispose() {
    // Updated to dispose 6 controllers and focus nodes
    for (var i = 0; i < 6; i++) {
      _controllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }
}
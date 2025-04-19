import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import '../../auth/login_auth.dart';
import '../auth/auth_service.dart';
import '../dashboard.dart';
import 'forgot_password.dart';
import 'package:in_out/localization/app_localizations.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // New variables to handle error messages
  bool _hasError = false;
  String _errorMessage = '';

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = "Veuillez entrer votre email et mot de passe.";
      });
      return;
    }

    setState(() => _isLoading = true);

    // Call the AuthService login method
    final result = await AuthService.login(email, password);

    setState(() => _isLoading = false);

    if (result["success"]) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
      // Show success message
      _showSuccess("Connexion réussie !");

      // Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = result["message"];
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _toggleRememberMe() {
    setState(() {
      _rememberMe = !_rememberMe;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenHeight * 0.018;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.85,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.06),
                        SizedBox(
                          height: screenHeight * 0.12,
                          child: SvgPicture.asset(
                            'images/logo.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome ',
                              style: TextStyle(
                                fontSize: baseFontSize * 1.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '👋',
                              style: TextStyle(fontSize: baseFontSize * 1.5),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: baseFontSize * 0.875,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              TextField(
                                controller: _emailController,
                                style: TextStyle(fontSize: baseFontSize),
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(fontSize: baseFontSize),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Iconify(MaterialSymbols.alternate_email,
                                        color: Colors.green.shade800),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _hasError ? Colors.red : Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _hasError ? Colors.red : Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _hasError ? Colors.red : Colors.green.shade800),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (_) {
                                  // Clear error when user starts typing
                                  if (_hasError) {
                                    setState(() {
                                      _hasError = false;
                                      _errorMessage = '';
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: baseFontSize * 0.875,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              TextField(
                                controller: _passwordController,
                                style: TextStyle(fontSize: baseFontSize),
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(fontSize: baseFontSize),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Iconify(MaterialSymbols.lock,
                                        color: Colors.green.shade800),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Iconify(
                                      _obscureText
                                          ? MaterialSymbols.visibility
                                          : MaterialSymbols.visibility_off,
                                      color: Colors.green.shade800,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _hasError ? Colors.red : Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _hasError ? Colors.red : Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _hasError ? Colors.red : Colors.green.shade800),
                                  ),
                                ),
                                onChanged: (_) {
                                  // Clear error when user starts typing
                                  if (_hasError) {
                                    setState(() {
                                      _hasError = false;
                                      _errorMessage = '';
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                children: [
                                  // Make the entire row section for "Remember Me" clickable
                                  GestureDetector(
                                    onTap: _toggleRememberMe,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          activeColor: Colors.green.shade800,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                        Text(
                                          'Remember Me',
                                          style: TextStyle(
                                            fontSize: baseFontSize * 0.875,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ForgotPasswordPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: baseFontSize * 0.875,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.03),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: screenHeight * 0.06,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: baseFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Error message display
                              if (_hasError)
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                    horizontal: screenWidth * 0.02,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: baseFontSize * 0.9,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
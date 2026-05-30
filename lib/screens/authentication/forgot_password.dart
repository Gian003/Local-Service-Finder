import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/services/api_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  bool _isEmailValid(String value) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(value);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postRequest(
        'user-auth/forgot-password',
        {'email': _emailController.text.trim()},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent. Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send reset email. Please try again.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Center(
                widthFactor: 3.0,
                heightFactor: 1.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),

                    const SizedBox(height: 50),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Enter your email address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(10),
                            right: Radius.circular(10),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!_isEmailValid(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.horizontal(
                            left: Radius.circular(10),
                            right: Radius.circular(10),
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Send',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    const SizedBox(height: 50),

                    Text(
                      'or',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[500],
                      ),
                    ),

                    const SizedBox(height: 50),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: FaIcon(
                            FontAwesomeIcons.facebook,
                            color: Colors.blueAccent,
                            size: 35,
                          ),
                        ),

                        const SizedBox(width: 10),

                        IconButton(
                          onPressed: () {},
                          icon: FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.black,
                            size: 35,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        const SizedBox(width: 5),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/register',
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

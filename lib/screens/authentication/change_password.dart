import 'package:flutter/material.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/services/api_service.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String value) {
    return value.length >= 8;
  }

  Future<void> _handleSubmit() async {
    if (!_formkey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.putRequest(
        'user-auth/profile/password',
        {'password': _newPasswordController.text.trim()},
        auth: true,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change password. Please try again.'),
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
              key: _formkey,
              child: Center(
                widthFactor: 3.0,
                heightFactor: 1.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create your new password',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),

                    const SizedBox(height: 50),

                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'Enter New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(15),
                            right: Radius.circular(15),
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        } else if (!_isPasswordValid(value)) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm your new password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(15),
                            right: Radius.circular(15),
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        } else if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    Card(
                      elevation: 1,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.horizontal(
                          left: Radius.circular(15),
                          right: Radius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password Requirements:',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            _newPasswordRequirements(
                              met: _newPasswordController.text.length >= 8,
                              text: 'At least 8 characters long',
                            ),

                            _newPasswordRequirements(
                              met: _newPasswordController.text.contains(
                                RegExp(r'[A-Z]'),
                              ),
                              text: 'At least one uppercase letter',
                            ),

                            _newPasswordRequirements(
                              met: _newPasswordController.text.contains(
                                RegExp(r'[0-9]'),
                              ),
                              text: 'At least one number',
                            ),

                            _newPasswordRequirements(
                              met:
                                  _newPasswordController.text ==
                                      _confirmPasswordController.text &&
                                  _confirmPasswordController.text.isNotEmpty,
                              text: 'Passwords match',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.horizontal(
                            left: Radius.circular(15),
                            right: Radius.circular(15),
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Submit',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _newPasswordRequirements({required bool met, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle,
            size: 16,
            color: met ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: met ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // For testing purposes, this function is commented out.

  // Future<void> _changePassword() async {
  //   if (!_formkey.currentState!.validate()) return;

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //     final response = await authProvider.changePassword(
  //       currentPassword: _currentPasswordController.text,
  //       newPassword: _newPasswordController.text,
  //     );

  //     if (response['success'] == true) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Password changed successfully'),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //         Navigator.pop(context);
  //       }
  //     } else {
  //       throw Exception(response['message'] ?? 'Password change failed');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to change password: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          style: const TextStyle(fontFamily: 'Montserrat'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Current Password
                      _buildPasswordField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Current password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        obscureText: _obscureCurrentPassword,
                        onToggleVisibility: () => setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        }),
                      ),
                      const SizedBox(height: 20),

                      // New Password
                      _buildPasswordField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Password must contain at least one uppercase letter';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Password must contain at least one number';
                          }
                          return null;
                        },
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () => setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        }),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      _buildPasswordField(
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () => setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Requirements
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRequirement(
                        met: _newPasswordController.text.length >= 8,
                        text: 'At least 8 characters',
                      ),
                      _buildRequirement(
                        met: _newPasswordController.text.contains(
                          RegExp(r'[A-Z]'),
                        ),
                        text: 'At least one uppercase letter',
                      ),
                      _buildRequirement(
                        met: _newPasswordController.text.contains(
                          RegExp(r'[0-9]'),
                        ),
                        text: 'At least one number',
                      ),
                      _buildRequirement(
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
              const Spacer(),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // _changePassword();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement({required bool met, required String text}) {
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

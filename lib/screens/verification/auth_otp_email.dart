import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lsffend/global%20variable/colors.dart';

class AuthOtpEmail extends StatefulWidget {
  const AuthOtpEmail({super.key});

  @override
  AuthOtpEmailState createState() => AuthOtpEmailState();
}

class AuthOtpEmailState extends State<AuthOtpEmail> {
  String otpCode = '';
  int _remainingTime = 60;
  bool _canResend = false;
  bool _isLoading = false;
  Timer? _timer;

  String _userEmail = '';
  String _userPassword = '';
  Map<String, dynamic> _userData = {};
  String _maskedContactInfo = '';

  bool _didGetArguments = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didGetArguments) {
      _didGetArguments = true;
      _getUserContactInfo();
    }
  }

  void _getUserContactInfo() {
    final args = ModalRoute.of(context)!.settings.arguments;

    if (args == null) {
      debugPrint('No arguments provided to AuthOtpEmail screen.');
      return;
    }

    try {
      final Map<String, dynamic> dynamicArgs = args as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint('== DEBUG: Arguments received in AuthOtpEmail');
        debugPrint('Type: ${args.runtimeType}');
        debugPrint('Value:$args');
        debugPrint('====================================');

        final Map<String, dynamic> stringArgs = {};
        dynamicArgs.forEach((key, value) {
          stringArgs[key.toString()] = value;
        });

        debugPrint('Converted arguments: $stringArgs');

        // Extracting user data for debugging purposes
      }
    } catch (e) {
      debugPrint('Error parsing arguments: $e');
      //set default values of user datas or show error message
    }

    // Auto-select email if available
    // if (_userEmail.isNotEmpty) {
    //   _selectedMethod = 'email';
    //   _maskedContact = _getMaskedEmail(_userEmail);
    //   _sendVerificationCode();
    // }
  }

  String _getMaskedEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email; // Invalid email format

    final userName = parts[0];
    final domain = [1];

    if (userName.length <= 2) {
      //If the username has a length of two or less
      return email;
    }

    //get the first two characters of the username
    final firstTwo = userName.substring(0, 2);

    //get the rest of the username and replace it with asterisks
    final maskedUserName = firstTwo + '*' * (userName.length - 2);

    return '$firstTwo$maskedUserName@$domain';
  }

  // Sends a verification code to the user's selected contact method (email or phone).
  //
  // This function sets the [_isLoading] state to true, and then sets it back to false once the verification code has been sent or an error has occurred.
  //
  // If the verification code is sent successfully, a snackbar is shown to the user with a message indicating that the verification code has been sent to their selected contact method.
  //
  // If an error occurs while sending the verification code, a snackbar is shown to the user with a message indicating that the verification code could not be sent.
  //
  // This function also starts a countdown from 60 seconds, and sets the [_canResend] state to false during the countdown period.
  Future<void> _sendVerificationCode() async {
    setState(() => _isLoading = true);

    try {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _canResend = false;
        _remainingTime = 30;
      });

      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code sent to $_userEmail!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification code: $e')),
      );
    }
  }

  void _startCountdown() {
    _timer?.cancel();

    setState(() {
      _canResend = false;
      _remainingTime = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  void _verifyCode() async {
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter the 6-digit code')));

      return;
    }

    setState(() => _isLoading = true);

    try {
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // final otpResult = await authProvider.verifyCode(
      //   code: otpCode,
      //   email: _userEmail.isNotEmpty ? _userEmail : null,
      // );

      if (!mounted) return;

      if (otpCode == '123456') {
        // Simulated success for testing
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration successful!')));

        Navigator.pushReplacementNamed(
          context,
          '/home',

          arguments: {'email': _userEmail},
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid Verificaion Code')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resendCode() {
    if (_canResend && !_isLoading) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Resending code...')));
      _sendVerificationCode();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),

            const Text(
              'Verify Code',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Please enter the 6-digit code we just sent to $_userEmail',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 5),

            Text(
              _maskedContactInfo,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Color(0xFF2F5899),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            OtpTextField(
              numberOfFields: 6,
              borderColor: Colors.black,
              cursorColor: Colors.black,
              showFieldAsBox: true,
              fieldHeight: 65,
              fillColor: Colors.white,
              filled: false,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(5),
                right: Radius.circular(5),
              ),
              onCodeChanged: (value) {
                // handle code change
              },
              onSubmit: (String verificationCode) {
                setState(() {
                  otpCode = verificationCode;
                });
                _verifyCode();
              },
            ),

            const SizedBox(height: 30),

            //Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2F5899),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.horizontal(
                            left: Radius.circular(10),
                            right: Radius.circular(10),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 30),

            //Resend Code Section
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Didn\'t recieve the code?',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 5),
                _canResend
                    ? GestureDetector(
                        onTap: () {
                          _resendCode();
                        },
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : Text(
                        'Resend available in 00:${_remainingTime.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
              ],
            ),

            const SizedBox(height: 20),

            //Change Method Section
            if (_userEmail.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    otpCode = '';
                    _timer?.cancel();
                    _canResend = false;
                    _remainingTime = 30;
                  });
                },
                child: Text(
                  'Change Verification Method',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF2F5899),
                  ),
                ),
              ),
          ],

          //Loading state when auto-sending
          // if (_isLoading && _selectedMethod != null) ...[
          //   const SizedBox(height: 20),
          //   const CircularProgressIndicator(),
          //   const SizedBox(height: 10),
          //   const Text(
          //     'Sending Verification code...',
          //     style: TextStyle(
          //       fontFamily: 'Montserrat',
          //       fontSize: 15,
          //       color: Colors.grey,
          //     ),
          //   ),
          // ],
        ),
      ),
    );
  }
}

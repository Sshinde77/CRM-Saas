import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../providers/api_provider.dart';
import '../../services/api_service.dart';
import '../role_home_screen.dart';

class PhoneOtpScreen extends StatefulWidget {
  final String phone;
  final int resendAfter;
  final ApiProvider apiProvider;

  const PhoneOtpScreen({
    super.key,
    required this.phone,
    required this.resendAfter,
    required this.apiProvider,
  });

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _codeController = TextEditingController();
  Timer? _timer;
  late int _secondsRemaining;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.resendAfter;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        _timer?.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showMessage('Enter the 6-digit OTP.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final session = await widget.apiProvider.loginWithPhoneOtp(
        phone: widget.phone,
        code: code,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => RoleHomeScreen.forRole(
            widget.apiProvider.currentUser?.role ?? session.user?.role,
          ),
        ),
        (_) => false,
      );
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) _showMessage('Verification failed: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0 || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final wait = await widget.apiProvider.sendPhoneOtp(phone: widget.phone);
      if (!mounted) return;
      setState(() => _secondsRemaining = wait);
      _startTimer();
      _showMessage('If this number is registered, an OTP has been sent.');
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) _showMessage('Could not resend OTP: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminSidebarBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        title: const Text('Verify mobile number'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Card(
                elevation: 0,
                color: AppColors.surfaceOverlay,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Enter the 6-digit code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If this number is registered, an OTP was sent to +91 ${widget.phone}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _codeController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: '------',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _verify(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verify,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Verify OTP'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _secondsRemaining == 0 && !_isLoading
                            ? _resend
                            : null,
                        child: Text(
                          _secondsRemaining == 0
                              ? 'Resend OTP'
                              : 'Resend OTP in ${_secondsRemaining}s',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

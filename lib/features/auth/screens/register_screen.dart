import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/user_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final FocusNode _phoneFocusNode = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  String _verificationCode = '';
  String? _phoneError;
  String? _codeError;
  String? _generatedCode;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {});
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -15,
      end: 15,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _phoneFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _codeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          // TOP RIGHT GLOW
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: -120 + _animation.value,
                right: -120 + _animation.value * 0.5,
                child: child!,
              );
            },
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFAE00FF).withOpacity(1.0),
                    const Color(0xFF9300D7).withOpacity(0.6),
                    const Color(0xFFAE00FF).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // TOP RIGHT BLUR
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: -80 + _animation.value,
                right: -80 + _animation.value * 0.5,
                child: child!,
              );
            },
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFAE00FF).withOpacity(0.45),
                ),
              ),
            ),
          ),

          // BOTTOM LEFT GLOW
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                bottom: -130 - _animation.value,
                left: -130 - _animation.value * 0.5,
                child: child!,
              );
            },
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFAE00FF).withOpacity(1.0),
                    const Color(0xFF9300D7).withOpacity(0.65),
                    const Color(0xFFAE00FF).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // BOTTOM LEFT BLUR
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                bottom: -90 - _animation.value,
                left: -90 - _animation.value * 0.5,
                child: child!,
              );
            },
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9300D7).withOpacity(0.5),
                ),
              ),
            ),
          ),

          // КОНТЕНТ
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),

                      // ЗАГОЛОВОК
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Регистрация',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ПОЛЯ
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Имя'),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _firstNameController,
                            ),
                            const SizedBox(height: 14),

                            _buildLabel('Фамилия'),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _lastNameController,
                            ),
                            const SizedBox(height: 14),

                            _buildLabel('Номер телефона'),
                            const SizedBox(height: 6),
                            _buildPhoneTextField(),
                            if (_phoneError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _phoneError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () {
                                  final random = Random();
                                  _verificationCode = (1000 + random.nextInt(9000)).toString();
                                  
                                  setState(() {
                                    _generatedCode = _verificationCode;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E1E2E),
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Отправить код',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 14),

                            _buildLabel('Код'),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _codeController,
                              obscureText: true,
                            ),
                            if (_generatedCode != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Тестовый код: $_generatedCode',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (_codeError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _codeError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),

                            // КНОПКА
                            Center(
                              child: SizedBox(
                                width: 250,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _phoneError = null;
                                      _codeError = null;
                                    });

                                    if (_codeController.text.trim() != _verificationCode) {
                                      setState(() {
                                        _codeError = 'Неверный код';
                                      });
                                      return;
                                    }

                                    final phone = '+996${_phoneController.text.trim()}';

                                    try {
                                      await SupabaseService.registerUser(
                                        firstName: _firstNameController.text.trim(),
                                        lastName: _lastNameController.text.trim(),
                                        phone: phone,
                                      );

                                      await UserStorage.savePhone(phone);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Регистрация успешно завершена'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      // Возврат на экран входа после успешной регистрации
                                      Navigator.pop(context);
                                    } catch (e) {
                                      setState(() {
                                        if (e.toString().contains('users_phone_key')) {
                                          _phoneError = 'Этот номер уже зарегистрирован';
                                        } else {
                                          _codeError = 'Ошибка регистрации. Попробуйте позже.';
                                        }
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E1E2E),
                                    elevation: 10,
                                    shadowColor: Colors.black.withOpacity(0.35),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Регистрация',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ВЕРСИЯ
                      const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: Text(
                          'v0.0.1',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.3),
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.65),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF8E8E93),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF9CA3AF),
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneTextField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _phoneFocusNode.hasFocus
              ? const Color(0xFF9CA3AF)
              : const Color(0xFF8E8E93),
          width: _phoneFocusNode.hasFocus ? 1.8 : 1.2,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Text(
            '+996',
            style: TextStyle(
              color: _phoneFocusNode.hasFocus
                  ? Colors.black87
                  : Colors.black38,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                fillColor: Colors.transparent,
                filled: true,
              ),
              onTap: () => setState(() {}),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}
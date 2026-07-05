import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/user_storage.dart';
import '../../passenger/main_tab_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final FocusNode _phoneFocusNode = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
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
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          // TOP RIGHT GLOW — слой 1 (градиент)
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

          // TOP RIGHT GLOW — слой 2 (blur размытие)
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

          // BOTTOM LEFT GLOW — слой 1 (градиент)
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

          // BOTTOM LEFT GLOW — слой 2 (blur размытие)
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

                      Text(
                        'Войти',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 48),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Номер телефона'),
                            const SizedBox(height: 6),
                            _phoneField(),
                            
                            const SizedBox(height: 10),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _phoneError = null;
                                  });

                                  final phone = '+996${_phoneController.text.trim()}';

                                  final exists = await SupabaseService.userExists(phone);

                                  if (!exists) {
                                    setState(() {
                                      _phoneError = 'Этот номер ещё не зарегистрирован';
                                    });
                                    return;
                                  }

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

                            const SizedBox(height: 16),

                            _label('Код'),
                            const SizedBox(height: 6),
                            _textField(_codeController),
                            
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

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _codeError = null;
                                  });

                                  if (_codeController.text.trim() != _verificationCode) {
                                    setState(() {
                                      _codeError = 'Неверный код';
                                    });
                                    return;
                                  }

                                  final phone = '+996${_phoneController.text.trim()}';

                                  await UserStorage.savePhone(phone);

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MainTabScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E1E2E),
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'Войти',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: Text(
                          'v0.0.1',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 14,
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

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.black54,
      ),
    );
  }

  Widget _textField(TextEditingController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black12,
            width: 1.0,
          ),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
          ),
          cursorColor: Colors.black54,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black12,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              '+996',
              style: TextStyle(
                color: _phoneFocusNode.hasFocus
                    ? Colors.black87
                    : Colors.black38,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 1,
              height: 22,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.black12,
            ),
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
                  color: Colors.black87,
                  fontSize: 15,
                ),
                cursorColor: Colors.black54,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
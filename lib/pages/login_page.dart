import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navbar_page.dart';
import '../services/api_services.dart';
import '../utils/session.dart';
import '../widgets/alert.dart';
import '../providers/theme_provider.dart'; // Pastikan path provider benar

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _loading = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final TextEditingController nisnController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    nisnController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final nisn = nisnController.text.trim();
    final password = passwordController.text.trim();

    if (nisn.isEmpty || password.isEmpty) {
      CoolAlert.show(
        context: context,
        isSuccess: false,
        title: 'Oops',
        message: 'NISN dan Password wajib diisi ya!',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await ApiService.loginSiswa(nisn, password);
      if (response['status'] == 'success') {
        await Session.saveLogin(response['data']);
        if (!mounted) return;

        final String namaSiswa = response['data']['name'] ?? 'Siswa';
        final String kelasSiswa = response['data']['class'] ?? '-';

        CoolAlert.show(
          context: context,
          isSuccess: true,
          title: 'LOGIN BERHASIL',
          message: '$namaSiswa\n$kelasSiswa',
          onConfirm: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NavbarPage()),
            );
          },
        );
      } else {
        if (!mounted) return;
         CoolAlert.show(
          context: context,
          isSuccess: false,
          title: 'Gagal Login',
          message: response['message'] ?? 'Periksa kembali NISN dan Password kamu.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      CoolAlert.show(
        context: context,
        isSuccess: false,
        title: 'Error',
        message: 'Tidak dapat terhubung ke server.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.bgWhite, // Adaptif background
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. HEADER SECTION
            Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: SimpleRoundedClipper(),
                  child: Container(
                    height: 380,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: isDark 
                          ? [const Color(0xFFE65100), const Color(0xFFBF360C)] // Lebih Deep saat Dark
                          : [const Color(0xFFFF8E62), const Color(0xFFE65100)],
                      ),
                    ),
                  ),
                ),
                
                Positioned(
                  top: -20,
                  right: -20,
                  child: _buildCircle(180, Colors.white.withOpacity(0.08)),
                ),

                Column(
                  children: [
                    const SizedBox(height: 60),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Image.asset(
                          'lib/images/logo-absen.png',
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.school_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Attendance Management System",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ],
            ),

            // 2. FORM SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildLabel("IDENTIFICATION NUMBER", themeProvider),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: nisnController,
                    hint: "Enter your NISN",
                    icon: Icons.badge_outlined,
                    themeProvider: themeProvider,
                  ),

                  const SizedBox(height: 25),

                  _buildLabel("SECURITY PASSWORD", themeProvider),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: passwordController,
                    hint: "Enter your password",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    themeProvider: themeProvider,
                  ),

                  const SizedBox(height: 40),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ).copyWith(
                        shadowColor: WidgetStateProperty.all(const Color(0xFFE65100).withOpacity(isDark ? 0.2 : 0.4)),
                        elevation: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.pressed) ? 2 : 6),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              "SIGN IN",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // FOOTER
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Trouble logging in?",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: themeProvider.subTextColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Contact School Administrator",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildLabel(String text, ThemeProvider theme) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: theme.subTextColor.withOpacity(0.7),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ThemeProvider themeProvider,
    bool isPassword = false,
  }) {
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFEDEFF3), 
          width: 1
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        style: TextStyle(
          fontFamily: 'Poppins', 
          fontSize: 15, 
          fontWeight: FontWeight.w600,
          color: themeProvider.textColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFE65100).withOpacity(0.7), size: 22),
          hintStyle: TextStyle(color: themeProvider.subTextColor.withOpacity(0.5), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: themeProvider.subTextColor.withOpacity(0.4),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
        ),
      ),
    );
  }
}

class SimpleRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
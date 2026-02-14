import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'navbar_page.dart';
import '../services/api_services.dart';
import '../utils/session.dart';
import '../widgets/alert.dart'; // IMPORT COOLALERT MILIKMU

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _loading = false;

  final TextEditingController nisnController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

        // Panggil CoolAlert dengan parameter onConfirm
        CoolAlert.show(
          context: context,
          isSuccess: true,
          title: 'Login Berhasil!',
          message: 'Selamat datang kembali, ${response['data']['name']}',
          onConfirm: () {
            // Navigasi dilakukan di sini (setelah tombol diklik)
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
          message:
              response['message'] ?? 'Periksa kembali NISN dan Password kamu.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      CoolAlert.show(
        context: context,
        isSuccess: false,
        title: 'Error',
        message: 'Tidak dapat terhubung ke server. Pastikan internetmu aktif.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B35),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // --- AREA LOGO ---
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Image.asset(
                        'lib/images/logo-absen.png',
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.school,
                                size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // --- CONTAINER PUTIH ---
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 250,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              TextSpan(
                                text: 'Welcome ',
                                style: TextStyle(color: Color(0xFFFF6B35)),
                              ),
                              TextSpan(
                                text: 'Back',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Siap untuk melakukan Absensi Hari ini?\nKamu harus Sign in dulu ya!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // NISN
                      const Text(
                        'NISN',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF6B35),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nisnController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Ketik NISN'),
                      ),
                      const SizedBox(height: 20),

                      // PASSWORD
                      const Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF6B35),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: _inputDecoration('Ketik Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // BUTTON LOGIN
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E62)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFFB399)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFF6B35)),
      ),
    );
  }
}

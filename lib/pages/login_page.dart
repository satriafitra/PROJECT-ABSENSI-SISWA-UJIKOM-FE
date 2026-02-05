import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart'; // 🔥 Import ini
import 'navbar_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;

  // ================= CONTROLLER =================
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ================= FUNGSI LOGIN DENGAN SWEET ALERT =================
  void _login() {
    final nisn = nisnController.text.trim();
    final password = passwordController.text.trim();

    if (nisn == '08622113' && password == '123') {
      // ✅ ALERT BERHASIL
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Login Berhasil!',
        text: 'Selamat datang kembali di Aplikasi Absensi',
        confirmBtnText: 'Masuk',
        confirmBtnColor: const Color(0xFFFF6B35),
        onConfirmBtnTap: () {
          Navigator.pop(context); // Tutup alert
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NavbarPage()),
          );
        },
      );
    } else {
      // ❌ ALERT GAGAL
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'NISN atau Password yang kamu masukkan salah.',
        confirmBtnText: 'Coba Lagi',
        confirmBtnColor: const Color(0xFFFF6B35),
        // Animasi tambahan untuk error
        animType: QuickAlertAnimType.scale,
      );
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
                // --- AREA LOGO (Header) ---
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
                            const Icon(Icons.school, size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // --- CONTAINER PUTIH ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
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
                      // Judul
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

                      // Input NISN
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
                        style: const TextStyle(fontFamily: 'Poppins'),
                        decoration: _inputDecoration('Ketik NISN, Contoh 0820089'),
                      ),
                      const SizedBox(height: 20),

                      // Input Password
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
                        style: const TextStyle(fontFamily: 'Poppins'),
                        decoration: _inputDecoration('Ketik Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Tombol Log In
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E62)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
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
                      const SizedBox(height: 20),
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

  // Refactor decoration agar kode lebih bersih
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
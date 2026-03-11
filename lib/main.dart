import 'package:absensi_app/pages/home_absensi.dart';
import 'package:absensi_app/pages/riwayat_absensi.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/navbar_page.dart';
import 'package:provider/provider.dart'; // Import Provider sudah benar
import 'providers/theme_provider.dart'; // Pastikan path file ini sesuai
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);

  // Bungkus MyApp dengan ChangeNotifierProvider agar Tema bisa diakses di semua halaman
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Memantau perubahan tema secara real-time
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi SMP',
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: themeProvider.bgWhite,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFE6F47), // orangeMain
          brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
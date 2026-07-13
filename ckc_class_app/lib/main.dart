import 'package:ckc_class_app/provider/nguoi_dung_provider.dart';
import 'package:ckc_class_app/provider/quiz_provider.dart';
import 'package:ckc_class_app/provider/sinh_vien_lop_hoc_phan_provider.dart';
import 'package:ckc_class_app/provider/sinh_vien_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/xac_thuc.dart';
import 'provider/bang_dieu_khien.dart';
import 'screen/dang_nhap.dart';
import 'screen/khung_chinh.dart';
import 'provider/khoa_provider.dart';
import 'provider/bo_mon_provider.dart';
import 'provider/mon_hoc_provider.dart';
import 'provider/lop_provider.dart';
import 'provider/lop_hoc_phan_provider.dart';
import 'provider/giang_vien_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => KhoaProvider()),
        ChangeNotifierProvider(create: (_) => BoMonProvider()),
        ChangeNotifierProvider(create: (_) => MonHocProvider()),
        ChangeNotifierProvider(create: (_) => NguoiDungProvider()),
        ChangeNotifierProvider(create: (_) => LopProvider()),
        ChangeNotifierProvider(create: (_) => LopHocPhanProvider()),
        ChangeNotifierProvider(create: (_) => GiangVienProvider()),
        ChangeNotifierProvider(create: (_) => SinhVienProvider()),
        ChangeNotifierProvider(create: (_) => SinhVienLopHocPhanProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CKC Class',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const MainScaffold();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

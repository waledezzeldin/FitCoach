import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            _routeFromSplash();
          }
        });
      }
    });
  }

  Future<void> _routeFromSplash() async {
    final app = AppStateScope.of(context);
    if (!app.initialized) {
      await app.load();
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, app.resolveLandingRoute());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brand, // solid green background
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Image.asset(
            'assets/branding/logo.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
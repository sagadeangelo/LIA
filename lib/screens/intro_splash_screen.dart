import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class IntroSplashScreen extends StatefulWidget {
  const IntroSplashScreen({super.key});

  @override
  State<IntroSplashScreen> createState() => _IntroSplashScreenState();
}

class _IntroSplashScreenState extends State<IntroSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Timer _autoRedirectTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    _playStartupSound();

    _autoRedirectTimer = Timer(const Duration(seconds: 5), _navegar);
  }

  Future<void> _playStartupSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/tap_confirm.mp3'));
    } catch (e) {
      debugPrint('Error reproduciendo sonido: $e');
    }
  }

  void _navegar() {
    if (!mounted) return;
    _confettiController.stop();
    Navigator.pushReplacementNamed(context, '/bienvenida');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    _autoRedirectTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🎇 Confetti mágico
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 6,
              maxBlastForce: 10,
              minBlastForce: 5,
              shouldLoop: false,
              colors: const [
                Colors.cyanAccent,
                Colors.blueAccent,
                Colors.white70,
              ],
            ),
          ),

          // 🎬 Logo animado + mensaje
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo_lia',
                child: Lottie.asset(
                  'assets/animations/logo_lia.json',
                  width: screenWidth * 0.8,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cargando tu mundo...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _navegar,
                icon: const Icon(Icons.fast_forward),
                label: const Text('Saltar introducción'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan[700],
                ),
              ),
            ],
          ),

          // 🌀 Logo pequeño arriba (opcional)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 100,
              child: Hero(
                tag: 'logo_lia',
                child: Lottie.asset(
                  'assets/animations/logo_lia.json',
                  width: screenWidth * 0.4,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

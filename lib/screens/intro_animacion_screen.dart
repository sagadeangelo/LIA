import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';

class IntroAnimacionScreen extends StatefulWidget {
  const IntroAnimacionScreen({super.key});

  @override
  State<IntroAnimacionScreen> createState() => _IntroAnimacionScreenState();
}

class _IntroAnimacionScreenState extends State<IntroAnimacionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/bienvenida');
      }
    });
  }

  void _playSonidoImpacto() {
    _audioPlayer.play(AssetSource('sounds/tap_confirm.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LOGO COMPLETO (NO VISIBLE PARA EVITAR REAPARICIÓN INSTANTÁNEA)
          // El logo será parte de la pantalla /bienvenida

          // LIBRO ENTRANDO
          Align(
            alignment: Alignment.bottomLeft,
            child: Image.asset(
              'assets/images/libro_icono.png',
              width: 160,
            )
                .animate()
                .move(
                  begin: const Offset(-250, 300),
                  end: const Offset(0, 0),
                  duration: 1800.ms,
                  curve: Curves.easeOutBack,
                )
                .rotate(begin: -0.5, end: 0.0, duration: 1800.ms)
                .fadeIn(duration: 400.ms)
                .then(delay: 2000.ms)
                .fadeOut(duration: 600.ms)
                .callback(callback: (_) => _playSonidoImpacto()),
          )
        ],
      ),
    );
  }
}

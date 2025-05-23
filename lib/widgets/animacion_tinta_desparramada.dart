import 'package:flutter/material.dart';

class AnimacionTintaDesparramada extends StatefulWidget {
  final String imagePath;
  const AnimacionTintaDesparramada({required this.imagePath});

  @override
  _AnimacionTintaDesparramadaState createState() => _AnimacionTintaDesparramadaState();
}

class _AnimacionTintaDesparramadaState extends State<AnimacionTintaDesparramada>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCirc,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return RadialGradient(
              center: Alignment.center,
              radius: _animation.value,
              colors: [Colors.white, Colors.transparent],
              stops: [0.0, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Image.asset(widget.imagePath, fit: BoxFit.cover),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

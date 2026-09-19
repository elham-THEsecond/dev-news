import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

/// 1. Configuration Model
class ParticleSphereConfig {
  final int particleCount;
  final double sphereRadius;
  final double baseParticleSize;
  final double glowOpacity;
  final double rotationSpeedX;
  final double rotationSpeedY;
  final double deformationStrength;
  final double deformationFrequency;
  final double noiseSpeed;
  final Color color;
  final double perspectiveFocalLength;

  ParticleSphereConfig({
    required this.particleCount,
    required this.sphereRadius,
    required this.baseParticleSize,
    required this.glowOpacity,
    required this.rotationSpeedX,
    required this.rotationSpeedY,
    required this.deformationStrength,
    required this.deformationFrequency,
    required this.noiseSpeed,
    required this.color,
    required this.perspectiveFocalLength,
  });

  factory ParticleSphereConfig.fromJson(Map<String, dynamic> json) {
    String hexColor = json['colorHex'] ?? '#00E5FF';
    hexColor = hexColor.replaceAll('#', '0xFF');

    return ParticleSphereConfig(
      particleCount: (json['particleCount'] ?? 3000).toInt(),
      sphereRadius: (json['sphereRadius'] ?? 120.0).toDouble(),
      baseParticleSize: (json['baseParticleSize'] ?? 2.0).toDouble(),
      glowOpacity: (json['glowOpacity'] ?? 0.6).toDouble(),
      rotationSpeedX: (json['rotationSpeedX'] ?? 0.2).toDouble(),
      rotationSpeedY: (json['rotationSpeedY'] ?? 0.5).toDouble(),
      deformationStrength: (json['deformationStrength'] ?? 15.0).toDouble(),
      deformationFrequency: (json['deformationFrequency'] ?? 5.0).toDouble(),
      noiseSpeed: (json['noiseSpeed'] ?? 1.5).toDouble(),
      color: Color(int.parse(hexColor)),
      perspectiveFocalLength: (json['perspectiveFocalLength'] ?? 300.0)
          .toDouble(),
    );
  }
}

/// 2. Simple 3D Vector for internal math
class _Vector3 {
  final double x, y, z;
  _Vector3(this.x, this.y, this.z);
}

/// 3. Reusable Widget
class ParticleSphere extends StatefulWidget {
  final String configPath;
  final double width;
  final double height;

  const ParticleSphere({
    super.key,
    this.configPath = 'assets/particle_sphere.json',
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  State<ParticleSphere> createState() => _ParticleSphereState();
}

class _ParticleSphereState extends State<ParticleSphere>
    with SingleTickerProviderStateMixin {
  ParticleSphereConfig? _config;
  late AnimationController _controller;
  final List<_Vector3> _baseParticles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final String jsonString = await rootBundle.loadString(widget.configPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      setState(() {
        _config = ParticleSphereConfig.fromJson(jsonData);
        _generateFibonacciSphere(_config!.particleCount);
      });
    } catch (e) {
      debugPrint("Error loading particle sphere config: $e");
    }
  }

  /// Generates evenly distributed points on a sphere
  void _generateFibonacciSphere(int count) {
    _baseParticles.clear();
    final double phi = (1 + sqrt(5)) / 2;
    for (int i = 0; i < count; i++) {
      double y = 1 - (i / (count - 1)) * 2; // y goes from 1 to -1
      double radius = sqrt(1 - y * y);
      double theta = 2 * pi * i / phi;
      double x = cos(theta) * radius;
      double z = sin(theta) * radius;
      _baseParticles.add(_Vector3(x, y, z));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_config == null || _baseParticles.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.cyan),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticleSpherePainter(
              config: _config!,
              baseParticles: _baseParticles,
              time: _controller.value * 2 * pi, // 0 to 2pi
            ),
          );
        },
      ),
    );
  }
}

/// 4. High-Performance Particle Painter
class _ParticleSpherePainter extends CustomPainter {
  final ParticleSphereConfig config;
  final List<_Vector3> baseParticles;
  final double time;

  _ParticleSpherePainter({
    required this.config,
    required this.baseParticles,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw subtle background glow
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [config.color.withValues(alpha: 0.15), Colors.transparent],
            stops: const [0.0, 0.8],
          ).createShader(
            Rect.fromCircle(center: center, radius: config.sphereRadius * 1.5),
          );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // Calculate rotation angles
    final double rotX = time * config.rotationSpeedX;
    final double rotY = time * config.rotationSpeedY;
    final double noiseTime = time * config.noiseSpeed;

    // We bucket particles into 5 depth layers to draw them in batches via drawRawPoints.
    // This provides massive performance gains over drawing individual circles.
    final int numLayers = 5;
    List<List<double>> layers = List.generate(numLayers, (_) => []);

    for (var p in baseParticles) {
      // 1. Calculate organic deformation (pseudo-3D noise via sine waves)
      double noise =
          sin(p.x * config.deformationFrequency + noiseTime) *
          cos(p.y * config.deformationFrequency + noiseTime) *
          sin(p.z * config.deformationFrequency + noiseTime);

      double r = config.sphereRadius + (noise * config.deformationStrength);

      // Scale base points by the new deformed radius
      double x0 = p.x * r;
      double y0 = p.y * r;
      double z0 = p.z * r;

      // 2. Rotate Y
      double x1 = x0 * cos(rotY) - z0 * sin(rotY);
      double z1 = x0 * sin(rotY) + z0 * cos(rotY);
      double y1 = y0;

      // 3. Rotate X
      double y2 = y1 * cos(rotX) - z1 * sin(rotX);
      double z2 = y1 * sin(rotX) + z1 * cos(rotX);
      double x2 = x1;

      // 4. Perspective Projection
      double scale =
          config.perspectiveFocalLength / (config.perspectiveFocalLength - z2);
      double screenX = center.dx + x2 * scale;
      double screenY = center.dy + y2 * scale;

      // 5. Depth Sorting / Bucketing
      // Normalize Z from approx [-radius, radius] to [0.0, 1.0] (1.0 is closest to camera)
      double zNorm = (z2 + config.sphereRadius) / (config.sphereRadius * 2);
      zNorm = zNorm.clamp(0.0, 1.0);

      int layerIndex = (zNorm * (numLayers - 1)).floor();

      layers[layerIndex].add(screenX);
      layers[layerIndex].add(screenY);
    }

    // 6. Draw layers (back to front)
    for (int i = 0; i < numLayers; i++) {
      if (layers[i].isEmpty) continue;

      // Closer layers are larger and more opaque
      double layerWeight = (i + 1) / numLayers;

      final paint = Paint()
        ..color = config.color.withValues(
          alpha: config.glowOpacity * layerWeight,
        )
        ..strokeWidth = config.baseParticleSize * layerWeight
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode
            .screen; // Creates a premium glowing effect where particles overlap

      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.fromList(layers[i]),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleSpherePainter oldDelegate) => true;
}

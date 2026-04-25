// lib/features/focus/presentation/widgets/fluid_engine.dart
// ✅ محرك السوائل المتقدم - مستوحى من oil_simulation.dart

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// محرك الفيزياء
// ═══════════════════════════════════════════════════════════════════

class FluidEngine {
  final List<FluidParticle> particles = [];
  final List<OilPool> pools = [];
  final math.Random _random = math.Random();

  double screenWidth = 400;
  double screenHeight = 800;

  // ثوابت الفيزياء (قابلة للتعديل)
  double gravity = 400.0; // أبطأ للهدوء
  double viscosity = 0.92; // لزوجة عالية
  double cohesion = 0.6;
  double adhesion = 0.7;
  double surfaceTension = 0.5;
  double dampening = 0.96;
  double restitution = 0.08; // ارتداد منخفض

  // إنتاج القطرات
  double dropInterval = 0.12; // أبطأ
  double dropSpawnY = 60.0;
  double _timeSinceLastDrop = 0.0;

  // حدود الجزيئات
  int maxParticles = 500; // أقل للأداء
  double particleRadius = 5.0;

  // اللون (قابل للتغيير)
  Color primaryColor = const Color(0xFF6366F1); // بنفسجي هادئ
  Color secondaryColor = const Color(0xFF4F46E5);
  Color highlightColor = const Color(0xFFA5B4FC);

  void updateScreenSize(double width, double height) {
    screenWidth = width;
    screenHeight = height;
  }

  void setColors(Color primary, Color secondary, Color highlight) {
    primaryColor = primary;
    secondaryColor = secondary;
    highlightColor = highlight;
  }

  void update(double deltaTime) {
    _spawnDroplets(deltaTime);
    _updateParticles(deltaTime);
    _handleCollisions();
    _updatePools(deltaTime);
    _stabilizePools();
  }

  void _spawnDroplets(double deltaTime) {
    _timeSinceLastDrop += deltaTime;

    if (_timeSinceLastDrop >= dropInterval && particles.length < maxParticles) {
      _timeSinceLastDrop = 0.0;

      // نقطة الإسقاط في المنتصف مع تنوع بسيط
      final spawnX = screenWidth / 2 + (_random.nextDouble() - 0.5) * 40;

      particles.add(
        FluidParticle(
          x: spawnX,
          y: dropSpawnY,
          radius: particleRadius + _random.nextDouble() * 2,
          vy: 20 + _random.nextDouble() * 30,
        ),
      );
    }
  }

  void _updateParticles(double deltaTime) {
    for (var particle in particles) {
      // تطبيق الجاذبية
      particle.vy += gravity * deltaTime;

      // تطبيق اللزوجة
      particle.vx *= viscosity;
      particle.vy *= viscosity;

      // تحديث الموقع
      particle.x += particle.vx * deltaTime;
      particle.y += particle.vy * deltaTime;

      // حدود الشاشة
      _handleBoundaries(particle);

      // تحديث حالة التجمع
      if (particle.y > screenHeight - 150) {
        particle.isPooling = true;
        particle.poolingTime += deltaTime;
      }
    }
  }

  void _handleBoundaries(FluidParticle particle) {
    // الحدود الجانبية
    if (particle.x < particle.radius) {
      particle.x = particle.radius;
      particle.vx *= -restitution;
    } else if (particle.x > screenWidth - particle.radius) {
      particle.x = screenWidth - particle.radius;
      particle.vx *= -restitution;
    }

    // الحد السفلي
    if (particle.y > screenHeight - particle.radius - 20) {
      particle.y = screenHeight - particle.radius - 20;
      particle.vy *= -restitution;
      particle.isPooling = true;
    }
  }

  void _handleCollisions() {
    // تطبيق التماسك بين الجزيئات
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final dx = p2.x - p1.x;
        final dy = p2.y - p1.y;
        final distance = math.sqrt(dx * dx + dy * dy);
        final minDist = p1.radius + p2.radius;

        if (distance < minDist * 2 && distance > 0) {
          // قوة التماسك
          final force = cohesion * (1 - distance / (minDist * 2));
          final fx = dx / distance * force;
          final fy = dy / distance * force;

          p1.vx += fx * 0.5;
          p1.vy += fy * 0.5;
          p2.vx -= fx * 0.5;
          p2.vy -= fy * 0.5;
        }

        // منع التداخل
        if (distance < minDist && distance > 0) {
          final overlap = minDist - distance;
          final nx = dx / distance;
          final ny = dy / distance;

          p1.x -= nx * overlap * 0.5;
          p1.y -= ny * overlap * 0.5;
          p2.x += nx * overlap * 0.5;
          p2.y += ny * overlap * 0.5;
        }
      }
    }
  }

  void _updatePools(double deltaTime) {
    // تحويل الجزيئات المستقرة لبرك
    final stableParticles = particles
        .where((p) => p.isPooling && p.poolingTime > 1.5 && p.vy.abs() < 20)
        .toList();

    for (var particle in stableParticles) {
      // إضافة للبركة أو إنشاء جديدة
      bool addedToPool = false;
      for (var pool in pools) {
        if ((particle.x - pool.centerX).abs() < pool.width / 2) {
          pool.addMass(1);
          addedToPool = true;
          break;
        }
      }

      if (!addedToPool && pools.length < 5) {
        pools.add(OilPool(centerX: particle.x, baseY: screenHeight - 20));
      }
    }

    // تحديث البرك
    for (var pool in pools) {
      pool.update(deltaTime);
    }
  }

  void _stabilizePools() {
    particles.removeWhere(
      (p) => p.isPooling && p.poolingTime > 2.5 && p.vy.abs() < 15,
    );
  }

  void reset() {
    particles.clear();
    pools.clear();
    _timeSinceLastDrop = 0.0;
  }

  double get fillPercentage {
    double totalMass = pools.fold(0.0, (sum, pool) => sum + pool.mass);
    return (totalMass / 100).clamp(0.0, 1.0);
  }
}

// ═══════════════════════════════════════════════════════════════════
// جسيم السائل
// ═══════════════════════════════════════════════════════════════════

class FluidParticle {
  double x, y;
  double vx, vy;
  double radius;
  bool isPooling;
  double poolingTime;

  FluidParticle({
    required this.x,
    required this.y,
    this.radius = 5.0,
    this.vx = 0.0,
    this.vy = 0.0,
    this.isPooling = false,
    this.poolingTime = 0.0,
  });
}

// ═══════════════════════════════════════════════════════════════════
// بركة السائل
// ═══════════════════════════════════════════════════════════════════

class OilPool {
  double centerX;
  double baseY;
  double mass;
  double width;
  double height;

  OilPool({required this.centerX, required this.baseY, this.mass = 5.0})
    : width = 25.0,
      height = 4.0;

  void addMass(double amount) {
    mass += amount;
    width = math.min(mass * 2.5, 250);
    height = math.min(mass * 0.4, 40);
  }

  void update(double deltaTime) {
    width += deltaTime * 3;
    height = math.max(height - deltaTime, 4);
  }
}

// ═══════════════════════════════════════════════════════════════════
// رسام السائل مع تأثير Metaball
// ═══════════════════════════════════════════════════════════════════

class FluidPainter extends CustomPainter {
  final FluidEngine engine;
  final double fillPercentage;
  final bool showDebug;

  FluidPainter({
    required this.engine,
    required this.fillPercentage,
    this.showDebug = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. رسم البرك
    _drawPools(canvas, size);

    // 2. رسم تأثير Metaball
    _drawMetaballs(canvas, size);

    // 3. رسم الجزيئات بتأثير لامع
    _drawParticles(canvas, size);

    // 4. رسم مؤشر الامتلاء
    _drawFillIndicator(canvas, size);
  }

  void _drawPools(Canvas canvas, Size size) {
    for (var pool in engine.pools) {
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(pool.centerX, pool.baseY),
          pool.width / 2,
          [
            engine.primaryColor.withValues(alpha: 0.9),
            engine.secondaryColor.withValues(alpha: 0.95),
          ],
          [0.0, 1.0],
        )
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(pool.centerX - pool.width / 2, pool.baseY);

      // شكل عضوي للبركة
      path.quadraticBezierTo(
        pool.centerX,
        pool.baseY - pool.height,
        pool.centerX + pool.width / 2,
        pool.baseY,
      );

      path.lineTo(pool.centerX + pool.width / 2, pool.baseY + 3);
      path.lineTo(pool.centerX - pool.width / 2, pool.baseY + 3);
      path.close();

      canvas.drawPath(path, paint);

      // إضاءة
      final highlightPaint = Paint()
        ..color = engine.highlightColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(pool.centerX, pool.baseY - pool.height * 0.6),
          width: pool.width * 0.5,
          height: pool.height * 0.35,
        ),
        highlightPaint,
      );
    }
  }

  void _drawMetaballs(Canvas canvas, Size size) {
    if (engine.particles.isEmpty) return;

    for (var particle in engine.particles) {
      final metaballPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(particle.x, particle.y),
          particle.radius * 3.5,
          [
            engine.primaryColor.withValues(alpha: 0.35),
            engine.primaryColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          [0.0, 0.5, 1.0],
        )
        ..blendMode = BlendMode.screen;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius * 3.5,
        metaballPaint,
      );
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (var particle in engine.particles) {
      // الجسم الأساسي
      final bodyPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(
            particle.x - particle.radius * 0.3,
            particle.y - particle.radius * 0.3,
          ),
          particle.radius * 1.3,
          [
            engine.primaryColor,
            engine.secondaryColor,
            engine.secondaryColor.withValues(alpha: 0.8),
          ],
          [0.0, 0.6, 1.0],
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        bodyPaint,
      );

      // إضاءة لامعة (زجاجية)
      final highlightPaint = Paint()
        ..color = engine.highlightColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(
        Offset(
          particle.x - particle.radius * 0.35,
          particle.y - particle.radius * 0.35,
        ),
        particle.radius * 0.3,
        highlightPaint,
      );

      // إضاءة ثانوية
      final secondaryHighlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          particle.x - particle.radius * 0.25,
          particle.y - particle.radius * 0.25,
        ),
        particle.radius * 0.12,
        secondaryHighlight,
      );
    }
  }

  void _drawFillIndicator(Canvas canvas, Size size) {
    final fillHeight = size.height * fillPercentage;

    // خط مستوى الامتلاء
    final linePaint = Paint()
      ..color = engine.primaryColor.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(30, size.height - fillHeight),
      Offset(size.width - 30, size.height - fillHeight),
      linePaint,
    );

    // علامات النسبة
    final markerPaint = Paint()
      ..color = engine.primaryColor.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (double i = 0.25; i <= 1.0; i += 0.25) {
      final y = size.height - (size.height * i * 0.8);
      canvas.drawLine(Offset(15, y), Offset(22, y), markerPaint);
      canvas.drawLine(
        Offset(size.width - 22, y),
        Offset(size.width - 15, y),
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FluidPainter oldDelegate) => true;
}

//-----------------------------------------------------------------------------

// // lib/features/focus/presentation/widgets/fluid_engine.dart
// // ✅ محرك السوائل المتقدم - مستوحى من oil_simulation.dart

// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';

// // ═══════════════════════════════════════════════════════════════════
// // محرك الفيزياء
// // ═══════════════════════════════════════════════════════════════════

// class FluidEngine {
//   final List<FluidParticle> particles = [];
//   final List<OilPool> pools = [];
//   final math.Random _random = math.Random();

//   double screenWidth = 400;
//   double screenHeight = 800;

//   // ثوابت الفيزياء (قابلة للتعديل)
//   double gravity = 400.0; // أبطأ للهدوء
//   double viscosity = 0.92; // لزوجة عالية
//   double cohesion = 0.6;
//   double adhesion = 0.7;
//   double surfaceTension = 0.5;
//   double dampening = 0.96;
//   double restitution = 0.08; // ارتداد منخفض

//   // إنتاج القطرات
//   double dropInterval = 0.12; // أبطأ
//   double dropSpawnY = 60.0;
//   double _timeSinceLastDrop = 0.0;

//   // حدود الجزيئات
//   int maxParticles = 500; // أقل للأداء
//   double particleRadius = 5.0;

//   // اللون (قابل للتغيير)
//   Color primaryColor = const Color(0xFF6366F1); // بنفسجي هادئ
//   Color secondaryColor = const Color(0xFF4F46E5);
//   Color highlightColor = const Color(0xFFA5B4FC);

//   void updateScreenSize(double width, double height) {
//     screenWidth = width;
//     screenHeight = height;
//   }

//   void setColors(Color primary, Color secondary, Color highlight) {
//     primaryColor = primary;
//     secondaryColor = secondary;
//     highlightColor = highlight;
//   }

//   void update(double deltaTime) {
//     _spawnDroplets(deltaTime);
//     _updateParticles(deltaTime);
//     _handleCollisions();
//     _updatePools(deltaTime);
//     _stabilizePools();
//   }

//   void _spawnDroplets(double deltaTime) {
//     _timeSinceLastDrop += deltaTime;

//     if (_timeSinceLastDrop >= dropInterval && particles.length < maxParticles) {
//       _timeSinceLastDrop = 0.0;

//       // نقطة الإسقاط في المنتصف مع تنوع بسيط
//       final spawnX = screenWidth / 2 + (_random.nextDouble() - 0.5) * 40;

//       particles.add(
//         FluidParticle(
//           x: spawnX,
//           y: dropSpawnY,
//           radius: particleRadius + _random.nextDouble() * 2,
//           vy: 20 + _random.nextDouble() * 30,
//         ),
//       );
//     }
//   }

//   void _updateParticles(double deltaTime) {
//     for (var particle in particles) {
//       // تطبيق الجاذبية
//       particle.vy += gravity * deltaTime;

//       // تطبيق اللزوجة
//       particle.vx *= viscosity;
//       particle.vy *= viscosity;

//       // تحديث الموقع
//       particle.x += particle.vx * deltaTime;
//       particle.y += particle.vy * deltaTime;

//       // حدود الشاشة
//       _handleBoundaries(particle);

//       // تحديث حالة التجمع
//       if (particle.y > screenHeight - 150) {
//         particle.isPooling = true;
//         particle.poolingTime += deltaTime;
//       }
//     }
//   }

//   void _handleBoundaries(FluidParticle particle) {
//     // الحدود الجانبية
//     if (particle.x < particle.radius) {
//       particle.x = particle.radius;
//       particle.vx *= -restitution;
//     } else if (particle.x > screenWidth - particle.radius) {
//       particle.x = screenWidth - particle.radius;
//       particle.vx *= -restitution;
//     }

//     // الحد السفلي
//     if (particle.y > screenHeight - particle.radius - 20) {
//       particle.y = screenHeight - particle.radius - 20;
//       particle.vy *= -restitution;
//       particle.isPooling = true;
//     }
//   }

//   void _handleCollisions() {
//     // تطبيق التماسك بين الجزيئات
//     for (int i = 0; i < particles.length; i++) {
//       for (int j = i + 1; j < particles.length; j++) {
//         final p1 = particles[i];
//         final p2 = particles[j];

//         final dx = p2.x - p1.x;
//         final dy = p2.y - p1.y;
//         final distance = math.sqrt(dx * dx + dy * dy);
//         final minDist = p1.radius + p2.radius;

//         if (distance < minDist * 2 && distance > 0) {
//           // قوة التماسك
//           final force = cohesion * (1 - distance / (minDist * 2));
//           final fx = dx / distance * force;
//           final fy = dy / distance * force;

//           p1.vx += fx * 0.5;
//           p1.vy += fy * 0.5;
//           p2.vx -= fx * 0.5;
//           p2.vy -= fy * 0.5;
//         }

//         // منع التداخل
//         if (distance < minDist && distance > 0) {
//           final overlap = minDist - distance;
//           final nx = dx / distance;
//           final ny = dy / distance;

//           p1.x -= nx * overlap * 0.5;
//           p1.y -= ny * overlap * 0.5;
//           p2.x += nx * overlap * 0.5;
//           p2.y += ny * overlap * 0.5;
//         }
//       }
//     }
//   }

//   void _updatePools(double deltaTime) {
//     // تحويل الجزيئات المستقرة لبرك
//     final stableParticles = particles
//         .where((p) => p.isPooling && p.poolingTime > 1.5 && p.vy.abs() < 20)
//         .toList();

//     for (var particle in stableParticles) {
//       // إضافة للبركة أو إنشاء جديدة
//       bool addedToPool = false;
//       for (var pool in pools) {
//         if ((particle.x - pool.centerX).abs() < pool.width / 2) {
//           pool.addMass(1);
//           addedToPool = true;
//           break;
//         }
//       }

//       if (!addedToPool && pools.length < 5) {
//         pools.add(OilPool(centerX: particle.x, baseY: screenHeight - 20));
//       }
//     }

//     // تحديث البرك
//     for (var pool in pools) {
//       pool.update(deltaTime);
//     }
//   }

//   void _stabilizePools() {
//     particles.removeWhere(
//       (p) => p.isPooling && p.poolingTime > 2.5 && p.vy.abs() < 15,
//     );
//   }

//   void reset() {
//     particles.clear();
//     pools.clear();
//     _timeSinceLastDrop = 0.0;
//   }

//   double get fillPercentage {
//     double totalMass = pools.fold(0.0, (sum, pool) => sum + pool.mass);
//     return (totalMass / 100).clamp(0.0, 1.0);
//   }
// }

// // ═══════════════════════════════════════════════════════════════════
// // جسيم السائل
// // ═══════════════════════════════════════════════════════════════════

// class FluidParticle {
//   double x, y;
//   double vx, vy;
//   double radius;
//   bool isPooling;
//   double poolingTime;

//   FluidParticle({
//     required this.x,
//     required this.y,
//     this.radius = 5.0,
//     this.vx = 0.0,
//     this.vy = 0.0,
//     this.isPooling = false,
//     this.poolingTime = 0.0,
//   });
// }

// // ═══════════════════════════════════════════════════════════════════
// // بركة السائل
// // ═══════════════════════════════════════════════════════════════════

// class OilPool {
//   double centerX;
//   double baseY;
//   double mass;
//   double width;
//   double height;

//   OilPool({required this.centerX, required this.baseY, this.mass = 5.0})
//     : width = 25.0,
//       height = 4.0;

//   void addMass(double amount) {
//     mass += amount;
//     width = math.min(mass * 2.5, 250);
//     height = math.min(mass * 0.4, 40);
//   }

//   void update(double deltaTime) {
//     width += deltaTime * 3;
//     height = math.max(height - deltaTime, 4);
//   }
// }

// // ═══════════════════════════════════════════════════════════════════
// // رسام السائل مع تأثير Metaball
// // ═══════════════════════════════════════════════════════════════════

// class FluidPainter extends CustomPainter {
//   final FluidEngine engine;
//   final double fillPercentage;
//   final bool showDebug;

//   FluidPainter({
//     required this.engine,
//     required this.fillPercentage,
//     this.showDebug = false,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // 1. رسم البرك
//     _drawPools(canvas, size);

//     // 2. رسم تأثير Metaball
//     _drawMetaballs(canvas, size);

//     // 3. رسم الجزيئات بتأثير لامع
//     _drawParticles(canvas, size);

//     // 4. رسم مؤشر الامتلاء
//     _drawFillIndicator(canvas, size);
//   }

//   void _drawPools(Canvas canvas, Size size) {
//     for (var pool in engine.pools) {
//       final paint = Paint()
//         ..shader = ui.Gradient.radial(
//           Offset(pool.centerX, pool.baseY),
//           pool.width / 2,
//           [
//             engine.primaryColor.withValues(alpha: 0.9),
//             engine.secondaryColor.withValues(alpha: 0.95),
//           ],
//           [0.0, 1.0],
//         )
//         ..style = PaintingStyle.fill;

//       final path = Path();
//       path.moveTo(pool.centerX - pool.width / 2, pool.baseY);

//       // شكل عضوي للبركة
//       path.quadraticBezierTo(
//         pool.centerX,
//         pool.baseY - pool.height,
//         pool.centerX + pool.width / 2,
//         pool.baseY,
//       );

//       path.lineTo(pool.centerX + pool.width / 2, pool.baseY + 3);
//       path.lineTo(pool.centerX - pool.width / 2, pool.baseY + 3);
//       path.close();

//       canvas.drawPath(path, paint);

//       // إضاءة
//       final highlightPaint = Paint()
//         ..color = engine.highlightColor.withValues(alpha: 0.3)
//         ..style = PaintingStyle.fill;

//       canvas.drawOval(
//         Rect.fromCenter(
//           center: Offset(pool.centerX, pool.baseY - pool.height * 0.6),
//           width: pool.width * 0.5,
//           height: pool.height * 0.35,
//         ),
//         highlightPaint,
//       );
//     }
//   }

//   void _drawMetaballs(Canvas canvas, Size size) {
//     if (engine.particles.isEmpty) return;

//     for (var particle in engine.particles) {
//       final metaballPaint = Paint()
//         ..shader = ui.Gradient.radial(
//           Offset(particle.x, particle.y),
//           particle.radius * 3.5,
//           [
//             engine.primaryColor.withValues(alpha: 0.35),
//             engine.primaryColor.withValues(alpha: 0.1),
//             Colors.transparent,
//           ],
//           [0.0, 0.5, 1.0],
//         )
//         ..blendMode = BlendMode.screen;

//       canvas.drawCircle(
//         Offset(particle.x, particle.y),
//         particle.radius * 3.5,
//         metaballPaint,
//       );
//     }
//   }

//   void _drawParticles(Canvas canvas, Size size) {
//     for (var particle in engine.particles) {
//       // الجسم الأساسي
//       final bodyPaint = Paint()
//         ..shader = ui.Gradient.radial(
//           Offset(
//             particle.x - particle.radius * 0.3,
//             particle.y - particle.radius * 0.3,
//           ),
//           particle.radius * 1.3,
//           [
//             engine.primaryColor,
//             engine.secondaryColor,
//             engine.secondaryColor.withValues(alpha: 0.8),
//           ],
//           [0.0, 0.6, 1.0],
//         )
//         ..style = PaintingStyle.fill;

//       canvas.drawCircle(
//         Offset(particle.x, particle.y),
//         particle.radius,
//         bodyPaint,
//       );

//       // إضاءة لامعة (زجاجية)
//       final highlightPaint = Paint()
//         ..color = engine.highlightColor.withValues(alpha: 0.6)
//         ..style = PaintingStyle.fill
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

//       canvas.drawCircle(
//         Offset(
//           particle.x - particle.radius * 0.35,
//           particle.y - particle.radius * 0.35,
//         ),
//         particle.radius * 0.3,
//         highlightPaint,
//       );

//       // إضاءة ثانوية
//       final secondaryHighlight = Paint()
//         ..color = Colors.white.withValues(alpha: 0.25)
//         ..style = PaintingStyle.fill;

//       canvas.drawCircle(
//         Offset(
//           particle.x - particle.radius * 0.25,
//           particle.y - particle.radius * 0.25,
//         ),
//         particle.radius * 0.12,
//         secondaryHighlight,
//       );
//     }
//   }

//   void _drawFillIndicator(Canvas canvas, Size size) {
//     final fillHeight = size.height * fillPercentage;

//     // خط مستوى الامتلاء
//     final linePaint = Paint()
//       ..color = engine.primaryColor.withValues(alpha: 0.25)
//       ..strokeWidth = 1.5
//       ..style = PaintingStyle.stroke;

//     canvas.drawLine(
//       Offset(30, size.height - fillHeight),
//       Offset(size.width - 30, size.height - fillHeight),
//       linePaint,
//     );

//     // علامات النسبة
//     final markerPaint = Paint()
//       ..color = engine.primaryColor.withValues(alpha: 0.4)
//       ..strokeWidth = 2
//       ..strokeCap = StrokeCap.round;

//     for (double i = 0.25; i <= 1.0; i += 0.25) {
//       final y = size.height - (size.height * i * 0.8);
//       canvas.drawLine(Offset(15, y), Offset(22, y), markerPaint);
//       canvas.drawLine(
//         Offset(size.width - 22, y),
//         Offset(size.width - 15, y),
//         markerPaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant FluidPainter oldDelegate) => true;
// }

//-----------------------------------------------------------------------------

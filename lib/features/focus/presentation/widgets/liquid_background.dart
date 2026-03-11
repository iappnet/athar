import 'dart:math';
import 'package:athar/features/focus/presentation/cubit/focus_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/focus_cubit.dart';
import 'liquid_physics.dart';

class SharpLiquidBackground extends StatefulWidget {
  const SharpLiquidBackground({super.key});

  @override
  State<SharpLiquidBackground> createState() => _SharpLiquidBackgroundState();
}

class _SharpLiquidBackgroundState extends State<SharpLiquidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<LiquidDrop> drops = [];

  // زدنا العدد قليلاً لملء الفراغ
  final int maxDrops = 7;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // دورة التموج
    );
  }

  void _manageDrops(Size size) {
    drops.removeWhere((d) => d.position.dy > size.height);

    // زدنا احتمالية التوليد (0.02 -> 0.04) لقطرات أكثر تواتراً
    if (drops.length < maxDrops && Random().nextDouble() < 0.04) {
      drops.add(LiquidDrop.spawn(size));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FocusCubit, FocusState>(
      listener: (context, state) {
        if (state is FocusRunning) {
          if (!_controller.isAnimating) _controller.repeat();
        } else {
          _controller.stop();
        }
      },
      builder: (context, state) {
        const int totalSeconds = 25 * 60;
        double fillPercentage = 1.0 - (state.duration / totalSeconds);
        fillPercentage = fillPercentage.clamp(0.0, 1.0);

        if (state is FocusInitial || state is FocusCompleted) {
          drops.clear();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                if (state is FocusRunning) {
                  _manageDrops(size);
                  for (var drop in drops) {
                    drop.update(size, size.height * fillPercentage);
                  }
                }

                return CustomPaint(
                  painter: SharpOilPainter(
                    fillPercentage: fillPercentage,
                    drops: drops,
                    isRunning: state is FocusRunning,
                    time: _controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            );
          },
        );
      },
    );
  }
}

class SharpOilPainter extends CustomPainter {
  final double fillPercentage;
  final List<LiquidDrop> drops;
  final bool isRunning;
  final double time;

  SharpOilPainter({
    required this.fillPercentage,
    required this.drops,
    required this.isRunning,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // --- 1. الجزيرة الديناميكية المتموجة (Wavy Oil Blob) ---
    double islandW = 126.0;
    double islandH = 37.0;
    double islandTop = 11.0;
    double islandBottomY = islandTop + islandH;

    Path islandPath = Path();

    // نبدأ الرسم من الزاوية العلوية اليسرى للجزيرة
    double leftX = (size.width - islandW) / 2;
    double rightX = (size.width + islandW) / 2;

    // القوس العلوي (ثابت - صلب)
    islandPath.moveTo(leftX, islandTop + 20); // نبدأ من انحناءة اليسار
    islandPath.arcToPoint(
      Offset(leftX + 20, islandTop),
      radius: const Radius.circular(20),
    );
    islandPath.lineTo(rightX - 20, islandTop);
    islandPath.arcToPoint(
      Offset(rightX, islandTop + 20),
      radius: const Radius.circular(20),
    );

    // الحافة السفلية المتموجة (الديناميكية)
    // نمشي من اليمين لليسار بخطوط صغيرة ونطبق عليها دالة الموجة
    for (double x = rightX; x >= leftX; x -= 2) {
      double y = islandBottomY;

      if (isRunning) {
        // تموجات الزيت: دمج موجتين بترددات مختلفة
        double wave1 = sin((x / 15) + (time * 2 * pi)) * 2;
        double wave2 = cos((x / 25) - (time * 2 * pi)) * 1.5;

        // "انتفاخ" في الوسط (Belly) لتتجمع فيه القطرات
        // نستخدم دالة Gaussian أو Sine بسيطة مركزة في الوسط
        double distFromCenter = (x - size.width / 2).abs();
        double belly = 0;
        if (distFromCenter < 40) {
          belly =
              cos((distFromCenter / 40) * (pi / 2)) * 6; // انتفاخ بمقدار 6 بكسل
        }

        y += wave1 + wave2 + belly;
      }

      islandPath.lineTo(x, y);
    }

    // إغلاق المسار بالعودة لنقطة البداية (مع انحناءة اليسار السفلية ضمنياً)
    islandPath.close();
    canvas.drawPath(islandPath, paint);

    // --- 2. القطرات ---
    if (isRunning) {
      for (var drop in drops) {
        // أ) مرحلة الاتصال
        if (drop.phase != DropPhase.falling) {
          _drawMetaball(
            canvas,
            paint,
            origin: drop.anchor,
            originRadius: 10.0, // قاعدة أعرض قليلاً
            target: drop.position,
            targetRadius: drop.radius,
          );
          canvas.drawCircle(drop.position, drop.radius, paint);
        }
        // ب) مرحلة السقوط
        else {
          canvas.save();
          canvas.translate(drop.position.dx, drop.position.dy);
          canvas.scale(1.0 / sqrt(drop.stretch), drop.stretch);
          canvas.drawCircle(Offset.zero, drop.radius, paint);
          canvas.restore();
        }
      }
    }

    // --- 3. السائل السفلي ---
    double liquidH = size.height * fillPercentage;
    if (liquidH > 0) {
      Path floor = Path();
      floor.moveTo(0, size.height);
      floor.lineTo(size.width, size.height);
      floor.lineTo(size.width, size.height - liquidH);

      for (double x = size.width; x >= 0; x -= 10) {
        // تموجات متطابقة مع تموجات الجزيرة للتناسق
        double y = size.height - liquidH + sin(x / 50 + time * 5) * 2;
        floor.lineTo(x, y);
      }
      floor.close();
      canvas.drawPath(floor, paint);
    }
  }

  void _drawMetaball(
    Canvas canvas,
    Paint paint, {
    required Offset origin,
    required double originRadius,
    required Offset target,
    required double targetRadius,
  }) {
    double d = (target - origin).distance;
    if (d < originRadius + targetRadius) return;

    double angle = atan2(target.dy - origin.dy, target.dx - origin.dx);
    double v = 0.5;

    double angle1 = angle + pi / 2 + v;
    double angle2 = angle - pi / 2 - v;
    double angle3 = angle - pi / 2;
    double angle4 = angle + pi / 2;

    Offset p1 = origin + Offset(cos(angle1), sin(angle1)) * originRadius;
    Offset p2 = origin + Offset(cos(angle2), sin(angle2)) * originRadius;
    Offset p3 = target + Offset(cos(angle3), sin(angle3)) * targetRadius;
    Offset p4 = target + Offset(cos(angle4), sin(angle4)) * targetRadius;

    Path connector = Path();
    connector.moveTo(p1.dx, p1.dy);
    // تم إصلاح الخطأ هنا: نقطة التحكم هي المنتصف بين النقطتين، وليس عرض الشاشة
    connector.quadraticBezierTo(
      (p1.dx + p3.dx) / 2,
      (p1.dy + p3.dy) / 2,
      p3.dx,
      p3.dy,
    );
    connector.lineTo(p4.dx, p4.dy);
    connector.quadraticBezierTo(
      (p2.dx + p4.dx) / 2,
      (p2.dy + p4.dy) / 2,
      p2.dx,
      p2.dy,
    );
    connector.close();
    canvas.drawPath(connector, paint);
  }

  @override
  bool shouldRepaint(covariant SharpOilPainter oldDelegate) => true;
}

import 'dart:math';
import 'package:flutter/material.dart';

enum DropPhase { accumulating, hanging, falling, splashing }

class LiquidDrop {
  Offset anchor;
  Offset position;
  double radius;
  double velocity;
  DropPhase phase;
  double mass;
  double stretch;

  LiquidDrop({
    required this.anchor,
    required this.position,
    required this.radius,
    required this.velocity,
    required this.phase,
    required this.mass,
    this.stretch = 1.0,
  });

  factory LiquidDrop.spawn(Size screenSize) {
    final random = Random();
    double islandWidth = 100.0;
    // نوزع نقاط الخروج عشوائياً تحت الجزيرة
    double startX =
        (screenSize.width / 2) +
        (random.nextDouble() * islandWidth - islandWidth / 2);
    double islandBottom = 48.0;

    return LiquidDrop(
      anchor: Offset(startX, islandBottom),
      position: Offset(startX, islandBottom),
      radius: 2.0, // نبدأ بحجم محسوس قليلاً
      velocity: 0,
      phase: DropPhase.accumulating,
      // زيادة الكتلة لإنتاج قطرات أكبر
      mass: random.nextDouble() * 3 + 2,
    );
  }

  void update(Size size, double liquidHeight) {
    if (phase == DropPhase.accumulating) {
      // السماح للقطرة بالنمو لحجم أكبر (x4 الكتلة)
      if (radius < (mass * 4)) {
        radius += 0.12; // نمو أسرع قليلاً
        position = Offset(anchor.dx, anchor.dy + radius * 0.4);
      } else {
        phase = DropPhase.hanging;
      }
    } else if (phase == DropPhase.hanging) {
      velocity += 0.1;
      position = Offset(position.dx, position.dy + velocity);

      // نطيل العنق أكثر للقطرات الكبيرة
      double maxNeckLength = radius * 3.5;
      if ((position.dy - anchor.dy) > maxNeckLength) {
        phase = DropPhase.falling;
        velocity = 2.5;
      }
    } else if (phase == DropPhase.falling) {
      velocity += 0.45;
      if (velocity > 18) velocity = 18; // سرعة قصوى أعلى قليلاً للثقل

      position = Offset(position.dx, position.dy + velocity);
      stretch = 1.0 + (velocity * 0.04);
    }
  }
}

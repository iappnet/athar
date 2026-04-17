// lib/features/space/presentation/widgets/sample_data_banner.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 📦 بانر البيانات التجريبية - يظهر للمستخدم الجديد
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class SampleDataBanner extends StatefulWidget {
  final VoidCallback? onDismissed;
  final VoidCallback? onKept;

  const SampleDataBanner({
    super.key,
    this.onDismissed,
    this.onKept,
  });

  @override
  State<SampleDataBanner> createState() => _SampleDataBannerState();
}

class _SampleDataBannerState extends State<SampleDataBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AtharAnimations.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismissSampleData() async {
    setState(() => _isLoading = true);

    try {
      // حذف البيانات التجريبية
      await getIt<SpaceRepository>().dismissSampleData();

      // تحديث قائمة المساحات
      if (mounted) {
        context.read<SpaceCubit>().loadSpaces();
      }

      // إخفاء البانر
      await _hideBanner();

      widget.onDismissed?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حذف البيانات التجريبية'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _keepSampleData() async {
    // المستخدم يريد الاحتفاظ بالبيانات
    // نخفي البانر فقط ولكن لا نغير sampleDataDismissed
    await _hideBanner();
    widget.onKept?.call();
  }

  Future<void> _hideBanner() async {
    await _controller.reverse();
    if (mounted) {
      setState(() => _isVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFF3E0),
                const Color(0xFFFFE0B2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.orange.shade300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // العنوان
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.orange.shade700,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بيانات تجريبية',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        Text(
                          'للتعرف على التطبيق',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // الوصف
              Text(
                'أضفنا بعض البيانات التجريبية لمساعدتك على فهم كيفية استخدام التطبيق. يمكنك حذفها أو الاحتفاظ بها.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.orange.shade800,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 16.h),

              // الأزرار
              Row(
                children: [
                  // زر الحذف
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _dismissSampleData,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: _isLoading
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red.shade700,
                              ),
                            )
                          : Icon(Icons.delete_outline_rounded, size: 18.sp),
                      label: Text(
                        'حذف الكل',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // زر الاحتفاظ
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _keepSampleData,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: Icon(Icons.check_rounded, size: 18.sp),
                      label: Text(
                        'إبقاء وتعديل',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // ملاحظة
              Text(
                '💡 يمكنك حذفها لاحقاً من الإعدادات',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.orange.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🔍 FutureBuilder للتحقق من وجود بيانات تجريبية
// ═══════════════════════════════════════════════════════════════════════════════

class SampleDataBannerChecker extends StatelessWidget {
  final VoidCallback? onDismissed;
  final VoidCallback? onKept;

  const SampleDataBannerChecker({
    super.key,
    this.onDismissed,
    this.onKept,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getIt<SpaceRepository>().hasSampleData(),
      builder: (context, snapshot) {
        // أثناء التحميل أو إذا لا توجد بيانات تجريبية
        if (!snapshot.hasData || snapshot.data != true) {
          return const SizedBox.shrink();
        }

        // عرض البانر
        return SampleDataBanner(
          onDismissed: onDismissed,
          onKept: onKept,
        );
      },
    );
  }
}

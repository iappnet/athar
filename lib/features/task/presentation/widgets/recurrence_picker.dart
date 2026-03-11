import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/features/task/data/models/recurrence_pattern.dart';

class RecurrencePicker extends StatefulWidget {
  final RecurrencePattern? initialPattern;
  final Function(RecurrencePattern?) onChanged;

  const RecurrencePicker({
    super.key,
    this.initialPattern,
    required this.onChanged,
  });

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  bool _isEnabled = false;
  RecurrenceType _type = RecurrenceType.daily;
  int _interval = 1;
  List<int> _selectedWeekDays = [];
  RecurrenceEndType _endType = RecurrenceEndType.never;
  int _occurrences = 10;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialPattern != null) {
      final p = widget.initialPattern!;
      _isEnabled = p.type != RecurrenceType.none;
      _type = p.type;
      _interval = p.interval;
      _selectedWeekDays = p.weekDays;
      _endType = p.endType;
      _occurrences = p.occurrences ?? 10;
      _endDate = p.endDate;
    }
  }

  void _notifyChange() {
    if (!_isEnabled) {
      widget.onChanged(null);
      return;
    }

    final pattern = RecurrencePattern()
      ..type = _type
      ..interval = _interval
      ..weekDays = _selectedWeekDays
      ..endType = _endType
      ..occurrences = _endType == RecurrenceEndType.afterOccurrences
          ? _occurrences
          : null
      ..endDate = _endType == RecurrenceEndType.onDate ? _endDate : null
      ..startDate = DateTime.now();

    widget.onChanged(pattern);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.repeat, color: colorScheme.primary),
        title: Text(
          l10n.recurrence,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _isEnabled
            ? Text(
                _getPatternDescription(),
                style: TextStyle(fontSize: 11.sp, color: colorScheme.primary),
              )
            : null,
        children: [
          Padding(
            padding: AtharSpacing.allMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text(l10n.enableRecurrence),
                  value: _isEnabled,
                  activeThumbColor: colorScheme.primary,
                  onChanged: (val) {
                    setState(() => _isEnabled = val);
                    _notifyChange();
                  },
                ),

                if (_isEnabled) ...[
                  AtharGap.lg,

                  // نوع التكرار
                  _buildTypeSelector(),

                  AtharGap.md,

                  // الفترة الزمنية
                  _buildIntervalSelector(),

                  // اختيار الأيام (للتكرار الأسبوعي)
                  if (_type == RecurrenceType.weekly) ...[
                    AtharGap.md,
                    _buildWeekDaysSelector(),
                  ],

                  AtharGap.lg,
                  const Divider(),
                  AtharGap.sm,

                  // متى ينتهي التكرار
                  _buildEndTypeSelector(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recurrenceTypeLabel,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AtharGap.sm,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildTypeChip(
              RecurrenceType.daily,
              l10n.recurrenceDaily,
              Icons.today,
            ),
            _buildTypeChip(
              RecurrenceType.weekly,
              l10n.recurrenceWeekly,
              Icons.view_week,
            ),
            _buildTypeChip(
              RecurrenceType.monthly,
              l10n.recurrenceMonthly,
              Icons.calendar_month,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(RecurrenceType type, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _type == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
          ),
          AtharGap.hXxs,
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      onSelected: (val) {
        setState(() => _type = type);
        _notifyChange();
      },
    );
  }

  Widget _buildIntervalSelector() {
    final l10n = AppLocalizations.of(context);
    String unit;
    switch (_type) {
      case RecurrenceType.daily:
        unit = l10n.intervalDay;
        break;
      case RecurrenceType.weekly:
        unit = l10n.intervalWeek;
        break;
      case RecurrenceType.monthly:
        unit = l10n.intervalMonth;
        break;
      default:
        unit = l10n.intervalPeriod;
    }

    return Row(
      children: [
        Text(l10n.everyInterval, style: TextStyle(fontSize: 14.sp)),
        AtharGap.hMd,
        SizedBox(
          width: 60.w,
          child: DropdownButtonFormField<int>(
            initialValue: _interval,
            items: List.generate(30, (i) => i + 1)
                .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                .toList(),
            onChanged: (val) {
              setState(() => _interval = val!);
              _notifyChange();
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              border: OutlineInputBorder(borderRadius: AtharRadii.radiusSm),
            ),
          ),
        ),
        AtharGap.hMd,
        Text(unit, style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }

  Widget _buildWeekDaysSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final days = [
      (1, l10n.monday),
      (2, l10n.tuesday),
      (3, l10n.wednesday),
      (4, l10n.thursday),
      (5, l10n.friday),
      (6, l10n.saturday),
      (7, l10n.sunday),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recurrenceDays,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AtharGap.sm,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: days.map((day) {
            final isSelected = _selectedWeekDays.contains(day.$1);
            return FilterChip(
              label: Text(day.$2),
              selected: isSelected,
              selectedColor: colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: colorScheme.primary,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedWeekDays.add(day.$1);
                  } else {
                    _selectedWeekDays.remove(day.$1);
                  }
                  _selectedWeekDays.sort();
                });
                _notifyChange();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEndTypeSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recurrenceEnds,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AtharGap.sm,

        RadioListTile<RecurrenceEndType>(
          title: Text(l10n.recurrenceNever),
          value: RecurrenceEndType.never,
          groupValue: _endType,
          activeColor: colorScheme.primary,
          onChanged: (val) {
            setState(() => _endType = val!);
            _notifyChange();
          },
        ),

        RadioListTile<RecurrenceEndType>(
          title: Row(
            children: [
              Text(l10n.recurrenceAfter),
              AtharGap.hSm,
              SizedBox(
                width: 60.w,
                child: TextField(
                  enabled: _endType == RecurrenceEndType.afterOccurrences,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: '$_occurrences')
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: '$_occurrences'.length),
                    ),
                  onChanged: (val) {
                    _occurrences = int.tryParse(val) ?? 10;
                    _notifyChange();
                  },
                ),
              ),
              AtharGap.hSm,
              Text(l10n.recurrenceTimes),
            ],
          ),
          value: RecurrenceEndType.afterOccurrences,
          groupValue: _endType,
          activeColor: colorScheme.primary,
          onChanged: (val) {
            setState(() => _endType = val!);
            _notifyChange();
          },
        ),

        RadioListTile<RecurrenceEndType>(
          title: Row(
            children: [
              Text(l10n.recurrenceOn),
              AtharGap.hSm,
              TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _endDate != null
                      ? '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'
                      : l10n.selectDate,
                ),
                onPressed: _endType == RecurrenceEndType.onDate
                    ? _pickEndDate
                    : null,
              ),
            ],
          ),
          value: RecurrenceEndType.onDate,
          groupValue: _endType,
          activeColor: colorScheme.primary,
          onChanged: (val) {
            setState(() => _endType = val!);
            if (_endDate == null) _pickEndDate();
            _notifyChange();
          },
        ),
      ],
    );
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() => _endDate = date);
      _notifyChange();
    }
  }

  String _getPatternDescription() {
    if (!_isEnabled) return '';
    final l10n = AppLocalizations.of(context);

    String desc = '';
    switch (_type) {
      case RecurrenceType.daily:
        desc = _interval == 1 ? l10n.repeatDaily : l10n.everyNDays(_interval);
        break;
      case RecurrenceType.weekly:
        if (_selectedWeekDays.isEmpty) {
          desc = _interval == 1
              ? l10n.repeatWeekly
              : l10n.everyNWeeks(_interval);
        } else {
          final dayNames = _selectedWeekDays
              .map((d) {
                final names = [
                  '',
                  l10n.monday,
                  l10n.tuesday,
                  l10n.wednesday,
                  l10n.thursday,
                  l10n.friday,
                  l10n.saturday,
                  l10n.sunday,
                ];
                return names[d];
              })
              .join(', ');
          desc = l10n.everyDayNames(dayNames);
        }
        break;
      case RecurrenceType.monthly:
        desc = _interval == 1
            ? l10n.repeatMonthly
            : l10n.everyNMonths(_interval);
        break;
      default:
        desc = l10n.repeatCustom;
    }

    switch (_endType) {
      case RecurrenceEndType.afterOccurrences:
        desc += ' ${l10n.nTimesParenthetical(_occurrences)}';
        break;
      case RecurrenceEndType.onDate:
        if (_endDate != null) {
          desc +=
              ' ${l10n.untilDateParenthetical('${_endDate!.year}/${_endDate!.month}/${_endDate!.day}')}';
        }
        break;
      case RecurrenceEndType.never:
        desc += ' ${l10n.foreverParenthetical}';
        break;
    }

    return desc;
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/task/data/models/recurrence_pattern.dart';

// class RecurrencePicker extends StatefulWidget {
//   final RecurrencePattern? initialPattern;
//   final Function(RecurrencePattern?) onChanged;

//   const RecurrencePicker({
//     super.key,
//     this.initialPattern,
//     required this.onChanged,
//   });

//   @override
//   State<RecurrencePicker> createState() => _RecurrencePickerState();
// }

// class _RecurrencePickerState extends State<RecurrencePicker> {
//   bool _isEnabled = false;
//   RecurrenceType _type = RecurrenceType.daily;
//   int _interval = 1;
//   List<int> _selectedWeekDays = [];
//   RecurrenceEndType _endType = RecurrenceEndType.never;
//   int _occurrences = 10;
//   DateTime? _endDate;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialPattern != null) {
//       final p = widget.initialPattern!;
//       _isEnabled = p.type != RecurrenceType.none;
//       _type = p.type;
//       _interval = p.interval;
//       _selectedWeekDays = p.weekDays;
//       _endType = p.endType;
//       _occurrences = p.occurrences ?? 10;
//       _endDate = p.endDate;
//     }
//   }

//   void _notifyChange() {
//     if (!_isEnabled) {
//       widget.onChanged(null);
//       return;
//     }

//     final pattern = RecurrencePattern()
//       ..type = _type
//       ..interval = _interval
//       ..weekDays = _selectedWeekDays
//       ..endType = _endType
//       ..occurrences = _endType == RecurrenceEndType.afterOccurrences
//           ? _occurrences
//           : null
//       ..endDate = _endType == RecurrenceEndType.onDate ? _endDate : null
//       ..startDate = DateTime.now();

//     widget.onChanged(pattern);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.purple.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.purple.shade100),
//       ),
//       child: ExpansionTile(
//         leading: const Icon(Icons.repeat, color: Colors.purple),
//         title: const Text(
//           "التكرار",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: _isEnabled
//             ? Text(
//                 _getPatternDescription(),
//                 style: TextStyle(fontSize: 11.sp, color: Colors.purple),
//               )
//             : null,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(12.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SwitchListTile(
//                   title: const Text("تفعيل التكرار"),
//                   value: _isEnabled,
//                   activeThumbColor: AppColors.primary,
//                   onChanged: (val) {
//                     setState(() => _isEnabled = val);
//                     _notifyChange();
//                   },
//                 ),

//                 if (_isEnabled) ...[
//                   SizedBox(height: 16.h),

//                   // نوع التكرار
//                   _buildTypeSelector(),

//                   SizedBox(height: 12.h),

//                   // الفترة الزمنية
//                   _buildIntervalSelector(),

//                   // اختيار الأيام (للتكرار الأسبوعي)
//                   if (_type == RecurrenceType.weekly) ...[
//                     SizedBox(height: 12.h),
//                     _buildWeekDaysSelector(),
//                   ],

//                   SizedBox(height: 16.h),
//                   const Divider(),
//                   SizedBox(height: 8.h),

//                   // متى ينتهي التكرار
//                   _buildEndTypeSelector(),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTypeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "التكرار:",
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Wrap(
//           spacing: 8.w,
//           runSpacing: 8.h,
//           children: [
//             _buildTypeChip(RecurrenceType.daily, "يومي", Icons.today),
//             _buildTypeChip(RecurrenceType.weekly, "أسبوعي", Icons.view_week),
//             _buildTypeChip(
//               RecurrenceType.monthly,
//               "شهري",
//               Icons.calendar_month,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTypeChip(RecurrenceType type, String label, IconData icon) {
//     final isSelected = _type == type;
//     return ChoiceChip(
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: isSelected ? Colors.white : Colors.purple,
//           ),
//           SizedBox(width: 4.w),
//           Text(label),
//         ],
//       ),
//       selected: isSelected,
//       selectedColor: AppColors.primary,
//       labelStyle: TextStyle(
//         color: isSelected ? Colors.white : Colors.black,
//         fontFamily: 'Tajawal',
//       ),
//       onSelected: (val) {
//         setState(() => _type = type);
//         _notifyChange();
//       },
//     );
//   }

//   Widget _buildIntervalSelector() {
//     String unit = 'يوم';
//     switch (_type) {
//       case RecurrenceType.daily:
//         unit = 'يوم';
//         break;
//       case RecurrenceType.weekly:
//         unit = 'أسبوع';
//         break;
//       case RecurrenceType.monthly:
//         unit = 'شهر';
//         break;
//       default:
//         unit = 'فترة';
//     }

//     return Row(
//       children: [
//         Text("كل", style: TextStyle(fontSize: 14.sp)),
//         SizedBox(width: 12.w),
//         SizedBox(
//           width: 60.w,
//           child: DropdownButtonFormField<int>(
//             initialValue: _interval,
//             items: List.generate(30, (i) => i + 1)
//                 .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
//                 .toList(),
//             onChanged: (val) {
//               setState(() => _interval = val!);
//               _notifyChange();
//             },
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: 12.w),
//         Text(unit, style: TextStyle(fontSize: 14.sp)),
//       ],
//     );
//   }

//   Widget _buildWeekDaysSelector() {
//     const days = [
//       (1, 'الإثنين'),
//       (2, 'الثلاثاء'),
//       (3, 'الأربعاء'),
//       (4, 'الخميس'),
//       (5, 'الجمعة'),
//       (6, 'السبت'),
//       (7, 'الأحد'),
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "الأيام:",
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Wrap(
//           spacing: 8.w,
//           runSpacing: 8.h,
//           children: days.map((day) {
//             final isSelected = _selectedWeekDays.contains(day.$1);
//             return FilterChip(
//               label: Text(day.$2),
//               selected: isSelected,
//               selectedColor: AppColors.primary.withOpacity(0.2),
//               checkmarkColor: AppColors.primary,
//               onSelected: (val) {
//                 setState(() {
//                   if (val) {
//                     _selectedWeekDays.add(day.$1);
//                   } else {
//                     _selectedWeekDays.remove(day.$1);
//                   }
//                   _selectedWeekDays.sort();
//                 });
//                 _notifyChange();
//               },
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildEndTypeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "ينتهي:",
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         SizedBox(height: 8.h),

//         RadioListTile<RecurrenceEndType>(
//           title: const Text("أبداً"),
//           value: RecurrenceEndType.never,
//           groupValue: _endType,
//           activeColor: AppColors.primary,
//           onChanged: (val) {
//             setState(() => _endType = val!);
//             _notifyChange();
//           },
//         ),

//         RadioListTile<RecurrenceEndType>(
//           title: Row(
//             children: [
//               const Text("بعد"),
//               SizedBox(width: 8.w),
//               SizedBox(
//                 width: 60.w,
//                 child: TextField(
//                   enabled: _endType == RecurrenceEndType.afterOccurrences,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(horizontal: 8),
//                     border: OutlineInputBorder(),
//                   ),
//                   controller: TextEditingController(text: '$_occurrences')
//                     ..selection = TextSelection.fromPosition(
//                       TextPosition(offset: '$_occurrences'.length),
//                     ),
//                   onChanged: (val) {
//                     _occurrences = int.tryParse(val) ?? 10;
//                     _notifyChange();
//                   },
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               const Text("مرة"),
//             ],
//           ),
//           value: RecurrenceEndType.afterOccurrences,
//           groupValue: _endType,
//           activeColor: AppColors.primary,
//           onChanged: (val) {
//             setState(() => _endType = val!);
//             _notifyChange();
//           },
//         ),

//         RadioListTile<RecurrenceEndType>(
//           title: Row(
//             children: [
//               const Text("في"),
//               SizedBox(width: 8.w),
//               TextButton.icon(
//                 icon: const Icon(Icons.calendar_today, size: 16),
//                 label: Text(
//                   _endDate != null
//                       ? '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'
//                       : 'اختر تاريخ',
//                 ),
//                 onPressed: _endType == RecurrenceEndType.onDate
//                     ? _pickEndDate
//                     : null,
//               ),
//             ],
//           ),
//           value: RecurrenceEndType.onDate,
//           groupValue: _endType,
//           activeColor: AppColors.primary,
//           onChanged: (val) {
//             setState(() => _endType = val!);
//             if (_endDate == null) _pickEndDate();
//             _notifyChange();
//           },
//         ),
//       ],
//     );
//   }

//   Future<void> _pickEndDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
//     );
//     if (date != null) {
//       setState(() => _endDate = date);
//       _notifyChange();
//     }
//   }

//   String _getPatternDescription() {
//     if (!_isEnabled) return '';

//     String desc = '';
//     switch (_type) {
//       case RecurrenceType.daily:
//         desc = _interval == 1 ? 'يومياً' : 'كل $_interval أيام';
//         break;
//       case RecurrenceType.weekly:
//         if (_selectedWeekDays.isEmpty) {
//           desc = _interval == 1 ? 'أسبوعياً' : 'كل $_interval أسابيع';
//         } else {
//           final dayNames = _selectedWeekDays
//               .map((d) {
//                 const names = [
//                   '',
//                   'الإثنين',
//                   'الثلاثاء',
//                   'الأربعاء',
//                   'الخميس',
//                   'الجمعة',
//                   'السبت',
//                   'الأحد',
//                 ];
//                 return names[d];
//               })
//               .join(', ');
//           desc = 'كل $dayNames';
//         }
//         break;
//       case RecurrenceType.monthly:
//         desc = _interval == 1 ? 'شهرياً' : 'كل $_interval أشهر';
//         break;
//       default:
//         desc = 'مخصص';
//     }

//     switch (_endType) {
//       case RecurrenceEndType.afterOccurrences:
//         desc += ' ($_occurrences مرة)';
//         break;
//       case RecurrenceEndType.onDate:
//         if (_endDate != null) {
//           desc +=
//               ' (حتى ${_endDate!.year}/${_endDate!.month}/${_endDate!.day})';
//         }
//         break;
//       case RecurrenceEndType.never:
//         desc += ' (إلى الأبد)';
//         break;
//     }

//     return desc;
//   }
// }

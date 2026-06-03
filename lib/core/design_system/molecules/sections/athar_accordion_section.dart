import 'package:flutter/material.dart';
import 'package:athar/core/design_system/tokens.dart';

/// Collapsible form section for accordion-style heavy sheets.
///
/// Spec (§9b):
/// - Tinted icon + title in header row, always visible.
/// - Chevron rotates 180° on expand/collapse ([AtharAnimations.normalSlow]).
/// - [summaryValue] shown beside title when collapsed; hidden when expanded.
/// - Required red dot (6×6, [colorScheme.error]) visible while
///   [isRequired] && [summaryValue].isEmpty — clears live as user types.
/// - Body revealed/hidden via [AnimatedAlign](heightFactor) + [ClipRect] so
///   [FormField] descendants remain in the widget tree and [Form.validate()]
///   finds them even when collapsed (Guard #2).
///
/// Access [AtharAccordionSectionState] via [GlobalKey] to call [expand] or
/// [collapse] from parent save logic (Guard #1).
class AtharAccordionSection extends StatefulWidget {
  const AtharAccordionSection({
    super.key,
    required this.icon,
    required this.title,
    required this.summaryValue,
    required this.child,
    this.isRequired = false,
    this.initiallyExpanded = false,
  });

  final IconData icon;
  final String title;

  /// Shown in the header when collapsed.
  /// Empty string = "—" placeholder. Used for the live red-dot check.
  final String summaryValue;

  final Widget child;

  /// Shows a red dot when true and [summaryValue] is empty.
  final bool isRequired;

  /// Whether the section starts expanded (Option A: first section = true).
  final bool initiallyExpanded;

  @override
  AtharAccordionSectionState createState() => AtharAccordionSectionState();
}

class AtharAccordionSectionState extends State<AtharAccordionSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _chevronController;
  late Animation<double> _chevronTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _chevronController = AnimationController(
      duration: AtharAnimations.normalSlow,
      vsync: this,
      value: _isExpanded ? 0.5 : 0.0,
    );
    _chevronTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  bool get isExpanded => _isExpanded;

  void expand() {
    if (!_isExpanded) _toggle();
  }

  void collapse() {
    if (_isExpanded) _toggle();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _chevronController.forward();
    } else {
      _chevronController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEmptyRequired = widget.isRequired && widget.summaryValue.trim().isEmpty;
    final showSummary = !_isExpanded && widget.summaryValue.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ────────────────────────────────────────────────────
        InkWell(
          onTap: _toggle,
          borderRadius: AtharRadii.radiusMd,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
            child: Row(
              children: [
                // Tinted icon container
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: AtharRadii.radiusSm,
                  ),
                  child: Icon(widget.icon, size: 18, color: cs.primary),
                ),
                AtharGap.hMd,
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: cs.onSurface,
                                  fontFamily: AtharTypography.fontFamily,
                                  fontFamilyFallback:
                                      AtharTypography.fontFallback,
                                ),
                          ),
                          if (isEmptyRequired) ...[
                            AtharGap.hXxs,
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: cs.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (showSummary)
                        Text(
                          widget.summaryValue,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontFamily: AtharTypography.fontFamily,
                                fontFamilyFallback: AtharTypography.fontFallback,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Animated chevron
                RotationTransition(
                  turns: _chevronTurns,
                  child: Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        // ── Body: always in the widget tree for Form.validate() ───────────
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: _isExpanded ? 1.0 : 0.0,
            duration: AtharAnimations.normalSlow,
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: widget.child,
            ),
          ),
        ),
        // Divider between sections
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
        AtharGap.xs,
      ],
    );
  }
}

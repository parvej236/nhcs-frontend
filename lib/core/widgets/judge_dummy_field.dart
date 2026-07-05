import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dev/judge_dummy_data.dart';
import '../theme/app_colors.dart';

/// A drop-in replacement for [TextField] that, when focused, shows a small
/// suggestion box beneath it containing a pre-written dummy value for judges /
/// evaluators to autofill with a single tap.
///
/// The box has a small red "for judges testing" label on top and the real
/// dummy value below. Tapping anywhere on the box fills the field. There is no
/// dropdown — it appears purely on focus and disappears on blur.
///
/// Usage mirrors a plain [TextField]; just supply [dummyValue]:
/// ```dart
/// JudgeDummyField(
///   controller: _symptomController,
///   dummyValue: JudgeDummyData.doctor_clinicalWorkspace_textField_symptoms,
///   decoration: const InputDecoration(hintText: 'Type symptom...'),
///   onSubmitted: (v) { ... },
/// )
/// ```
///
/// This is temporary evaluation scaffolding — see [JudgeDummyData].
class JudgeDummyField extends StatefulWidget {
  const JudgeDummyField({
    super.key,
    required this.controller,
    required this.dummyValue,
    this.decoration,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.label = JudgeDummyData.suggestionLabel,
  });

  final TextEditingController controller;

  /// The pre-written value shown in the suggestion box and used to autofill.
  final String dummyValue;

  final InputDecoration? decoration;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  /// Small red header text on the suggestion box.
  final String label;

  @override
  State<JudgeDummyField> createState() => _JudgeDummyFieldState();
}

class _JudgeDummyFieldState extends State<JudgeDummyField> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _overlay = OverlayPortalController();
  // Shared tap-region group so tapping the suggestion box does NOT count as a
  // tap "outside" the field (which would unfocus it and hide the box before the
  // tap registers).
  final Object _tapGroupId = Object();
  late final FocusNode _focusNode;
  double _fieldWidth = 280;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.dummyValue.isNotEmpty) {
      _overlay.show();
    } else {
      _overlay.hide();
    }
  }

  void _fill() {
    final value = widget.dummyValue;
    widget.controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    widget.onChanged?.call(value);
    _overlay.hide();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlay,
      overlayChildBuilder: (context) {
        return CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 6),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _fieldWidth,
              child: TapRegion(
                groupId: _tapGroupId,
                // Fill on pointer-DOWN (not tap/pointer-up): the field's own
                // internal TapRegion unfocuses on the same pointer down, which
                // would hide this overlay before a tap could ever complete.
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _fill(),
                  child: _SuggestionBox(
                    label: widget.label,
                    value: widget.dummyValue,
                    onTap: _fill,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: TapRegion(
        groupId: _tapGroupId,
        child: CompositedTransformTarget(
          link: _link,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
                _fieldWidth = constraints.maxWidth;
              }
              return TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                decoration: widget.decoration,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SuggestionBox extends StatelessWidget {
  const _SuggestionBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.danger.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.science_rounded, size: 12, color: AppColors.danger),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

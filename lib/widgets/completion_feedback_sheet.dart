import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'delivery/voice_input_sheet.dart';

Future<String?> showCompletionFeedbackSheet({
  required BuildContext context,
  required String title,
  required String subjectLabel,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _CompletionFeedbackSheet(title: title, subjectLabel: subjectLabel),
  );
}

class _CompletionFeedbackSheet extends StatefulWidget {
  const _CompletionFeedbackSheet({
    required this.title,
    required this.subjectLabel,
  });

  final String title;
  final String subjectLabel;

  @override
  State<_CompletionFeedbackSheet> createState() =>
      _CompletionFeedbackSheetState();
}

class _CompletionFeedbackSheetState extends State<_CompletionFeedbackSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _recordVoiceNote() async {
    final transcript = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => VoiceInputSheet(
        title: 'Voice feedback',
        instruction:
            'Select a language, then describe the outcome, customer feedback, and next action.',
        hintText:
            'Your feedback will appear here. You can edit it before using.',
        actionLabel: 'Use feedback',
        minimumLength: 1,
        initialText: _controller.text,
      ),
    );
    if (!mounted || transcript == null) return;
    setState(() {
      _controller.text = transcript;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      _errorText = null;
    });
  }

  void _complete() {
    final feedback = _controller.text.trim();
    if (feedback.isEmpty) {
      setState(() => _errorText = 'Add notes or feedback before closing.');
      return;
    }
    Navigator.of(context).pop(feedback);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Add the outcome or customer feedback for ${widget.subjectLabel}.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: 7,
                autofocus: true,
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
                decoration: InputDecoration(
                  labelText: 'Notes / feedback *',
                  hintText: 'Outcome, customer response, next steps...',
                  errorText: _errorText,
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _recordVoiceNote,
                icon: const Icon(Icons.mic_rounded, size: 20),
                label: const Text('Add with voice · Any language'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _complete,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Save & close'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

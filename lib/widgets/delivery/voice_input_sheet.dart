import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../constants/app_colors.dart';

class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({super.key});

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  static const _silenceAutoStopDelay = Duration(seconds: 2);

  final _speech = SpeechToText();
  final _transcriptController = TextEditingController();
  late final AnimationController _pulseController;
  Timer? _silenceAutoStopTimer;

  bool _speechReady = false;
  bool _initializing = true;
  bool _listening = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.92,
      upperBound: 1.08,
    );
    _initializeSpeech();
  }

  @override
  void dispose() {
    _silenceAutoStopTimer?.cancel();
    _pulseController.dispose();
    _transcriptController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    final microphonePermission = await Permission.microphone.request();
    final speechPermission = await Permission.speech.request();
    if (!microphonePermission.isGranted || !speechPermission.isGranted) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error =
            'Microphone and speech recognition permissions are needed for voice entry.';
      });
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        final isListening = status == 'listening';
        setState(() => _listening = isListening);
        if (isListening) {
          _pulseController.repeat(reverse: true);
          _restartSilenceAutoStopTimer();
        } else {
          _silenceAutoStopTimer?.cancel();
          _pulseController.stop();
        }
      },
      onError: (error) {
        if (!mounted) return;
        _silenceAutoStopTimer?.cancel();
        setState(() {
          _listening = false;
          _error = error.errorMsg.isEmpty
              ? 'Speech recognition failed.'
              : error.errorMsg;
        });
        _pulseController.stop();
      },
    );

    if (!mounted) return;
    setState(() {
      _speechReady = available;
      _initializing = false;
      _error = available ? null : 'Speech recognition is unavailable.';
    });
  }

  Future<void> _toggleListening() async {
    if (_initializing || !_speechReady) return;
    if (_listening) {
      _silenceAutoStopTimer?.cancel();
      await _speech.stop();
      return;
    }

    setState(() => _error = null);
    await _speech.listen(
      partialResults: true,
      listenFor: const Duration(minutes: 2),
      pauseFor: _silenceAutoStopDelay,
      onResult: _onSpeechResult,
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (_listening) _restartSilenceAutoStopTimer();
    _transcriptController.text = result.recognizedWords;
    _transcriptController.selection = TextSelection.collapsed(
      offset: _transcriptController.text.length,
    );
    if (mounted) setState(() {});
  }

  void _restartSilenceAutoStopTimer() {
    _silenceAutoStopTimer?.cancel();
    _silenceAutoStopTimer = Timer(_silenceAutoStopDelay, () async {
      if (!mounted || !_listening) return;
      await _speech.stop();
    });
  }

  Future<void> _useTranscript() async {
    _silenceAutoStopTimer?.cancel();
    if (_listening) await _speech.stop();
    final transcript = _transcriptController.text.trim();
    if (!mounted) return;
    if (transcript.length < 8) {
      setState(() => _error = "Didn't catch that, please try again.");
      return;
    }
    Navigator.of(context).pop(transcript);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canUse = _transcriptController.text.trim().length >= 8;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Voice customer details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deliveryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.deliveryGreen.withValues(alpha: 0.18),
              ),
            ),
            child: const Text(
              'Speak like this: "Shop name Sharma Traders, contact person Rajesh, mobile number 9876543210, city Bangalore, pincode 560034".',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.deliveryDashboardHeaderEnd,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: ScaleTransition(
              scale: _pulseController,
              child: IconButton.filled(
                tooltip: _listening ? 'Stop listening' : 'Start voice input',
                onPressed: _initializing || !_speechReady
                    ? null
                    : _toggleListening,
                style: IconButton.styleFrom(
                  backgroundColor: _listening
                      ? AppColors.deliveryRed
                      : AppColors.deliveryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(64, 64),
                  iconSize: 30,
                ),
                icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _initializing
                ? 'Preparing speech recognition...'
                : _listening
                ? 'Listening... stops after 2 seconds of silence.'
                : 'Tap the mic and follow the example above.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.deliveryRed,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _transcriptController,
            minLines: 4,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Your transcript will appear here. You can edit it.',
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _listening
                      ? () {
                          _silenceAutoStopTimer?.cancel();
                          _speech.stop();
                        }
                      : null,
                  child: const Text('Stop'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canUse ? _useTranscript : null,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: const Text('Extract'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

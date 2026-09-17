import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe.dart';

class CookModeDialog extends StatefulWidget {
  final Recipe recipe;

  const CookModeDialog({super.key, required this.recipe});

  static void show(BuildContext context, Recipe recipe) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Cook Mode',
      pageBuilder: (ctx, anim1, anim2) => CookModeDialog(recipe: recipe),
    );
  }

  @override
  State<CookModeDialog> createState() => _CookModeDialogState();
}

class _CookModeDialogState extends State<CookModeDialog> {
  int _currentStepIndex = 0;
  Timer? _activeTimer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _activeTimer?.cancel();
    super.dispose();
  }

  void _startTimer(int minutes) {
    _activeTimer?.cancel();
    setState(() {
      _remainingSeconds = minutes * 60;
      _isTimerRunning = true;
    });

    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerRunning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 Timer Finished! Move to the next step.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe.instructions;
    final totalSteps = steps.length;
    final currentStep = steps.isNotEmpty ? steps[_currentStepIndex] : InstructionStep(step: 1, title: 'Cook', text: 'Prepare meal');
    final isFirst = _currentStepIndex == 0;
    final isLast = _currentStepIndex == totalSteps - 1;
    final progress = totalSteps > 0 ? (_currentStepIndex + 1) / totalSteps : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0E131F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8E9BAE), size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '👨‍🍳 COOK MODE · STEP ${_currentStepIndex + 1} OF $totalSteps',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Color(0xFFFF8C5A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.recipe.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFFBF5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance spacing
                ],
              ),
              const SizedBox(height: 16),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF2A344D),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                ),
              ),
              const SizedBox(height: 24),

              // Main Step Reading Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161D2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A344D)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Step ${_currentStepIndex + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFFFFFBF5),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _startTimer(currentStep.timerMinutes),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isTimerRunning ? const Color(0x3310B981) : const Color(0x26FF6B35),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _isTimerRunning ? const Color(0xFF10B981) : const Color(0x4DFF6B35),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 16,
                                      color: _isTimerRunning ? const Color(0xFF10B981) : const Color(0xFFFF8C5A),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isTimerRunning ? _formatTimer(_remainingSeconds) : currentStep.time,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _isTimerRunning ? const Color(0xFF10B981) : const Color(0xFFFF8C5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Text(
                          currentStep.title,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFFBF5),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          currentStep.text,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.6,
                            color: Color(0xFFC5D1E0),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bottom Navigation Large Touch Targets
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: Color(0xFF2A344D)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: const Color(0xFF161D2E),
                      ),
                      onPressed: isFirst
                          ? null
                          : () {
                              setState(() {
                                _currentStepIndex--;
                                _activeTimer?.cancel();
                                _isTimerRunning = false;
                              });
                            },
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFBF5)),
                      label: const Text(
                        'Previous',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFFFFBF5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: isLast ? const Color(0xFF10B981) : const Color(0xFFFF6B35),
                        foregroundColor: const Color(0xFFFFFBF5),
                        elevation: 4,
                        shadowColor: const Color(0x66FF6B35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (isLast) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Bravo! Dish completed perfectly!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        } else {
                          setState(() {
                            _currentStepIndex++;
                            _activeTimer?.cancel();
                            _isTimerRunning = false;
                          });
                        }
                      },
                      label: Text(
                        isLast ? 'Done Cooking! 🎉' : 'Next Step',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      icon: Icon(isLast ? Icons.task_alt : Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

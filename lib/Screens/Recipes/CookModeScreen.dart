import 'package:flutter/material.dart';
import 'dart:async';
import '../../Models/RecipeModel.dart';

class CookModeScreen extends StatefulWidget {
  final Recipe recipe;
  const CookModeScreen({super.key, required this.recipe});

  @override
  State<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends State<CookModeScreen> {
  int currentStep = 0;
  Timer? _timer;
  int _start = 0;
  bool isTimerRunning = false;

  double _selectedMinutes = 10; // Default 10 mins

  void startTimer() {
    setState(() {
      _start = (_selectedMinutes * 60).toInt();
      isTimerRunning = true;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          isTimerRunning = false;
        });
        // Play sound or vibration here (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⏰ Timer Finished!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String get timerString {
    Duration duration = Duration(seconds: _start);
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check current theme brightness
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ Background ab Theme se aayega
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Cooking Mode"),
        // ✅ AppBar colors ab main.dart wali Theme se aayenge
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        elevation: 0,
      ),

      body: Column(
        children: [
          // Step Progress Bar
          LinearProgressIndicator(
            value: (currentStep + 1) / widget.recipe.steps.length,
            color: Theme.of(context).primaryColor, // Theme Color
            backgroundColor:
                isDark
                    ? Colors.grey[800]
                    : Colors.grey[200], // Dark/Light track color
            minHeight: 8,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Step ${currentStep + 1}",
                    style: TextStyle(
                      fontSize: 20,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.recipe.steps[currentStep],
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      // ✅ Text Color khud adjust hoga (White for Dark, Black for Light)
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Adjustable Timer Logic
                  if (isTimerRunning || _start > 0)
                    Column(
                      children: [
                        Text(
                          timerString,
                          style: TextStyle(
                            fontSize: 60,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isTimerRunning)
                              ElevatedButton.icon(
                                onPressed: () {
                                  _timer?.cancel();
                                  setState(() => isTimerRunning = false);
                                },
                                icon: const Icon(Icons.pause),
                                label: const Text("Pause"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: startTimer,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text("Resume"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                _timer?.cancel();
                                setState(() {
                                  isTimerRunning = false;
                                  _start = 0;
                                });
                              },
                              child: const Text(
                                "Reset",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const Text(
                          "Set Timer (Minutes)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _selectedMinutes,
                          min: 1,
                          max: 60,
                          divisions: 59,
                          label: "${_selectedMinutes.toInt()} min",
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() => _selectedMinutes = val);
                          },
                        ),
                        ElevatedButton.icon(
                          onPressed: startTimer,
                          icon: const Icon(Icons.timer, color: Colors.white),
                          label: Text(
                            "Start ${_selectedMinutes.toInt()} Min Timer",
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Navigation Controls (Bottom Bar)
          Container(
            padding: const EdgeInsets.all(20),
            // ✅ Bottom Container Color fix (White/Black ka jhatka nahi lagega)
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => currentStep--),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Grey is fine for "Back"
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Previous"),
                  )
                else
                  const SizedBox(width: 80),

                if (currentStep < widget.recipe.steps.length - 1)
                  ElevatedButton(
                    onPressed: () => setState(() => currentStep++),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).primaryColor, // Theme Color
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Next Step"),
                  )
                else
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFFF7043,
                      ), // Orange for Finish
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Finish Cooking"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

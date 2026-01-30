import 'package:flutter/material.dart';

class BackgroundGradient extends StatelessWidget {
  final Widget child;

  const BackgroundGradient({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base background color
        Container(
          color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
        ),
        
        // Ambient Blobs - Top Right
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark 
                  ? Colors.deepPurple.withValues(alpha: 0.3) 
                  : Colors.blueAccent.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.deepPurple.withValues(alpha: 0.3) 
                      : Colors.blueAccent.withValues(alpha: 0.2),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),

        // Ambient Blobs - Bottom Left
        Positioned(
          bottom: -50,
          left: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark 
                  ? Colors.indigo.withValues(alpha: 0.2) 
                  : Colors.purpleAccent.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.indigo.withValues(alpha: 0.2) 
                      : Colors.purpleAccent.withValues(alpha: 0.15),
                  blurRadius: 100,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}

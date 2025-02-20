import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'PDF/Riverpod_State_Management/State_Management.dart';
//mport the Riverpod state file

void main() {
  runApp(ProviderScope(child: FontWeightSliderApp())); // Wrap with ProviderScope
}

// Main App
class FontWeightSliderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FontWeightSliderScreen(),
    );
  }
}

// UI Screen
class FontWeightSliderScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontWeightIndex = ref.watch(fontWeightProvider); // Watch for updates

    return Scaffold(
      appBar: AppBar(title: Text("Font Weight Slider (Riverpod)")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text Widget with dynamic FontWeight
            Text(
              "Adjust the Font Weight",
              style: TextStyle(
                fontSize: 24,
                fontWeight: fontWeights[fontWeightIndex],
              ),
            ),
            SizedBox(height: 30),

            // Slider wrapped inside Consumer
            Consumer(
              builder: (context, ref, child) {
                final fontWeightIndex = ref.watch(fontWeightProvider);

                return Slider(
                  min: 0,
                  max: 8, // Since we have 9 font weights (index 0 to 8)
                  divisions: 8, // Steps of 1 (mapped to 100–900)
                  value: fontWeightIndex.toDouble(),
                  onChanged: (newValue) {
                    ref.read(fontWeightProvider.notifier).setFontWeight(newValue.toInt());
                  },
                );
              },
            ),

            SizedBox(height: 10),
            Text(
              "Font Weight: w${fontWeights[fontWeightIndex].value}",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

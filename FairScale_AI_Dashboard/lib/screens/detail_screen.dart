import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> appData;

  const DetailScreen({Key? key, required this.appData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Global gradient background
      appBar: AppBar(
        title: Text('Evaluation for ${appData["name"]}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          // The Model comparison widgets
          final Widget modelA = _buildModelCard(
            context,
            title: "Model A (Original)",
            isBiased: true,
            decision: "REJECT",
            confidence: "87%",
            reasons: ["Income threshold", "Neighborhood factor (Zip Code)", "Employment history gaps"],
          );

          final Widget modelC = _buildModelCard(
            context,
            title: "Model C (Fair Mirror)",
            isBiased: false,
            decision: "APPROVE",
            confidence: "91%",
            reasons: ["Consistent baseline income", "Adjusted for historical bias", "Verified identity markers"],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Models Layout dependent on screen size
                if (isMobile)
                  Column(
                    children: [
                      modelA,
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("VS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white54)),
                      ),
                      modelC,
                    ],
                  )
                else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: modelA),
                        Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: const Text("VS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white54)),
                        ),
                        Expanded(child: modelC),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Gemini Explanation Block
                GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.blueAccent[100]),
                          const SizedBox(width: 12),
                          Text(
                            "Gemini 1.5 Flash Analysis",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent[100],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Warning: Potential Bias detected. Model A heavily weighted the zip code proxy feature which historically correlates with demographic disparities, leading to an unfair bias flag. Model C removes this constraint and focuses on direct income parity, computing an Approval.",
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          _showSuccessDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Apply FairFlow Fix",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildModelCard(
    BuildContext context, {
    required String title,
    required bool isBiased,
    required String decision,
    required String confidence,
    required List<String> reasons,
  }) {
    Color indicatorColor = isBiased ? Colors.redAccent : Colors.greenAccent;
    IconData iconData = isBiased ? Icons.warning_amber_rounded : Icons.check_circle_outline;

    return GlassCard(
      padding: const EdgeInsets.all(32),
      border: Border.all(
        color: indicatorColor.withOpacity(0.4),
        width: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: indicatorColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text("Decision:", style: TextStyle(color: Colors.white54)),
          Text(
            decision,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: indicatorColor,
            ),
          ),
          const SizedBox(height: 16),
          Text("Confidence: $confidence", style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),
          const Text("Key Factors:", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          ...reasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(fontSize: 18, color: Colors.white)),
                    Expanded(child: Text(r, style: const TextStyle(height: 1.4, color: Colors.white))),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Fairness Applied"),
        content: const Text("The application logic has healed successfully. Leo's outcome has been adjusted using Model C's fair recommendation.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(ctx); 
            },
            child: const Text("Return to Feed", style: TextStyle(color: Colors.indigoAccent)),
          )
        ],
      ),
    );
  }
}

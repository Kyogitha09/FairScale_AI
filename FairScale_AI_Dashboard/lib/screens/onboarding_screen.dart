import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
import '../widgets/glass_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  bool _isSpawningModels = false;
  double _spawnProgress = 0.0;
  bool _modelsSpawned = false;

  void _startVertexAISpawn() {
    setState(() {
      _isSpawningModels = true;
      _spawnProgress = 0.0;
    });
    
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _spawnProgress += 0.1;
      });
      if (_spawnProgress >= 1.0) {
        timer.cancel();
        setState(() {
          _isSpawningModels = false;
          _modelsSpawned = true;
          _currentStep += 1; 
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Uses global background
      appBar: AppBar(
        title: const Text('FairScale AI Setup Phase', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Stepper container
          double containerWidth = constraints.maxWidth;
          if (containerWidth > 800) containerWidth = 800; // Constrain for desktop
          
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: SizedBox(
                width: containerWidth,
                child: GlassCard(
                  padding: const EdgeInsets.all(8.0),
                  child: Stepper(
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep == 2 && !_modelsSpawned) {
                        _startVertexAISpawn();
                      } else if (_currentStep < 3) {
                        setState(() { _currentStep += 1; });
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0 && !_isSpawningModels) {
                        setState(() { _currentStep -= 1; });
                      }
                    },
                    controlsBuilder: (BuildContext context, ControlsDetails details) {
                      if (_currentStep == 2 && _isSpawningModels) return const SizedBox.shrink();
                      if (_currentStep == 3) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(_currentStep == 2 ? 'Spawn Vertex AI Models' : 'Continue Step'),
                            ),
                            const SizedBox(width: 12),
                            if (_currentStep != 0) 
                              TextButton(
                                onPressed: details.onStepCancel,
                                child: const Text('Back', style: TextStyle(color: Colors.white70)),
                              ),
                          ],
                        ),
                      );
                    },
                    steps: [
                      // STEP 1
                      Step(
                        title: const Text('Upload Historical Dataset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        content: GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.indigoAccent),
                              const SizedBox(height: 16),
                              const Text("Drag and drop your historical CSV/Excel data here", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 24),
                              OutlinedButton(
                                onPressed: () {}, 
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                  padding: const EdgeInsets.all(16)
                                ),
                                child: const Text("Browse Local Files")
                              )
                            ],
                          ),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                      ),
                      
                      // STEP 2
                      Step(
                        title: const Text('Map FairFlow Attributes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tell FairScale which columns from your dataset matter for bias detection.", style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 24),
                            _buildMappingRow("The Target (Goal)", ["Loan Approved?"]),
                            const SizedBox(height: 16),
                            _buildMappingRow("Protected Attributes", ["Race", "Gender", "Age"]),
                            const SizedBox(height: 16),
                            _buildMappingRow("Valid Features", ["Income", "Skills", "Credit Score", "Debt-to-Income"]),
                          ],
                        ),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                      ),

                      // STEP 3
                      Step(
                        title: const Text('Spawn Vertex AI Engines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Initializing the tripartite bias detection architecture via Google Vertex AI.", style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 24),
                            if (_isSpawningModels || _modelsSpawned)
                              GlassCard(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value: _spawnProgress, 
                                      backgroundColor: Colors.white12, 
                                      color: Colors.indigoAccent,
                                      minHeight: 6,
                                    ),
                                    const SizedBox(height: 32),
                                    _buildModelSpawningStatus("Model A (The Original)", "Trained on all features including hidden proxies.", _spawnProgress > 0.3),
                                    _buildModelSpawningStatus("Model B (The Detective)", "Trained strictly to identify demographic bias correlations.", _spawnProgress > 0.6),
                                    _buildModelSpawningStatus("Model C (The Fair Mirror)", "Trained exclusively on validated features, ignoring protected traits.", _spawnProgress > 0.9),
                                  ],
                                ),
                              )
                          ],
                        ),
                        isActive: _currentStep >= 2,
                        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                      ),

                      // STEP 4
                      Step(
                        title: const Text('Generate Interceptor API', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Paste this webhook URL into your Bank Website's backend. All future loan applications will be intercepted by FairScale AI before a final decision is made.", style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white70)),
                            const SizedBox(height: 24),
                            GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: Row(
                                children: [
                                  const Icon(Icons.link, color: Colors.indigoAccent),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: SelectableText(
                                      "https://api.fairscale.ai/v1/intercept?key=fs_live_92kxA819Plzm",
                                      style: TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.greenAccent),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Colors.white70),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('API Key Copied!', style: TextStyle(color: Colors.white)))
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                  );
                                },
                                icon: const Icon(Icons.launch),
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Text("Finish Setup & Go to Live Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 8,
                                  shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                ),
                              ),
                            )
                          ],
                        ),
                        isActive: _currentStep >= 3,
                        state: _currentStep == 3 ? StepState.indexed : StepState.complete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildMappingRow(String label, List<String> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: chips.map((c) => Chip(
            label: Text(c, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.white.withOpacity(0.1),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          )).toList()
           ..add(Chip(label: const Text("+ Add more", style: TextStyle(color: Colors.white70)), backgroundColor: Colors.transparent, side: BorderSide(color: Colors.white.withOpacity(0.2)))),
        )
      ],
    );
  }

  Widget _buildModelSpawningStatus(String title, String subtitle, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? Colors.greenAccent : Colors.white30,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDone ? Colors.white : Colors.white70)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white54)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

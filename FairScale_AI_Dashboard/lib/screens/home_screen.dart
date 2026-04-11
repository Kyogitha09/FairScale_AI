import 'package:flutter/material.dart';
import 'dart:async';
import 'scanning_screen.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<List<Map<String, dynamic>>> _pendingStream = Stream.periodic(
    const Duration(seconds: 15),
    (count) {
      return [
        {"id": "app_1001", "name": "Jane Doe", "income": 55000, "gender": "Female", "risk": "High"},
        {"id": "app_1002", "name": "John Smith", "income": 95000, "gender": "Male", "risk": "Low"},
        {"id": "app_1003", "name": "Alex Johnson", "income": 62000, "gender": "Non-binary", "risk": "Medium"},
      ];
    },
  ).asBroadcastStream();

  List<Map<String, dynamic>> initialData = [
    {"id": "app_1001", "name": "Jane Doe", "income": 55000, "gender": "Female", "risk": "High"},
    {"id": "app_1002", "name": "John Smith", "income": 95000, "gender": "Male", "risk": "Low"},
  ];

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsiveness
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: Colors.transparent, // Global gradient from main.dart
      appBar: isDesktop ? null : AppBar(
        title: const Text('FairScale AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: isDesktop ? null : Drawer(
        backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.9),
        child: _buildSidebarItems(),
      ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: _buildSidebarItems(),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Live Application Feed",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Real-time interception queue awaiting FairScale AI verification.", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 32),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _pendingStream,
                      initialData: initialData,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final apps = snapshot.data!;
                        return ListView.builder(
                          itemCount: apps.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ApplicationCard(appData: apps[index]),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarItems() {
    return ListView(
      padding: const EdgeInsets.only(top: 32),
      children: [
        if (MediaQuery.of(context).size.width >= 800)
             const Padding(
               padding: EdgeInsets.only(left: 24, bottom: 32),
               child: Text("FairScale AI", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
             ),
        ListTile(
          leading: const Icon(Icons.dashboard, color: Colors.indigoAccent),
          title: const Text("Interception Feed", style: TextStyle(fontWeight: FontWeight.bold)),
          selectedTileColor: Colors.white.withOpacity(0.05),
          selected: true,
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.white70),
          title: const Text("Dataset Mapping", style: TextStyle(color: Colors.white70)),
          onTap: () {},
        )
      ],
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> appData;

  const ApplicationCard({Key? key, required this.appData}) : super(key: key);

  Color _getRiskColor(String risk) {
    switch (risk) {
      case "High": return Colors.redAccent;
      case "Medium": return Colors.orangeAccent;
      case "Low": return Colors.greenAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(appData["risk"]);
    
    return GlassCard(
      padding: EdgeInsets.zero,
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          appData["name"],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("ID: ${appData["id"]} • Income: \$${appData["income"]} • ${appData["gender"]}", style: const TextStyle(color: Colors.white54)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: riskColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: riskColor.withOpacity(0.5)),
          ),
          child: Text(
            "${appData["risk"]} Risk detected",
            style: TextStyle(
              color: riskColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ScanningScreen(appData: appData),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
          );
        },
      ),
    );
  }
}

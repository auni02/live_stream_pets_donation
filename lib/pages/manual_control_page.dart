import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManualControlPage extends StatefulWidget {
  const ManualControlPage({super.key});

  @override
  State<ManualControlPage> createState() => _ManualControlPageState();
}

class _ManualControlPageState extends State<ManualControlPage> {
  final DatabaseReference systemRef =
      FirebaseDatabase.instance.ref('system');

  int foodLevel = 0;
  String status = 'idle';
  String lastDispensed = '--';

  @override
  void initState() {
    super.initState();

    systemRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      setState(() {
        foodLevel = data['foodLevel'] ?? 0;
        status = data['status'] ?? 'idle';
        lastDispensed = data['lastDispensed'] ?? '--';
      });
    });
  }

  // 🟢 DISPENSE
  Future<void> dispenseFood() async {
    if (status == 'paused' || status == 'low_food') return;

    await systemRef.update({
      'dispense': true,
      'status': 'dispensing',
    });

    await Future.delayed(const Duration(seconds: 1));
    await systemRef.update({'dispense': false});
  }

  // ⏸ PAUSE
  Future<void> pauseDispenser() async {
    await systemRef.update({'status': 'paused'});
  }

  // ▶ RESUME
  Future<void> resumeDispenser() async {
    await systemRef.update({'status': 'idle'});
  }

  // 🔄 RESET
  Future<void> resetDispenser() async {
    await systemRef.update({
      'reset': true,
      'status': 'idle',
    });

    await Future.delayed(const Duration(seconds: 1));
    await systemRef.update({'reset': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6DDC8),
      appBar: AppBar(
        title: const Text('Manual Control'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            infoCard(),
            const SizedBox(height: 30),

            // DISPENSE
            actionButton(
              label: 'Dispense\nFood',
              onTap: dispenseFood,
              enabled: status != 'paused' && status != 'low_food',
            ),

            const SizedBox(height: 16),

            // PAUSE / RESUME
            actionButton(
              label: status == 'paused'
                  ? 'Resume\nDispenser'
                  : 'Pause\nDispenser',
              onTap: status == 'paused'
                  ? resumeDispenser
                  : pauseDispenser,
            ),

            const SizedBox(height: 16),

            // RESET
            actionButton(
              label: 'Reset\nDispenser',
              onTap: resetDispenser,
            ),

            const SizedBox(height: 30),
            alertCard(),
          ],
        ),
      ),
    );
  }

  // ---------- UI ----------

  Widget infoCard() {
    return card(
      child: Column(
        children: [
          Text(
            'Food Level: $foodLevel%',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Status: ${status.toUpperCase()}',
            style: TextStyle(
              color: status == 'paused' || status == 'low_food'
                  ? Colors.red
                  : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget alertCard() {
    return card(
      child: Column(
        children: [
          const Text(
            'Alerts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Last Dispensed: $lastDispensed'),
          if (status == 'low_food')
            const Text(
              '⚠ Low Food Level!',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget actionButton({
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

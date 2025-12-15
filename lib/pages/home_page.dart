// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geofence/components/my_button.dart';
// import 'package:geofence/components/my_drawer.dart';
// import 'package:go_router/go_router.dart';
//
// import '../providers/providers.dart';
// import '../widgets/glass_card.dart';
// import '../widgets/section_header.dart';
// import 'map_page.dart'; // <-- We use MapLocation from here
//
// class HomePage extends ConsumerStatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   ConsumerState<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends ConsumerState<HomePage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Store the selected map location (returned from MapPage)
//   MapLocation? selectedLocation;
//
//   String place = 'Karachi, PK';
//   double lat = 24.8607;
//   double lon = 67.0011;
//   DateTime date = DateTime.now().add(const Duration(days: 1));
//   bool isButtonEnabled = false;
//
//   void _updateButtonState() {
//     final validDate = date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
//     setState(() {
//       isButtonEnabled = validDate && selectedLocation != null;
//     });
//   }
//
//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // user can't dismiss
//       builder: (_) => const Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   void _hideLoadingDialog() {
//     if (Navigator.of(context).canPop()) {
//       Navigator.of(context).pop(); // close the loading dialog
//     }
//   }
//
//
//   // Open map in a tall bottom sheet and receive MapLocation back
//   void _openMap() async {
//     final result = await showModalBottomSheet<MapLocation>(
//       context: context,
//       isScrollControlled: true, // allow near full-height
//       useSafeArea: true,        // respect notches and system UI
//       backgroundColor: Colors.transparent,
//       builder: (ctx) {
//         final h = MediaQuery.of(ctx).size.height;
//         return Container(
//           height: h * 0.92, // ~full screen minus app bar
//           decoration: BoxDecoration(
//             color: Theme.of(ctx).colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: MapPage(initialLat: lat, initialLon: lon, placeName: place),
//         );
//       },
//     );
//
//     if (result != null) {
//       setState(() {
//         selectedLocation = result; // keep the MapLocation object
//         lat = result.lat;          // keep your existing fields in sync (optional)
//         lon = result.lon;
//         place = result.placeName;
//       });
//       _updateButtonState();
//     }
//   }
//
//   // Call ApiService via provider; then navigate to results
//   // Call ApiService via provider; then print API response
//
// // ...
//
//   Future<void> _fetchData() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//     if (selectedLocation == null) return;
//
//     final api = ref.read(apiServiceProvider);
//
//     _showLoadingDialog(); // if you added the spinner helper
//     try {
//       final response = await api.fetchClimatology(
//         lat: selectedLocation!.lat,
//         lon: selectedLocation!.lon,
//         date: date,
//       );
//
//       print('✅ API Response: $response');
//
//       if (!mounted) return;
//       context.pushNamed('result_page', extra: response); // <— pass data here
//     } catch (e) {
//       print('❌ API error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ Failed: $e')),
//         );
//       }
//     } finally {
//       if (mounted) _hideLoadingDialog(); // if using the spinner
//     }
//   }
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Screen'),
//       ),
//       body: Container(
//         margin: EdgeInsets.symmetric(
//           vertical: MediaQuery.of(context).size.height * 0.10,
//           horizontal: MediaQuery.of(context).size.width * 0.05,
//         ),
//         child: Align(
//           alignment: Alignment.center,
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 980),
//             child: ListView(
//               padding: const EdgeInsets.only(right: 16, bottom: 24),
//               children: [
//                 const SectionHeader(
//                   title: 'Pick your parade details',
//                   subtitle: 'Choose place and date. We’ll estimate the rain risk and readiness.',
//                 ),
//                 const SizedBox(height: 12),
//
//                 GlassCard(
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         TextFormField(
//                           initialValue: place,
//                           decoration: const InputDecoration(
//                             labelText: 'Place (city or area)',
//                             hintText: 'e.g., Karachi, PK',
//                             prefixIcon: Icon(Icons.place_outlined),
//                           ),
//                           validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//                           onSaved: (v) => place = v!.trim(),
//                         ),
//
//                         const SizedBox(height: 12),
//                         OutlinedButton.icon(
//                           icon: const Icon(Icons.date_range_outlined),
//                           label: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text('Date: ${date.toIso8601String().split("T").first}'),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                             side: BorderSide(color: cs.outlineVariant),
//                             foregroundColor: cs.onSurface,
//                           ),
//                           onPressed: () async {
//                             final picked = await showDatePicker(
//                               context: context,
//                               firstDate: DateTime.now(),
//                               lastDate: DateTime.now().add(const Duration(days: 365)),
//                               initialDate: date,
//                             );
//                             if (picked != null) {
//                               setState(() => date = picked);
//                               _updateButtonState(); // re-check enabled state
//                             }
//                           },
//                         ),
//
//                         const SizedBox(height: 12),
//                         // Map button to open map panel
//                         MyButton(text: "Select location on Map", onTap: _openMap),
//
//                         const SizedBox(height: 18),
//
//                         // Fetch Data button (enabled only when date valid + location selected)
//                         MyButton(
//                           text: "Fetch Data",
//                           onTap: isButtonEnabled ? _fetchData : () {},
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//                 Center(
//                   child: TextButton(
//                     onPressed: () {
//                       context.pushNamed("about_page");
//                     },
//                     child: const Text('About & Data Sources'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       drawer: const MyDrawer(),
//     );
//   }
// }












import 'package:flutter/material.dart';
import 'package:geofence/components/my_drawer.dart';
import 'package:intl/intl.dart';
import '../services/mock_data_service.dart';
import '../widgets/sparkline.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MockDataService _svc;
  String _machine = 'M1';

  @override
  void initState() {
    super.initState();
    _svc = MockDataService(machineId: _machine)..start();
  }

  @override
  void dispose() {
    _svc.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.0');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _MachinePicker(
              value: _machine,
              onChanged: (v) {
                if (v == null) return;
                setState(() => _machine = v);
                _svc.stop();
                _svc = MockDataService(machineId: _machine)..start();
              },
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // optional soft gradient background
          const _SoftBackdrop(),
          StreamBuilder<SensorSnapshot>(
            stream: _svc.stream,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final d = snap.data!;
              return LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 1000;
                  final gridCount = wide ? 3 : 1;
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: gridCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _HeroInfoCard(
                          title: 'Roll',
                          value: d.rollNo,
                          subtitle: 'Lot ${d.lotNo}',
                          leading: Icons.groups_2_outlined,
                        ),
                        _MetricCard(
                          title: 'Length',
                          value: '${fmt.format(d.lengthM)} m',
                          history: d.gsmHistory, // just to have a line
                          hint: 'Cumulative',
                        ),
                        _MetricCard(
                          title: 'Width',
                          value: '${fmt.format(d.widthCm)} cm',
                          history: d.widthHistory,
                          min: 175,
                          max: 205,
                        ),
                        _MetricCard(
                          title: 'GSM',
                          value: fmt.format(d.gsm),
                          history: d.gsmHistory,
                          min: 100,
                          max: 150,
                        ),
                        _HoleCard(hole: d.hole, ts: d.ts),
                        _ActionCard(
                          title: 'Live Monitoring',
                          subtitle: 'Open real time screen',
                          icon: Icons.monitor_heart_outlined,
                          onTap: () => Navigator.pushNamed(context, '/live_monitor'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}

class _SoftBackdrop extends StatelessWidget {
  const _SoftBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF3FE), Color(0xFFF9FAFB)],
        ),
      ),
    );
  }
}

class _MachinePicker extends StatelessWidget {
  const _MachinePicker({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        items: const [
          DropdownMenuItem(value: 'M1', child: Text('Machine 1')),
          DropdownMenuItem(value: 'M2', child: Text('Machine 2')),
          DropdownMenuItem(value: 'M3', child: Text('Machine 3')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroInfoCard extends StatelessWidget {
  const _HeroInfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.leading,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData leading;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              child: Icon(leading, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 6),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.history,
    this.min,
    this.max,
    this.hint,
  });

  final String title;
  final String value;
  final List<double> history;
  final double? min;
  final double? max;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 250),
              builder: (_, __, child) => child!,
              child: Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            ),
            if (hint != null) Text(hint!, style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Sparkline(values: history, min: min, max: max),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoleCard extends StatefulWidget {
  const _HoleCard({required this.hole, required this.ts});
  final bool hole;
  final DateTime ts;

  @override
  State<_HoleCard> createState() => _HoleCardState();
}

class _HoleCardState extends State<_HoleCard> with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final danger = widget.hole;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _blink,
              builder: (_, __) => Icon(
                danger ? Icons.warning_amber_rounded : Icons.task_alt,
                size: 40,
                color: danger ? Color.lerp(Colors.red, Colors.orange, _blink.value) : Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hole detected'),
                  const SizedBox(height: 6),
                  Text(
                    danger ? 'Yes' : 'No',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: danger ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Updated ${TimeOfDay.fromDateTime(widget.ts).format(context)}',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

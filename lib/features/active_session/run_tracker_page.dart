import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // The Map
import 'package:latlong2/latlong.dart';      // Coordinates
import 'package:geolocator/geolocator.dart'; // GPS
import 'package:pedometer/pedometer.dart';   // Steps
import 'package:permission_handler/permission_handler.dart';
import '../../theme/theme_manager.dart';

class RunTrackerPage extends StatefulWidget {
  final String taskName; // e.g., "Morning Run"

  const RunTrackerPage({super.key, required this.taskName});

  @override
  State<RunTrackerPage> createState() => _RunTrackerPageState();
}

class _RunTrackerPageState extends State<RunTrackerPage> {
  // 📍 LOCATION DATA
  List<LatLng> _routePoints = [];
  MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5, // Update every 5 meters
  );

  // 👣 STEP DATA
  StreamSubscription<StepCount>? _stepStream;
  int _initialSteps = -1;
  int _currentSteps = 0;

  // ⏱️ TIMER & STATS
  Timer? _timer;
  Duration _duration = Duration.zero;
  double _totalDistanceKm = 0.0;
  double _caloriesBurned = 0.0;
  String _currentPace = "0'00\""; // min/km

  bool _isPaused = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStart();
  }

  Future<void> _checkPermissionsAndStart() async {
    // 1. Request Permissions
    await [
      Permission.location,
      Permission.activityRecognition,
    ].request();

    // 2. Start Services
    _startTimer();
    _startLocationTracking();
    _startStepTracking();

    setState(() => _isLoading = false);
  }

  // --- 🏃‍♂️ TRACKING LOGIC ---

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _duration += const Duration(seconds: 1);
          _updatePace();
        });
      }
    });
  }

  void _startLocationTracking() async {
    _positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings)
        .listen((Position position) {
      if (_isPaused) return;

      LatLng newPoint = LatLng(position.latitude, position.longitude);

      setState(() {
        // Calculate distance added
        if (_routePoints.isNotEmpty) {
          double dist = Geolocator.distanceBetween(
            _routePoints.last.latitude, _routePoints.last.longitude,
            newPoint.latitude, newPoint.longitude,
          );
          _totalDistanceKm += (dist / 1000); // Convert meters to km
          _caloriesBurned += (dist * 0.06); // Approx 60 cal per km (rough estimate)
        }

        _routePoints.add(newPoint);

        // Auto-center map
        _mapController.move(newPoint, 17.0);
      });
    });
  }

  void _startStepTracking() {
    _stepStream = Pedometer.stepCountStream.listen((StepCount event) {
      if (_initialSteps == -1) _initialSteps = event.steps;
      setState(() {
        _currentSteps = event.steps - _initialSteps;
        // Fallback calorie calc if GPS is flaky
        if (_totalDistanceKm == 0) {
          _caloriesBurned = _currentSteps * 0.04;
        }
      });
    }, onError: (e) => print("Step Error: $e"));
  }

  void _updatePace() {
    if (_totalDistanceKm > 0) {
      double minutes = _duration.inMinutes.toDouble();
      double paceVal = minutes / _totalDistanceKm;
      int paceMin = paceVal.floor();
      int paceSec = ((paceVal - paceMin) * 60).round();
      _currentPace = "$paceMin'${paceSec.toString().padLeft(2, '0')}\"";
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _finishRun() {
    _timer?.cancel();
    _positionStream?.cancel();
    _stepStream?.cancel();

    // Show Summary Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeManager().cardColor,
        title: Text("Run Complete! 🎉", style: TextStyle(color: ThemeManager().textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Distance: ${_totalDistanceKm.toStringAsFixed(2)} km", style: TextStyle(color: ThemeManager().subText)),
            Text("Time: ${_formatDuration(_duration)}", style: TextStyle(color: ThemeManager().subText)),
            Text("Steps: $_currentSteps", style: TextStyle(color: ThemeManager().subText)),
            Text("Calories: ${_caloriesBurned.toStringAsFixed(0)} kcal", style: TextStyle(color: ThemeManager().subText)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Dialog
              Navigator.pop(context, true); // Close Page & Return Success
            },
            child: const Text("Save & Exit", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    _stepStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager();
    return Scaffold(
      backgroundColor: theme.bgColor,
      body: Stack(
        children: [
          // 🗺️ 1. MAP LAYER (Full Screen)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0), // Will update on load
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                // Using OpenStreetMap (Free, no API key needed)
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.stride',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 5.0,
                    color: Colors.orangeAccent, // Strava Orange!
                  ),
                ],
              ),
              // Current Position Marker
              if (_routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _routePoints.last,
                      width: 20, height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 📊 2. TOP OVERLAY (Time & Pace)
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassMetric(theme, "TIME", _formatDuration(_duration), fontSize: 24),
                _buildGlassMetric(theme, "PACE", _currentPace, fontSize: 24),
              ],
            ),
          ),

          // 👟 3. BOTTOM STATS CARD (Strava Style)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Stat (Distance)
                  Text(
                    "${_totalDistanceKm.toStringAsFixed(2)}",
                    style: TextStyle(color: theme.textColor, fontSize: 60, fontWeight: FontWeight.bold, height: 1),
                  ),
                  Text("KILOMETERS", style: TextStyle(color: theme.subText, fontSize: 12, letterSpacing: 1.5)),

                  const SizedBox(height: 20),

                  // Secondary Stats Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSimpleStat(theme, Icons.local_fire_department_rounded, "${_caloriesBurned.toInt()}", "KCAL"),
                      _buildSimpleStat(theme, Icons.directions_walk_rounded, "$_currentSteps", "STEPS"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pause/Resume Button
                      FloatingActionButton(
                        heroTag: "pause",
                        backgroundColor: _isPaused ? Colors.green : Colors.orange,
                        onPressed: _togglePause,
                        child: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 30),
                      ),
                      const SizedBox(width: 20),
                      // Finish Button
                      FloatingActionButton(
                        heroTag: "stop",
                        backgroundColor: theme.accentColor,
                        onPressed: _finishRun,
                        child: const Icon(Icons.stop_rounded, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔙 Back Button
          Positioned(
            top: 40, left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87), // Map is light, use dark icon
              onPressed: () => Navigator.pop(context),
            ),
          ),

          if (_isLoading)
            Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildGlassMetric(ThemeManager theme, String label, String value, {double fontSize = 18}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6), // Glass effect
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(ThemeManager theme, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: theme.accentColor, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: theme.textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: theme.subText, fontSize: 10)),
      ],
    );
  }
}
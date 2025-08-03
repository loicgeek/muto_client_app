import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

// Navigation Step Model
class NavigationStep {
  final String instruction;
  final String maneuver;
  final double distance;
  final double duration;
  final LatLng location;
  final String direction;

  NavigationStep({
    required this.instruction,
    required this.maneuver,
    required this.distance,
    required this.duration,
    required this.location,
    required this.direction,
  });

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    return NavigationStep(
      instruction: json['instruction'] ?? '',
      maneuver: json['maneuver']['type'] ?? 'straight',
      distance: (json['distance'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toDouble(),
      location: LatLng(
        json['maneuver']['location'][1].toDouble(),
        json['maneuver']['location'][0].toDouble(),
      ),
      direction: json['maneuver']['modifier'] ?? '',
    );
  }
}

@RoutePage()
class StepByStepNavigationScreen extends StatefulWidget {
  final LatLng startLocation;
  final LatLng endLocation;
  final String startAddress;
  final String endAddress;

  const StepByStepNavigationScreen({
    super.key,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
  });

  @override
  _StepByStepNavigationScreenState createState() =>
      _StepByStepNavigationScreenState();
}

class _StepByStepNavigationScreenState
    extends State<StepByStepNavigationScreen> {
  MapController mapController = MapController();
  List<LatLng> routePoints = [];
  List<NavigationStep> navigationSteps = [];
  LatLng? currentLocation;
  int currentStepIndex = 0;
  bool isNavigating = false;
  bool isLoading = true;
  Timer? locationTimer;
  double totalDistance = 0;
  double totalDuration = 0;
  double remainingDistance = 0;
  double remainingDuration = 0;

  @override
  void initState() {
    super.initState();
    currentLocation = widget.startLocation;
    _loadRoute();
    _startNavigation();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  // Load route from OSRM
  Future<void> _loadRoute() async {
    try {
      final url = 'http://router.project-osrm.org/route/v1/driving/'
          '${widget.startLocation.longitude},${widget.startLocation.latitude};'
          '${widget.endLocation.longitude},${widget.endLocation.latitude}'
          '?overview=full&geometries=polyline&steps=true';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];

        // Decode polyline
        routePoints = _decodePolyline(route['geometry']);

        // Extract navigation steps
        navigationSteps = [];
        for (var leg in route['legs']) {
          for (var step in leg['steps']) {
            navigationSteps.add(NavigationStep.fromJson(step));
          }
        }

        totalDistance = route['distance'].toDouble();
        totalDuration = route['duration'].toDouble();
        remainingDistance = totalDistance;
        remainingDuration = totalDuration;

        setState(() {
          isLoading = false;
        });

        _centerMapOnRoute();
      }
    } catch (e) {
      print('Error loading route: $e');
      // Fallback to direct line
      setState(() {
        routePoints = [widget.startLocation, widget.endLocation];
        navigationSteps = [
          NavigationStep(
            instruction: 'Head to destination',
            maneuver: 'straight',
            distance:
                _calculateDistance(widget.startLocation, widget.endLocation),
            duration:
                _calculateDistance(widget.startLocation, widget.endLocation) /
                    15, // Assume 15 m/s
            location: widget.endLocation,
            direction: '',
          ),
        ];
        isLoading = false;
      });
    }
  }

  // Decode polyline from OSRM
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // Calculate distance between two points
  double _calculateDistance(LatLng point1, LatLng point2) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, point1, point2);
  }

  // Start navigation simulation
  void _startNavigation() {
    setState(() {
      isNavigating = true;
    });

    locationTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _updateCurrentLocation();
    });
  }

  // Simulate location updates along the route
  void _updateCurrentLocation() {
    if (!isNavigating || routePoints.isEmpty) return;

    // Simple simulation: move along route points
    int targetIndex = (currentStepIndex + 1).clamp(0, routePoints.length - 1);
    if (targetIndex < routePoints.length) {
      setState(() {
        currentLocation = routePoints[targetIndex];
      });

      // Update current step
      _updateCurrentStep();

      // Move map to current location
      mapController.move(currentLocation!, 16.0);

      // Check if reached destination
      if (targetIndex >= routePoints.length - 1) {
        _stopNavigation();
      }
    }
  }

  // Update current navigation step
  void _updateCurrentStep() {
    if (currentLocation == null || navigationSteps.isEmpty) return;

    double minDistance = double.infinity;
    int closestStepIndex = currentStepIndex;

    for (int i = currentStepIndex; i < navigationSteps.length; i++) {
      double distance =
          _calculateDistance(currentLocation!, navigationSteps[i].location);
      if (distance < minDistance) {
        minDistance = distance;
        closestStepIndex = i;
      }
    }

    if (closestStepIndex != currentStepIndex) {
      setState(() {
        currentStepIndex = closestStepIndex;
      });

      // Calculate remaining distance and time
      _calculateRemaining();
    }
  }

  // Calculate remaining distance and time
  void _calculateRemaining() {
    remainingDistance = 0;
    remainingDuration = 0;

    for (int i = currentStepIndex; i < navigationSteps.length; i++) {
      remainingDistance += navigationSteps[i].distance;
      remainingDuration += navigationSteps[i].duration;
    }

    setState(() {});
  }

  // Stop navigation
  void _stopNavigation() {
    setState(() {
      isNavigating = false;
    });
    locationTimer?.cancel();

    // Show arrival dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Arrived'),
        content: Text('You have reached your destination!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Center map on route
  void _centerMapOnRoute() {
    if (routePoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(routePoints);
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(50.0),
      ),
    );
  }

  // Get maneuver icon
  IconData _getManeuverIcon(String maneuver, String direction) {
    switch (maneuver.toLowerCase()) {
      case 'turn':
        return direction.contains('left') ? Icons.turn_left : Icons.turn_right;
      case 'sharp':
        return direction.contains('left')
            ? Icons.turn_sharp_left
            : Icons.turn_sharp_right;
      case 'slight':
        return direction.contains('left')
            ? Icons.turn_slight_left
            : Icons.turn_slight_right;
      case 'continue':
      case 'straight':
        return Icons.straight;
      case 'uturn':
        return Icons.u_turn_left;
      case 'arrive':
        return Icons.flag;
      case 'depart':
        return Icons.play_arrow;
      default:
        return Icons.navigation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isNavigating ? Icons.stop : Icons.play_arrow),
            onPressed: isNavigating ? _stopNavigation : _startNavigation,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isLandscape
              ? _buildLandscapeLayout()
              : _buildPortraitLayout(),
    );
  }

  // Landscape layout - side by side
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Navigation panel
        Expanded(
          flex: 2,
          child: _buildNavigationPanel(),
        ),
        // Map
        Expanded(
          flex: 3,
          child: _buildMap(),
        ),
      ],
    );
  }

  // Portrait layout - stacked
  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Current instruction
        _buildCurrentInstruction(),
        // Map
        Expanded(child: _buildMap()),
        // Navigation panel
        Container(
          height: 200,
          child: _buildNavigationPanel(),
        ),
      ],
    );
  }

  // Current instruction widget for portrait mode
  Widget _buildCurrentInstruction() {
    if (navigationSteps.isEmpty || currentStepIndex >= navigationSteps.length) {
      return SizedBox.shrink();
    }

    final currentStep = navigationSteps[currentStepIndex];

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue[700],
      child: Row(
        children: [
          Icon(
            _getManeuverIcon(currentStep.maneuver, currentStep.direction),
            color: Colors.white,
            size: 40,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStep.instruction,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'in ${(currentStep.distance).toStringAsFixed(0)}m',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(remainingDistance / 1000).toStringAsFixed(1)} km',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(remainingDuration / 60).toStringAsFixed(0)} min',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation panel
  Widget _buildNavigationPanel() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Header with ETA and distance
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${(remainingDistance / 1000).toStringAsFixed(1)} km',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ETA',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${(remainingDuration / 60).toStringAsFixed(0)} min',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation steps list
          Expanded(
            child: ListView.builder(
              itemCount: navigationSteps.length,
              itemBuilder: (context, index) {
                final step = navigationSteps[index];
                final isCurrentStep = index == currentStepIndex;
                final isPastStep = index < currentStepIndex;

                return Container(
                  color: isCurrentStep ? Colors.blue[50] : Colors.white,
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrentStep
                            ? Colors.blue
                            : isPastStep
                                ? Colors.grey
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getManeuverIcon(step.maneuver, step.direction),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      step.instruction,
                      style: TextStyle(
                        fontWeight:
                            isCurrentStep ? FontWeight.bold : FontWeight.normal,
                        color: isPastStep ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${step.distance.toStringAsFixed(0)}m',
                      style: TextStyle(
                        color: isPastStep ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    trailing: isCurrentStep
                        ? Icon(Icons.navigation, color: Colors.blue)
                        : isPastStep
                            ? Icon(Icons.check, color: Colors.grey)
                            : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Map widget
  Widget _buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation ?? widget.startLocation,
        initialZoom: 16.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        // Tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.navigation_app',
        ),

        // Route polyline
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              color: Colors.blue,
              strokeWidth: 6.0,
            ),
          ],
        ),

        // Markers
        MarkerLayer(
          markers: [
            // Start marker
            Marker(
              point: widget.startLocation,
              width: 40,
              height: 40,
              child: Icon(
                Icons.play_arrow,
                color: Colors.green,
                size: 40,
              ),
            ),

            // End marker
            Marker(
              point: widget.endLocation,
              width: 40,
              height: 40,
              child: Icon(
                Icons.flag,
                color: Colors.red,
                size: 40,
              ),
            ),

            // Current location
            if (currentLocation != null)
              Marker(
                point: currentLocation!,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

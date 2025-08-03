import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'package:muto_driver_app/app/features/home/data/models/delivery_model.dart';

@RoutePage()
class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  MapController mapController = MapController();
  DeliveryModel? deliveryData;
  List<Marker> markers = [];
  List<Polyline> polylines = [];
  Timer? locationTimer;
  LatLng? courierPosition;
  bool isLoading = true;

  // Replace with your actual API endpoints
  final String deliveryApiUrl = 'https://your-api.com/api/deliveries/10';
  final String courierLocationUrl =
      'https://your-api.com/api/courier-location/2';

  @override
  void initState() {
    super.initState();
    _loadDeliveryData();
    _startLocationTracking();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  // Load initial delivery data
  Future<void> _loadDeliveryData() async {
    try {
      // For demo purposes, using the provided JSON data
      final sampleData = {
        "id": 10,
        "pickup_address": "123 Main St, City, State",
        "pickup_latitude": "40.71280000",
        "pickup_longitude": "-74.00600000",
        "dropoff_address": "456 Oak Ave, City, State",
        "dropoff_latitude": "40.75890000",
        "dropoff_longitude": "-73.98510000",
        "status": "assigned",
        "content_type": "Electronics",
        "price": "25.00",
        "courier": {
          "id": 2,
          "online": true,
          "last_latitude": "40.72000000",
          "last_longitude": "-74.00000000"
        },
        "vehicle": {
          "make": "Honda",
          "model": "CBR600",
          "license_plate": "XYZ788",
          "type": "bike"
        }
      };

      setState(() {
        deliveryData = DeliveryModel.fromJson(sampleData);
        isLoading = false;
      });

      _setupMap();
    } catch (e) {
      print('Error loading delivery data: $e');
      setState(() => isLoading = false);
    }
  }

  // Set up map markers and route
  void _setupMap() {
    if (deliveryData == null) return;

    final pickup =
        LatLng(deliveryData!.pickupLatitude!, deliveryData!.pickupLongitude!);
    final dropoff =
        LatLng(deliveryData!.dropoffLatitude!, deliveryData!.dropoffLongitude!);

    setState(() {
      markers = [
        Marker(
          point: pickup,
          width: 80,
          height: 80,
          child: Container(
            child: Column(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Pickup',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        Marker(
          point: dropoff,
          width: 80,
          height: 80,
          child: Container(
            child: Column(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Dropoff',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    });

    // Add courier position if available
    if (deliveryData!.courier?.lastLatitude != null &&
        deliveryData!.courier?.lastLongitude != null) {
      courierPosition = LatLng(
        deliveryData!.courier!.lastLatitude!,
        deliveryData!.courier!.lastLongitude!,
      );
      _updateCourierMarker();
    }

    // Draw route with OpenRouteService
    _drawRouteWithOpenRouteService(pickup, dropoff);

    // Center map
    _centerMapOnRoute(pickup, dropoff);
  }

  // Update courier marker
  void _updateCourierMarker() {
    if (courierPosition == null) return;

    setState(() {
      // Remove existing courier marker
      markers.removeWhere((marker) =>
          marker.child is Container &&
          (marker.child as Container).child is Column &&
          ((marker.child as Container).child as Column).children.length > 1 &&
          ((marker.child as Container).child as Column).children[1]
              is Container &&
          (((marker.child as Container).child as Column).children[1]
                  as Container)
              .child is Text &&
          ((((marker.child as Container).child as Column).children[1]
                          as Container)
                      .child as Text)
                  .data ==
              'Courier');

      // Add updated courier marker
      markers.add(
        Marker(
          point: courierPosition!,
          width: 80,
          height: 100,
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getVehicleIcon(deliveryData!.vehicle?.type ?? ""),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Courier',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                Text(
                  '${deliveryData!.vehicle?.make ?? ''}',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Get vehicle icon based on type
  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'car':
        return Icons.directions_car;
      case 'truck':
        return Icons.local_shipping;
      case 'bicycle':
        return Icons.pedal_bike;
      default:
        return Icons.delivery_dining;
    }
  }

  // Draw route using OpenRouteService
  Future<void> _drawRouteWithOpenRouteService(
      LatLng pickup, LatLng dropoff) async {
    try {
      // Choose profile based on vehicle type
      String profile = _getRouteProfile(deliveryData?.vehicle?.type ?? 'car');

      final url =
          'https://api.openrouteservice.org/v2/directions/$profile/geojson';

      var openRouteServiceApiKey =
          "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjEwZDJmMjdiZTEyYjQ4ZDliOWE0YzYzZDgwYzE2YWUxIiwiaCI6Im11cm11cjY0In0=";

      final headers = {
        'Authorization': openRouteServiceApiKey,
        'Content-Type': 'application/json',
      };
      var queryParams = {
        "api_key": openRouteServiceApiKey,
      };

      final body = json.encode({
        'coordinates': [
          [pickup.longitude, pickup.latitude],
          [dropoff.longitude, dropoff.latitude],
        ],
        'format': 'geojson',
        'instructions': false,
        'elevation': false,
      });

      final response = await Dio().post(
        url,
        queryParameters: queryParams,
        data: body,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Get route info
        final properties = data['features'][0]['properties']['summary'];
        final distance = properties['distance']; // in meters
        final duration = properties['duration']; // in seconds
        final coordinates =
            data['features'][0]['geometry']['coordinates'] as List;
        print(coordinates);

        // Convert coordinates to LatLng points
        final routePoints = coordinates.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();

        setState(() {
          polylines = [
            Polyline(
              points: routePoints,
              color: Colors.blue,
              strokeWidth: 4.0,
            ),
          ];
        });

        // Update delivery data with route info
        print('Route distance: ${(distance / 1000).toStringAsFixed(2)} km');
        print('Route duration: ${(duration / 60).toStringAsFixed(0)} minutes');
      } else {
        // Fallback to straight line if API fails
        print('OpenRouteService error: ${response.statusCode}');
        _drawFallbackRoute(pickup, dropoff);
      }
    } catch (e) {
      print('Error getting route from OpenRouteService: $e');
      // Fallback to straight line
      _drawFallbackRoute(pickup, dropoff);
    }
  }

  // Get route profile based on vehicle type
  String _getRouteProfile(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'bicycle':
      case 'bike':
        return 'cycling-regular';
      case 'motorcycle':
        return 'driving-car'; // OpenRouteService doesn't have motorcycle, use car
      case 'car':
      case 'truck':
      default:
        return 'driving-car';
    }
  }

  // Fallback route drawing (straight line)
  void _drawFallbackRoute(LatLng pickup, LatLng dropoff) {
    setState(() {
      polylines = [
        Polyline(
          points: [pickup, dropoff],
          color: Colors.blue.withOpacity(0.7),
          strokeWidth: 4.0,
          // isDotted: true, // Make it dotted to indicate it's not a real route
        ),
      ];
    });
  }

  // Draw route between pickup and dropoff
  void _drawRoute(LatLng pickup, LatLng dropoff) {
    setState(() {
      polylines = [
        Polyline(
          points: [pickup, dropoff], // In real app, use routing service
          color: Colors.blue,
          strokeWidth: 4.0,
          // isDotted: true,
        ),
      ];
    });
  }

  // Center map on route
  void _centerMapOnRoute(LatLng pickup, LatLng dropoff) {
    final bounds = LatLngBounds(pickup, dropoff);

    // Add some padding to the bounds
    final paddedBounds = LatLngBounds(
      LatLng(
        bounds.south - 0.01,
        bounds.west - 0.01,
      ),
      LatLng(
        bounds.north + 0.01,
        bounds.east + 0.01,
      ),
    );

    mapController.fitCamera(
      CameraFit.bounds(
        bounds: paddedBounds,
        padding: EdgeInsets.all(50.0),
      ),
    );
  }

  // Start real-time location tracking
  void _startLocationTracking() {
    locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateCourierLocation();
    });
  }

  // Update courier location (replace with your real-time service)
  Future<void> _updateCourierLocation() async {
    try {
      // Simulate real-time position updates
      // In your real app, call your real-time location service here
      if (courierPosition != null) {
        // Simulate movement (small random changes)
        final newLat = courierPosition!.latitude +
            (DateTime.now().millisecond % 10 - 5) * 0.0001;
        final newLng = courierPosition!.longitude +
            (DateTime.now().millisecond % 10 - 5) * 0.0001;

        setState(() {
          courierPosition = LatLng(newLat, newLng);
        });

        _updateCourierMarker();
      }
    } catch (e) {
      print('Error updating courier location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Tracking'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Delivery info card
                if (deliveryData != null) _buildDeliveryInfoCard(),
                // Map
                Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter:
                          LatLng(40.7128, -74.0060), // Default to NYC
                      initialZoom: 12.0,
                      minZoom: 3.0,
                      maxZoom: 18.0,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      // Tile layer (OpenStreetMap)
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.muto_driver_app',
                        maxZoom: 19,
                      ),

                      // Polyline layer for routes
                      PolylineLayer(
                        polylines: polylines,
                      ),

                      // Marker layer
                      MarkerLayer(
                        markers: markers,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Center on route button
          FloatingActionButton(
            heroTag: "center",
            mini: true,
            onPressed: () {
              if (deliveryData != null) {
                final pickup = LatLng(deliveryData!.pickupLatitude!,
                    deliveryData!.pickupLongitude!);
                final dropoff = LatLng(deliveryData!.dropoffLatitude!,
                    deliveryData!.dropoffLongitude!);
                _centerMapOnRoute(pickup, dropoff);
              }
            },
            child: Icon(Icons.center_focus_strong),
            backgroundColor: Colors.blue[600],
          ),
          SizedBox(height: 8),

          // Follow courier button
          FloatingActionButton(
            heroTag: "follow",
            mini: true,
            onPressed: () {
              if (courierPosition != null) {
                mapController.move(courierPosition!, 15.0);
              }
            },
            child: Icon(Icons.my_location),
            backgroundColor: Colors.green[600],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery #${deliveryData!.id}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(deliveryData!.status ?? ""),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (deliveryData!.status ?? "").toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Courier: ${deliveryData!.vehicle?.make} ${deliveryData!.vehicle?.model}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      'License: ${deliveryData!.vehicle?.licensePlate}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    deliveryData!.courier?.online == true
                        ? Icons.circle
                        : Icons.circle_outlined,
                    color: deliveryData!.courier?.online == true
                        ? Colors.green
                        : Colors.red,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    deliveryData!.courier?.online == true
                        ? 'Online'
                        : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: deliveryData!.courier?.online == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.orange;
      case 'picked_up':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/home/repositories/deliveries_repository.dart';
import 'package:muto_client_app/app/ui/loading_overlay.dart';
import 'package:muto_client_app/app/ui/ui_utils.dart';

@RoutePage()
class AddDeliveryScreen extends StatefulWidget {
  const AddDeliveryScreen({super.key});

  @override
  State<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends State<AddDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Map related
  MapController pickupMapController = MapController();
  MapController dropoffMapController = MapController();
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  bool isSelectingPickup = true;
  List<Marker> pickupMarkers = [];
  List<Marker> dropoffMarkers = [];

  // Form controllers
  final TextEditingController _pickupAddressController =
      TextEditingController();
  final TextEditingController _dropoffAddressController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _packageCountController = TextEditingController();
  final TextEditingController _contentTypeController = TextEditingController();
  final TextEditingController _handlingInstructionsController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _courierFeeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _pickupDateTime;
  DateTime? _dropoffDateTime;
  String _selectedVehicleType = 'bike';

  final List<String> _vehicleTypes = [
    'bike',
    'motorcycle',
    'car',
    'truck',
    'bicycle'
  ];

  @override
  void initState() {
    super.initState();
    // Default to Douala, Cameroon coordinates
    pickupMapController = MapController();
    dropoffMapController = MapController();
  }

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _dropoffAddressController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _packageCountController.dispose();
    _contentTypeController.dispose();
    _handlingInstructionsController.dispose();
    _priceController.dispose();
    _courierFeeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      if (isSelectingPickup) {
        pickupLocation = point;
      } else {
        dropoffLocation = point;
      }
      _updatePickupMarkers();
    });
  }

  void _updatePickupMarkers() {
    pickupMarkers.clear();

    if (pickupLocation != null) {
      pickupMarkers.add(
        Marker(
          point: pickupLocation!,
          width: 80,
          height: 80,
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
      );
    }
  }

  void _updateDropoffMarkers() {
    dropoffMarkers.clear();

    if (dropoffLocation != null) {
      dropoffMarkers.add(
        Marker(
          point: dropoffLocation!,
          width: 80,
          height: 80,
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
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<DateTime?> _selectDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        return dateTime;
      }
    }
  }

  void _submitDelivery() async {
    if (pickupLocation != null &&
        dropoffLocation != null &&
        _pickupDateTime != null) {
      try {
        final deliveryData = {
          "pickup_address": _pickupAddressController.text,
          "pickup_latitude": pickupLocation!.latitude,
          "pickup_longitude": pickupLocation!.longitude,
          "dropoff_address": _dropoffAddressController.text,
          "dropoff_latitude": dropoffLocation!.latitude,
          "dropoff_longitude": dropoffLocation!.longitude,
          "pickup_scheduled_at": _pickupDateTime?.toUtc().toIso8601String(),
          "dropoff_scheduled_at": _dropoffDateTime?.toUtc().toIso8601String(),
          "weight_kg": double.tryParse(_weightController.text) ?? 0.0,
          "length_cm": double.tryParse(_lengthController.text) ?? 0.0,
          "width_cm": double.tryParse(_widthController.text) ?? 0.0,
          "height_cm": double.tryParse(_heightController.text) ?? 0.0,
          "package_count": int.tryParse(_packageCountController.text) ?? 1,
          "content_type": _contentTypeController.text,
          "handling_instructions": _handlingInstructionsController.text,
          "price": double.tryParse(_priceController.text) ?? 0.0,
          "courier_fee": double.tryParse(_courierFeeController.text) ?? 0.0,
          "notes": _notesController.text,
          "vehicle_type": _selectedVehicleType,
        };

        // Here you would typically call your API to create the delivery
        var delivery =
            await context.read<LoadingController>().wrapWithLoading(() {
          return getIt.get<DeliveriesRepository>().create(deliveryData);
        });

        // Show success message and navigate back
        UiUtils.showSnackbarSuccess(context, 'Delivery created successfully!');

        // Navigate back or to delivery list
        context.router.pop(delivery);
      } catch (e) {
        UiUtils.showSnackBar(
            context, 'An error occurred while creating the delivery');
      }
    } else {
      UiUtils.showSnackBar(
          context, 'Please fill all required fields and select locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Add New Delivery',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? Color.fromARGB(255, 35, 81, 249)
                          : Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Step titles
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Locations',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        _currentStep >= 0 ? FontWeight.w600 : FontWeight.w400,
                    color: _currentStep >= 0
                        ? Color.fromARGB(255, 35, 81, 249)
                        : Color(0xFF999999),
                  ),
                ),
                Text(
                  'Package Details',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        _currentStep >= 1 ? FontWeight.w600 : FontWeight.w400,
                    color: _currentStep >= 1
                        ? Color.fromARGB(255, 35, 81, 249)
                        : Color(0xFF999999),
                  ),
                ),
                Text(
                  'Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        _currentStep >= 2 ? FontWeight.w600 : FontWeight.w400,
                    color: _currentStep >= 2
                        ? Color.fromARGB(255, 35, 81, 249)
                        : Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildLocationStep(),
                _buildPackageDetailsStep(),
                _buildSummaryStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side:
                            BorderSide(color: Color.fromARGB(255, 35, 81, 249)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 35, 81, 249),
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 2 ? _submitDelivery : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 35, 81, 249),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Create Delivery' : 'Next',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return ListView(
      children: [
        // Location selection controls
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select locations on the map',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelectingPickup
                      ? Color.fromARGB(255, 35, 81, 249)
                      : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isSelectingPickup ? Colors.white : Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pickup',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: isSelectingPickup ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pickupAddressController,
                      decoration: InputDecoration(
                        labelText: 'Pickup Address',
                        prefixIcon:
                            Icon(Icons.location_on, color: Colors.green),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FlutterMap(
                          mapController: pickupMapController,
                          options: MapOptions(
                            initialCenter:
                                LatLng(4.0511, 9.7679), // Douala, Cameroon
                            initialZoom: 12.0,
                            onTap: (tapPosition, point) {
                              setState(() {
                                pickupLocation = point;
                                _updatePickupMarkers();
                              });
                            },
                            interactionOptions: InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.muto_client_app',
                            ),
                            MarkerLayer(markers: pickupMarkers),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? dateTime = await _selectDateTime();
                        if (dateTime != null) {
                          setState(() {
                            _pickupDateTime = dateTime;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup Time',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _pickupDateTime?.toString().substring(0, 16) ??
                                  'Select date & time',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _pickupDateTime != null
                                    ? Colors.black
                                    : Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isSelectingPickup
                      ? Color.fromARGB(255, 35, 81, 249)
                      : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: !isSelectingPickup ? Colors.white : Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Dropoff',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: !isSelectingPickup ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              TextField(
                controller: _dropoffAddressController,
                decoration: InputDecoration(
                  labelText: 'Dropoff Address',
                  prefixIcon: Icon(Icons.location_on, color: Colors.red),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: dropoffMapController,
                    options: MapOptions(
                      initialCenter: LatLng(4.0511, 9.7679), // Douala, Cameroon
                      initialZoom: 12.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          dropoffLocation = point;
                          _updateDropoffMarkers();
                        });
                      },
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.muto_client_app',
                      ),
                      MarkerLayer(markers: dropoffMarkers),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Date time selection
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? dateTime = await _selectDateTime();
                        if (dateTime != null) {
                          setState(() {
                            _dropoffDateTime = dateTime;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dropoff Time',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _dropoffDateTime?.toString().substring(0, 16) ??
                                  'Select date & time',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _dropoffDateTime != null
                                    ? Colors.black
                                    : Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Map
      ],
    );
  }

  Widget _buildPackageDetailsStep() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package dimensions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Package Information',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _packageCountController,
                          decoration: InputDecoration(
                            labelText: 'Package Count',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lengthController,
                          decoration: InputDecoration(
                            labelText: 'Length (cm)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _widthController,
                          decoration: InputDecoration(
                            labelText: 'Width (cm)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _contentTypeController,
                    decoration: InputDecoration(
                      labelText: 'Content Type',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Vehicle and pricing
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Options',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedVehicleType,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Type',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _vehicleTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedVehicleType = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'Price (FCFA)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _courierFeeController,
                          decoration: InputDecoration(
                            labelText: 'Courier Fee (FCFA)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _handlingInstructionsController,
                    decoration: InputDecoration(
                      labelText: 'Handling Instructions',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Summary',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),

          // Locations summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pickup Location',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  _pickupAddressController.text.isEmpty
                      ? 'Not selected'
                      : _pickupAddressController.text,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                if (_pickupDateTime != null) ...[
                  SizedBox(height: 4),
                  Text(
                    'Scheduled: ${_pickupDateTime.toString().substring(0, 16)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Dropoff Location',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  _dropoffAddressController.text.isEmpty
                      ? 'Not selected'
                      : _dropoffAddressController.text,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                if (_dropoffDateTime != null) ...[
                  SizedBox(height: 4),
                  Text(
                    'Scheduled: ${_dropoffDateTime.toString().substring(0, 16)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 16),

          // Package details summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Package Details',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                          'Weight', '${_weightController.text} kg'),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                          'Packages', _packageCountController.text),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem('Dimensions',
                          '${_lengthController.text}×${_widthController.text}×${_heightController.text} cm'),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                          'Content', _contentTypeController.text),
                    ),
                  ],
                ),
                if (_handlingInstructionsController.text.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _buildSummaryItem(
                      'Instructions', _handlingInstructionsController.text),
                ],
                if (_notesController.text.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _buildSummaryItem('Notes', _notesController.text),
                ],
              ],
            ),
          ),

          SizedBox(height: 16),

          // Delivery options summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Options',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                          'Vehicle Type', _selectedVehicleType.toUpperCase()),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                          'Total Price', '${_priceController.text} FCFA'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildSummaryItem(
                    'Courier Fee', '${_courierFeeController.text} FCFA'),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Cost breakdown
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 35, 81, 249).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color.fromARGB(255, 35, 81, 249).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cost Breakdown',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 35, 81, 249),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Price:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${_priceController.text} FCFA',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Courier Fee:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${_courierFeeController.text} FCFA',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Divider(height: 20, color: Color.fromARGB(255, 35, 81, 249)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Pays:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 35, 81, 249),
                      ),
                    ),
                    Text(
                      '${(double.tryParse(_priceController.text) ?? 0.0) - (double.tryParse(_courierFeeController.text) ?? 0.0)} FCFA',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 35, 81, 249),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 100), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Not specified' : value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: value.isEmpty ? Color(0xFF999999) : Colors.black,
          ),
        ),
      ],
    );
  }
}

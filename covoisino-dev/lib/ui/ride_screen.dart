// ride.dart
import 'package:covoisino/core/localization.dart';
import 'package:covoisino/core/utils.dart';
import 'package:covoisino/main.dart';
import 'package:covoisino/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../core/providers.dart';
import '../core/models.dart';
import '../core/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// QR Scanning Screen
class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final qrData = barcodes.first.rawValue;
              if (qrData == null) return;

              try {
                final rideDetails =
                    await context.read<RideProvider>().handleQRScan(qrData);

                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RideConfirmationScreen(
                      driverDetails: rideDetails['driver']!,
                      vehicleDetails: rideDetails['vehicle']!,
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
          // Scanning frame animation
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          // Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildControlButton(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                ),
                _buildControlButton(
                  icon: Icons.flash_on,
                  onTap: () => controller.toggleTorch(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon),
      ),
    );
  }
}

// QR Display Screen
class QRDisplayScreen extends StatelessWidget {
  const QRDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer2<VehicleProvider, RideProvider>(
      builder: (context, vehicle, ride, _) {
        final currentVehicle = vehicle.vehicle;
        if (currentVehicle == null) return const SizedBox.shrink();

        // Start listening for active rides
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ride.checkForActiveRide();
        });

        // Check for active ride
        if (ride.currentRide != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RideScreen()),
            );
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.get('your_qr_code')),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: FutureBuilder<String>(
            future: ride.createQRSession(currentVehicle),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Column(
                children: [
                  const Spacer(),
                  // Vehicle details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.directions_car_outlined,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentVehicle.color} ${currentVehicle.model}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currentVehicle.licensePlate,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(duration: const Duration(milliseconds: 600)),
                      SlideEffect(
                        begin: const Offset(0, -0.2),
                        end: const Offset(0, 0),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // QR Code
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: snapshot.data!,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.get('your_qr_code'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.get('show_to_passengers'),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(duration: const Duration(milliseconds: 600)),
                      ScaleEffect(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// RideConfirmationScreen
class RideConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> driverDetails;
  final Map<String, dynamic> vehicleDetails;
  final bool isDriver;

  const RideConfirmationScreen({
    super.key,
    required this.driverDetails,
    required this.vehicleDetails,
    this.isDriver = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer2<AppAuthProvider, VehicleProvider>(
      builder: (context, auth, vehicle, _) => Scaffold(
        appBar: AppBar(
          title: Text(
              isDriver ? l10n.get('new_passenger') : l10n.get('confirm_ride')),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Profile section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'profile_photo',
                          child: displayPhoto(
                            isDriver 
                                ? auth.currentUser?.photoUrl ?? '' 
                                : driverDetails['photoUrl'] ?? '',
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isDriver
                              ? auth.currentUser?.name ?? 'User'
                              : driverDetails['name'] ?? 'Unknown Driver',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.get('verified_member'),
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(duration: const Duration(milliseconds: 600)),
                      ScaleEffect(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  if (!isDriver) ...[
                    // Vehicle details for passengers
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.get('vehicle_details'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.directions_car_outlined),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vehicleDetails['color'] ?? 'Unknown'} ${vehicleDetails['model'] ?? 'Vehicle'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    vehicleDetails['licensePlate'] ??
                                        'License Plate',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate(
                      effects: [
                        FadeEffect(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Safety reminder
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.amber[100]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.security,
                                color: Colors.amber[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              l10n.get('safety_check'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isDriver
                              ? l10n.get('verify_passenger')
                              : l10n.get('verify_driver'),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Consumer<RideProvider>(
                builder: (context, ride, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AsyncButton(
                      onPressed: () async {
                        final user = auth.currentUser!;
                        
                        await ride.startRide(
                          driver: isDriver
                              ? user
                              : User(
                                  name: driverDetails['name'],
                                  email: driverDetails['email'],
                                  phoneNumber: driverDetails['phoneNumber'],
                                  isVerified: true,
                                ),
                          passenger: isDriver
                              ? User(
                                  name: driverDetails['name'],
                                  email: driverDetails['email'],
                                  phoneNumber: driverDetails['phoneNumber'],
                                  isVerified: true,
                                )
                              : user,
                          vehicle: isDriver
                              ? vehicle.vehicle!
                              : Vehicle(
                                  model: vehicleDetails['model'],
                                  licensePlate: vehicleDetails['licensePlate'],
                                  color: vehicleDetails['color'],
                                ),
                        );
                        
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RideScreen()),
                        );
                      },
                      child: Text(
                        isDriver
                            ? l10n.get('accept_ride')
                            : l10n.get('start_ride'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        l10n.get('cancel'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(
              effects: [
                FadeEffect(duration: const Duration(milliseconds: 600)),
                SlideEffect(
                  begin: const Offset(0, 0.2),
                  end: const Offset(0, 0),
                  duration: const Duration(milliseconds: 600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// RideScreen
class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is being closed, end the ride
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      if (rideProvider.currentRide != null) {
        rideProvider.endRide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return WillPopScope(
      // Show end ride confirmation when back button is pressed
      onWillPop: () async {
        final ride = Provider.of<RideProvider>(context, listen: false);
        if (ride.currentRide != null) {
          _showEndRideConfirmation(context, ride, l10n);
        }
        return false; // Still prevent actual back navigation
      },
      child: Scaffold(
      body: Consumer2<RideProvider, AppAuthProvider>(
        builder: (context, ride, auth, _) {
          final currentRide = ride.currentRide;
          if (currentRide == null) return const SizedBox.shrink();

          // Determine if current user is the driver
          final isDriver = currentRide.driver.email == auth.currentUser?.email;

          // Get the other user's details (passenger for driver, driver for passenger)
          final otherUser =
              isDriver ? currentRide.passenger : currentRide.driver;

          return Stack(
            children: [
              // Map placeholder
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[200]!,
                      Colors.grey[300]!,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                ),
              ),

              // Emergency button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF4757),
                          Color(0xFFFF6B81),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4757).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.emergency,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.get('emergency'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate(
                effects: [
                  FadeEffect(duration: const Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: const Offset(0, -0.2),
                    end: const Offset(0, 0),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),

              // Ride details panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Hero(
                            tag: 'profile_photo',
                            child: displayPhoto(
                              otherUser.photoUrl ?? '',
                              size: 60,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherUser.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!isDriver)
                                  Text(
                                    '${currentRide.vehicle.color} ${currentRide.vehicle.model} - ${currentRide.vehicle.licensePlate}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AsyncButton(
                        onPressed: () async =>
                            _showEndRideConfirmation(context, ride, l10n),
                        color: Colors.red,
                        child: Text(
                          l10n.get('end_ride'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(
                effects: [
                  FadeEffect(duration: const Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: const Offset(0, 0.2),
                    end: const Offset(0, 0),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ));
  }

  void _showEndRideConfirmation(
      BuildContext context, RideProvider ride, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 44,
          vertical: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('end_ride'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('end_ride_confirmation'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            AsyncButton(
              onPressed: () async {
                await ride.endRide();
                if (!context.mounted) return;
                Navigator.pop(context); // Just close the bottom sheet

                // Now navigate to home screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              color: Colors.red,
              child: Text(
                l10n.get('end_ride'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ).animate(
        effects: [
          FadeEffect(duration: const Duration(milliseconds: 300)),
          SlideEffect(
            begin: const Offset(0, 0.1),
            end: const Offset(0, 0),
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

// Emergency Screen
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency header
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF4757),
                      Color(0xFFFF6B81),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4757).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emergency,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.get('emergency_services'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.get('get_assistance'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ).animate(
                effects: [
                  FadeEffect(duration: const Duration(milliseconds: 600)),
                  ScaleEffect(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              // Emergency actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.get('emergency_actions'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEmergencyAction(
                      icon: Icons.phone,
                      title: l10n.get('call_emergency'),
                      subtitle: l10n.get('connect_responders'),
                      onTap: () => _handleEmergencyCall(context, l10n),
                    ),
                    const SizedBox(height: 16),
                    _buildEmergencyAction(
                      icon: Icons.share_location,
                      title: l10n.get('share_location'),
                      subtitle: l10n.get('send_location'),
                      onTap: () => _handleLocationShare(context, l10n),
                    ),
                  ],
                ),
              ).animate(
                effects: [
                  FadeEffect(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),

              const Spacer(),
              AsyncButton(
                onPressed: () async => Navigator.pop(context),
                color: Colors.grey[800],
                child: Text(
                  l10n.get('back_to_safety'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate(
                effects: [
                  FadeEffect(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4757).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF4757),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _handleEmergencyCall(BuildContext context, AppLocalizations l10n) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(l10n.get('call_emergency')),
      content: Text(l10n.get('call_confirmation')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.get('cancel'),
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            // Launch emergency call - using standard emergency number
              final Uri phoneUri = Uri(scheme: 'tel', path: '112');
            try {
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.get('could_not_launch_call')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.get('error')}${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF4757),
          ),
          child: Text(
            l10n.get('call'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

Future<void> _handleLocationShare(BuildContext context, AppLocalizations l10n) async {
  try {
    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('location_permission_denied')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.get('location_permissions_permanently_denied')),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: l10n.get('settings'),
            onPressed: () {
              Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return;
    }
    
    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    // Create Google Maps link with the coordinates
    final mapsUrl = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
    
    // Create a message with the emergency information
    final message = '${l10n.get('emergency_message')}\n${l10n.get('my_location')}: $mapsUrl';
    
    // Share the location
    await Share.share(
      message,
      subject: l10n.get('emergency_location_share'),
    );
    
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.get('location_shared_successfully')),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.get('error')}${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}

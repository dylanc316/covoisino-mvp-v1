// providers.dart
import 'dart:async';
import 'package:covoisino/ui/home_screen.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../main.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart' show BuildContext;

class AppAuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final VehicleProvider vehicleProvider;
  final BuildContext context;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Updated constructor to accept VehicleProvider and context
  AppAuthProvider(this.vehicleProvider, this.context) {
    _isLoading = true;
    notifyListeners();

    // Initialize Remote Config
    initializeRemoteConfig().then((_) {
      final initialUser = _auth.currentUser;
      if (initialUser != null) {
        // Set basic user info immediately
        _currentUser = User(
          name: initialUser.displayName ?? '',
          email: initialUser.email ?? '',
          phoneNumber: initialUser.phoneNumber ?? '',
          photoUrl: initialUser.photoURL,
          isVerified: initialUser.emailVerified,
          verifiers: const [],
          pendingVerifiers: const [],
        );

        // Fetch complete user data including verifiers
        FirebaseFirestore.instance
            .collection('users')
            .doc(initialUser.uid)
            .get()
            .then((userDoc) async {
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            
            // Get current sponsorship status from Firestore
            final currentStatus = userData['sponsorshipStatus'] as String?;
            final appState =
                Provider.of<AppStateProvider>(context, listen: false);

            // Update local sponsorship status
            if (currentStatus == 'completed') {
              appState.updateSponsorshipStatus(SponsorshipStatus.completed);
            } else if (currentStatus == 'pending') {
              appState.updateSponsorshipStatus(SponsorshipStatus.pending);
            } else {
              appState.updateSponsorshipStatus(SponsorshipStatus.notStarted);
            }

            // Get verifier emails
            final verifierEmails =
                (userData['verifiers'] as List<dynamic>? ?? [])
                    .map((v) => v['email'] as String)
                    .toList();

            // Get pending verifier emails
            final pendingVerifierEmails =
                (userData['pendingVerifiers'] as List<dynamic>? ?? [])
                    .map((v) => v['email'] as String)
                    .toList();

            // Fetch verifier details from Firestore
            final List<Contact> verifiers =
                await Future.wait(verifierEmails.map((email) async {
              final verifierDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: email)
                  .limit(1)
                  .get();

              if (verifierDoc.docs.isEmpty) return null;

              final verifierData = verifierDoc.docs.first.data();
              return Contact(
                name: verifierData['name'] as String? ?? 'Unknown User',
                phone: verifierData['phoneNumber'] as String? ?? '',
                isVerified: true,
              );
            })).then((list) => list.whereType<Contact>().toList());

            // Fetch pending verifier details from Firestore
            final List<Contact> pendingVerifiers =
                await Future.wait(pendingVerifierEmails.map((email) async {
              final verifierDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: email)
                  .limit(1)
                  .get();

              if (verifierDoc.docs.isEmpty) return null;

              final verifierData = verifierDoc.docs.first.data();
              return Contact(
                name: verifierData['name'] as String? ?? 'Unknown User',
                phone: verifierData['phoneNumber'] as String? ?? '',
                isVerified: false,
              );
            })).then((list) => list.whereType<Contact>().toList());

            _currentUser = User(
              name: userData['name'] as String,
              email: userData['email'] as String,
              phoneNumber: userData['phoneNumber'] as String,
              photoUrl: initialUser.photoURL,
              isVerified: initialUser.emailVerified,
              verifiers: verifiers,
              pendingVerifiers: pendingVerifiers,
            );
            
            // Update verified sponsors count
            appState.updateVerifiedSponsors(verifiers.length);
            appState.updatePendingSponsors(pendingVerifiers.length);

            // Check verification status after all data is loaded
            await checkVerificationStatus();
          }
          _isLoading = false;
          notifyListeners();

          // Ensure vehicle data is fetched regardless of user document existence
          await vehicleProvider.fetchVehicle();
          
        }).catchError((error) {
          debugPrint('Error fetching user data: $error');
          _isLoading = false;
          notifyListeners();
          
          // Still try to fetch vehicle data even if user data fetch fails
          vehicleProvider.fetchVehicle();
        });
      } else {
        _isLoading = false;
        notifyListeners();
      }
    });

    // Listen to auth state changes
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser != null) {
        await setUser(firebaseUser);
        // Fetch vehicle data whenever auth state changes
        await vehicleProvider.fetchVehicle();
      } else {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      if (userCredential.user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userData.exists) {
          _currentUser = User(
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            photoUrl: userCredential.user?.photoURL,
            isVerified: userCredential.user?.emailVerified ?? false,
          );
        }
      }
      await checkVerificationStatus();
    } catch (e) {
      _handleFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
      String name, String email, String password, String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update user profile with display name
        await userCredential.user?.updateDisplayName(name);

        // Create Firestore document for the user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'vehicles': [],
          'verifiers': [],
          'pendingVerifiers': [],
        });

        // Update current user
        _currentUser = User(
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          photoUrl: userCredential.user?.photoURL,
          isVerified: false,
        );

        // Send email verification
        await userCredential.user?.sendEmailVerification();
      }
    } catch (e) {
      _handleFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      // User info will be updated via the auth state listener
    } catch (e) {
      _handleFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _handleFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        if (user.email != email) {
          await user.verifyBeforeUpdateEmail(email);
        }
        await user.updateDisplayName(name);
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }

        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': name,
        });

        _currentUser = User(
          name: name,
          email: email,
          phoneNumber: _currentUser?.phoneNumber ?? '',
          photoUrl: photoUrl,
          isVerified: user.emailVerified,
          verifiers: _currentUser?.verifiers ?? [],
          pendingVerifiers: _currentUser?.pendingVerifiers ?? [],
        );
      }
    } catch (e) {
      _handleFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _currentUser = null;
    } catch (e) {
      _handleFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmail(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For Firebase, email verification is handled through the link sent to email
      // This method might need to be modified based on your verification requirements
      await _auth.currentUser?.reload();
    } catch (e) {
      _handleFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUser(firebase_auth.User firebaseUser) async {
    try {
      // Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        throw 'User document not found';
      }

      final userData = userDoc.data()!;

      // Get verifier emails
      final verifierEmails = (userData['verifiers'] as List<dynamic>? ?? [])
          .map((v) => v['email'] as String)
          .toList();
      print('verifierEmails: $verifierEmails');

      // Get pending verifier emails
      final pendingVerifierEmails =
          (userData['pendingVerifiers'] as List<dynamic>? ?? [])
              .map((v) => v['email'] as String)
              .toList();
      print('pendingVerifierEmails: $pendingVerifierEmails');
      // Fetch verifier details from Firestore
      final List<Contact> verifiers =
          await Future.wait(verifierEmails.map((email) async {
        final verifierDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (verifierDoc.docs.isEmpty) return null;

        final verifierData = verifierDoc.docs.first.data();
        return Contact(
          name: verifierData['name'] as String? ?? 'Unknown User',
          phone: verifierData['phoneNumber'] as String? ?? '',
          isVerified: true,
        );
      })).then((list) => list.whereType<Contact>().toList());

      print('verifiers: $verifiers');

      // Fetch pending verifier details from Firestore
      final List<Contact> pendingVerifiers =
          await Future.wait(pendingVerifierEmails.map((email) async {
        final verifierDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (verifierDoc.docs.isEmpty) return null;

        final verifierData = verifierDoc.docs.first.data();
        return Contact(
          name: verifierData['name'] as String? ?? 'Unknown User',
          phone: verifierData['phoneNumber'] as String? ?? '',
          isVerified: false,
        );
      })).then((list) => list.whereType<Contact>().toList());

      print('pendingVerifiers: $pendingVerifiers');

      _currentUser = User(
        name: firebaseUser.displayName ?? userData['name'] ?? '',
        email: firebaseUser.email ?? userData['email'] ?? '',
        phoneNumber: firebaseUser.phoneNumber ?? userData['phoneNumber'] ?? '',
        photoUrl: firebaseUser.photoURL ?? userData['photoUrl'],
        isVerified: firebaseUser.emailVerified,
        verifiers: verifiers,
        pendingVerifiers: pendingVerifiers,
      );
      await checkVerificationStatus();
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting user: $e');
      _currentUser = User(
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phoneNumber: firebaseUser.phoneNumber ?? '',
        photoUrl: firebaseUser.photoURL,
        isVerified: firebaseUser.emailVerified,
        verifiers: const [],
        pendingVerifiers: const [],
      );
      notifyListeners();
    }
  }

  Future<void> setUserWithData(
    firebase_auth.User firebaseUser,
    String name,
    String email,
  ) async {
    try {
      // Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final userData = userDoc.data() ?? {};

      // Get verifier emails
      final verifierEmails = (userData['verifiers'] as List<dynamic>? ?? [])
          .map((v) => v['email'] as String)
          .toList();

      // Get pending verifier emails
      final pendingVerifierEmails =
          (userData['pendingVerifiers'] as List<dynamic>? ?? [])
              .map((v) => v['email'] as String)
              .toList();

      // Fetch verifier details from Firestore
      final List<Contact> verifiers =
          await Future.wait(verifierEmails.map((email) async {
        final verifierDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (verifierDoc.docs.isEmpty) return null;

        final verifierData = verifierDoc.docs.first.data();
        return Contact(
          name: verifierData['name'] as String? ?? 'Unknown User',
          phone: verifierData['phoneNumber'] as String? ?? '',
          isVerified: true,
        );
      })).then((list) => list.whereType<Contact>().toList());

      // Fetch pending verifier details from Firestore
      final List<Contact> pendingVerifiers =
          await Future.wait(pendingVerifierEmails.map((email) async {
        final verifierDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (verifierDoc.docs.isEmpty) return null;

        final verifierData = verifierDoc.docs.first.data();
        return Contact(
          name: verifierData['name'] as String? ?? 'Unknown User',
          phone: verifierData['phoneNumber'] as String? ?? '',
          isVerified: false,
        );
      })).then((list) => list.whereType<Contact>().toList());

      _currentUser = User(
        name: name,
        email: email,
        phoneNumber: firebaseUser.phoneNumber ?? userData['phoneNumber'] ?? '',
        photoUrl: firebaseUser.photoURL ?? userData['photoUrl'],
        isVerified: firebaseUser.emailVerified,
        verifiers: verifiers,
        pendingVerifiers: pendingVerifiers,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting user with data: $e');
      _currentUser = User(
        name: name,
        email: email,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        photoUrl: firebaseUser.photoURL,
        isVerified: firebaseUser.emailVerified,
        verifiers: const [],
        pendingVerifiers: const [],
      );
      notifyListeners();
    }
  }

  void _handleFirebaseError(dynamic error) {
    _error = switch (error) {
      firebase_auth.FirebaseAuthException e when e.code == 'user-not-found' =>
        'No user found for that email.',
      firebase_auth.FirebaseAuthException e when e.code == 'wrong-password' =>
        'Wrong password provided.',
      firebase_auth.FirebaseAuthException e
          when e.code == 'email-already-in-use' =>
        'The email address is already in use.',
      firebase_auth.FirebaseAuthException e when e.code == 'invalid-email' =>
        'The email address is invalid.',
      firebase_auth.FirebaseAuthException e when e.code == 'weak-password' =>
        'The password provided is too weak.',
      _ => 'An error occurred. Please try again.',
    };
    notifyListeners();
  }

  Future<void> initializeRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig.setDefaults({
        'required_verifications': 1,
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error initializing remote config: $e');
    }
  }

  Future<void> checkVerificationStatus() async {
    if (_currentUser == null) return;

    final requiredVerifications =
        _remoteConfig.getInt('required_verifications');
    final currentVerifications = _currentUser!.verifiers.length;

    print('Required verifications: $requiredVerifications'); // Debug print
    print('Current verifications: $currentVerifications'); // Debug print

    if (currentVerifications >= requiredVerifications) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          // Update Firestore first
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'sponsorshipStatus': 'completed',
          });

          // After Firestore update succeeds, update local state
          if (context.mounted) {
            // Check if context is still valid
            final appState =
                Provider.of<AppStateProvider>(context, listen: false);
            print('Updating to completed status'); // Debug print
            appState.updateSponsorshipStatus(SponsorshipStatus.completed);
            appState.updateVerifiedSponsors(currentVerifications);
            print(
                'New sponsorship status: ${appState.sponsorshipStatus}'); // Debug print
          }
        }
      } catch (e) {
        debugPrint('Error updating sponsorship status: $e');
      }
    }
  }
}

class VehicleProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  Vehicle? _vehicle;
  bool _isLoading = false;

  Vehicle? get vehicle => _vehicle;
  bool get isLoading => _isLoading;

  Future<void> addVehicle(
      String model, String licensePlate, String color) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // Create vehicle document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vehicles')
          .add({
        'model': model,
        'licensePlate': licensePlate,
        'color': color,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _vehicle = Vehicle(
        model: model,
        licensePlate: licensePlate,
        color: color,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeVehicle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // Remove vehicle document from Firestore
      final vehiclesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vehicles');

      final vehicles = await vehiclesRef.get();
      if (vehicles.docs.isNotEmpty) {
        await vehiclesRef.doc(vehicles.docs.first.id).delete();
      }

      _vehicle = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVehicle(
      String model, String licensePlate, String color) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // Update vehicle document in Firestore
      final vehiclesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vehicles');

      final vehicles = await vehiclesRef.get();
      if (vehicles.docs.isNotEmpty) {
        await vehiclesRef.doc(vehicles.docs.first.id).update({
          'model': model,
          'licensePlate': licensePlate,
          'color': color,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _vehicle = Vehicle(
        model: model,
        licensePlate: licensePlate,
        color: color,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVehicle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final vehiclesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vehicles')
          .limit(1)
          .get();

      if (vehiclesSnapshot.docs.isNotEmpty) {
        final vehicleData = vehiclesSnapshot.docs.first.data();
        _vehicle = Vehicle(
          model: vehicleData['model'] as String,
          licensePlate: vehicleData['licensePlate'] as String,
          color: vehicleData['color'] as String,
        );
      } else {
        _vehicle = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class RideProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot>? _rideSubscription;
  Ride? _currentRide;
  StreamSubscription<QuerySnapshot>? _activeRidesSubscription;
  bool _isListening = false;

  Ride? get currentRide => _currentRide;

  Future<void> startRide({
    required User driver,
    required User passenger,
    required Vehicle vehicle,
  }) async {
    final rideRef = _firestore.collection('rides').doc();
    final rideData = {
      'driverId': driver.email,
      'driver': {
        'name': driver.name,
        'email': driver.email,
      },
      'passengerId': passenger.email,
      'passenger': {
        'name': passenger.name,
        'email': passenger.email,
      },
      'vehicle': {
        'model': vehicle.model,
        'licensePlate': vehicle.licensePlate,
        'color': vehicle.color,
      },
      'status': 'active',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await rideRef.set(rideData);
    _listenToRide(rideRef.id);
  }

  void _listenToRide(String rideId) {
    _rideSubscription?.cancel();
    _rideSubscription = _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data['status'] == 'completed') {
          _currentRide = null;
          // Navigate to home screen when ride is completed
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        } else {
          // Update the current ride state with complete user details
          _currentRide = Ride(
            id: snapshot.id,
            driver: User(
              name: data['driver']['name'] ?? '',
              email: data['driverId'],
              phoneNumber: data['driver']['phoneNumber'] ?? '',
              isVerified: true,
            ),
            passenger: User(
              name: data['passenger']['name'] ?? '',
              email: data['passengerId'],
              phoneNumber: data['passenger']['phoneNumber'] ?? '',
              isVerified: true,
            ),
            vehicle: Vehicle(
              model: data['vehicle']['model'],
              licensePlate: data['vehicle']['licensePlate'],
              color: data['vehicle']['color'],
            ),
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          );
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _isListening = false;
    _rideSubscription?.cancel();
    _activeRidesSubscription?.cancel();
    super.dispose();
  }

  Future<String> createQRSession(Vehicle vehicle) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    // Create a new ride session document
    final sessionRef = await _firestore.collection('ride_sessions').add({
      'driverId': user.uid,
      'vehicleId': vehicle.licensePlate, // Using license plate as vehicle ID
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
      'expiresAt': DateTime.now().add(const Duration(minutes: 5)),
    });

    // Create signature (in production, use proper crypto)
    final signature = base64Encode(utf8.encode('${user.uid}:${sessionRef.id}'));

    // Return encoded QR data
    final qrData = RideQRData(
      driverId: user.uid,
      vehicleId: vehicle.licensePlate,
      timestamp: DateTime.now(),
      signature: signature,
    );

    return json.encode(qrData.toJson());
  }

  Future<Map<String, Map<String, dynamic>?>> handleQRScan(String qrData) async {
    final data = RideQRData.fromJson(json.decode(qrData));

    // Verify timestamp (5 minute expiration)
    if (DateTime.now().difference(data.timestamp) >
        const Duration(minutes: 5)) {
      throw 'QR code has expired';
    }

    // Verify signature
    // In production, implement proper signature verification

    // Get driver and vehicle details
    final driverDoc =
        await _firestore.collection('users').doc(data.driverId).get();
    if (!driverDoc.exists) throw 'Driver not found';

    final vehiclesQuery = await _firestore
        .collection('users')
        .doc(data.driverId)
        .collection('vehicles')
        .where('licensePlate', isEqualTo: data.vehicleId)
        .get();

    if (vehiclesQuery.docs.isEmpty) throw 'Vehicle not found';

    // Return driver and vehicle details for confirmation screen
    return {
      'driver': driverDoc.data(),
      'vehicle': vehiclesQuery.docs.first.data(),
    };
  }

  Future<void> endRide() async {
    if (_currentRide != null) {
      await _firestore.collection('rides').doc(_currentRide!.id).update({
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
      });
      _currentRide = null;
      notifyListeners();
    }
  }

  Future<void> checkForActiveRide() async {
    if (_isListening) return;
    _isListening = true;

    final user = _auth.currentUser;
    if (user == null) return;

    _activeRidesSubscription?.cancel();

    _activeRidesSubscription = _firestore
        .collection('rides')
        .where('driverId', isEqualTo: user.email)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _listenToRide(snapshot.docs.first.id);
      }
    });
  }

  Future<List<Ride>> fetchRideHistory() async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    final snapshot = await _firestore
        .collection('rides')
        .where('status', isEqualTo: 'completed')
        .where(Filter.or(
          Filter('driverId', isEqualTo: user.email),
          Filter('passengerId', isEqualTo: user.email),
        ))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Ride(
        id: doc.id,
        driver: User(
          name: data['driver']['name'],
          email: data['driverId'],
          phoneNumber: data['driver']['phoneNumber'] ?? '',
          isVerified: true,
        ),
        passenger: User(
          name: data['passenger']['name'],
          email: data['passengerId'],
          phoneNumber: data['passenger']['phoneNumber'] ?? '',
          isVerified: true,
        ),
        vehicle: Vehicle(
          model: data['vehicle']['model'],
          licensePlate: data['vehicle']['licensePlate'],
          color: data['vehicle']['color'],
        ),
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
  }
}

class AppStateProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  SponsorshipStatus _sponsorshipStatus = SponsorshipStatus.notStarted;
  int _verifiedSponsors = 0;
  int _pendingSponsors = 0;
  bool _hasCompletedProfile = false;

  AppStateProvider() {
    print('Initializing AppStateProvider'); // Debug print
    // Listen to auth state changes to update email verification status
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      if (user != null) {
        // Fetch initial sponsorship status from Firestore
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((doc) {
          if (doc.exists) {
            final status = doc.data()?['sponsorshipStatus'] as String?;
            print('Initial Firestore status: $status'); // Debug print
            if (status == 'completed') {
              _sponsorshipStatus = SponsorshipStatus.completed;
            } else if (status == 'pending') {
              _sponsorshipStatus = SponsorshipStatus.pending;
            } else {
              _sponsorshipStatus = SponsorshipStatus.notStarted;
            }
            notifyListeners();
          }
        });
      }
      notifyListeners();
    });

    // Listen to user changes (including email verification status changes)
    _auth.userChanges().listen((firebase_auth.User? user) {
      notifyListeners();
    });
  }

  SponsorshipStatus get sponsorshipStatus {
    print('Getting sponsorship status: $_sponsorshipStatus'); // Debug print
    return _sponsorshipStatus;
  }
  
  int get verifiedSponsors => _verifiedSponsors;
  int get pendingSponsors => _pendingSponsors;
  bool get hasCompletedProfile => _hasCompletedProfile;

  // Get email verification status directly from Firebase
  bool get isEmailVerified {
    final user = _auth.currentUser;
    final verified = user?.emailVerified ?? false;
    print('Email verified: $verified'); // Debug print
    return verified;
  }

  // Combined verification status
  bool get isFullyVerified {
    final result =
        _sponsorshipStatus == SponsorshipStatus.completed && isEmailVerified;
    print(
        'isFullyVerified: $result (status: $_sponsorshipStatus, email: ${isEmailVerified})'); // Debug print
    return result;
  }

  bool get canUseApp => isFullyVerified;

  void updateSponsorshipStatus(SponsorshipStatus status) {
    print(
        'Updating sponsorship status from: $_sponsorshipStatus to: $status'); // Debug print
    _sponsorshipStatus = status;
    print('Status updated. New status: $_sponsorshipStatus'); // Debug print
    notifyListeners();
  }

  void updateVerifiedSponsors(int count) {
    print('Updating verified sponsors count: $count'); // Debug print
    _verifiedSponsors = count;
    notifyListeners();
  }

  void updatePendingSponsors(int count) {
    _pendingSponsors = count;
    notifyListeners();
  }

  void setProfileComplete(bool complete) {
    _hasCompletedProfile = complete;
    notifyListeners();
  }

  Future<void> requestVerification(List<String> contactPhones) async {
    _pendingSponsors = contactPhones.length;
    _sponsorshipStatus = SponsorshipStatus.pending;
    notifyListeners();
  }

  // Method to manually refresh the email verification status
  Future<void> refreshEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing email verification status: $e');
    }
  }
}

class LocaleProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  void setLocale(Locale newLocale) {
    if (newLocale != _currentLocale) {
      _currentLocale = newLocale;
      notifyListeners();
    }
  }
}

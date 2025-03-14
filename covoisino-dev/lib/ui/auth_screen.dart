// auth_screens_part1.dart
import 'dart:async';

import 'package:covoisino/core/localization.dart';
import 'package:covoisino/main.dart';
import 'package:covoisino/ui/home_screen.dart';
import 'package:covoisino/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_theme.dart';
import '../core/providers.dart';
import '../core/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const LanguageSelector().animate(
                effects: [
                  FadeEffect(
                    delay: const Duration(milliseconds: 100),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                l10n.get('welcome_to'),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ).animate(
                effects: [
                  FadeEffect(duration: const Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: const Offset(-0.2, 0),
                    end: const Offset(0, 0),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.get('community_driven_rides'),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ).animate(
                effects: [
                  FadeEffect(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                  ),
                  SlideEffect(
                    begin: const Offset(-0.2, 0),
                    end: const Offset(0, 0),
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              AsyncButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                child: Text(
                  l10n.get('get_started'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    l10n.get('already_have_account'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate(
                effects: [
                  FadeEffect(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<AppAuthProvider>(
      builder: (context, appAuth, _) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const LanguageSelector().animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.get('welcome_back'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(duration: const Duration(milliseconds: 600)),
                      SlideEffect(
                        begin: const Offset(-0.2, 0),
                        end: const Offset(0, 0),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.get('continue_journey'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                      ),
                      SlideEffect(
                        begin: const Offset(-0.2, 0),
                        end: const Offset(0, 0),
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Social login buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleGoogleLogin(appAuth),
                          icon: const Icon(Icons.account_circle_sharp),
                          label: Text(l10n.get('google')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.get('or'),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 500),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  CustomTextFormField(
                    controller: _emailController,
                    labelText: l10n.get('email'),
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_email');
                      }
                      if (!value!.contains('@')) {
                        return l10n.get('please_enter_valid_email');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: l10n.get('password'),
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_password');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: Text(
                        l10n.get('forgot_password'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 800),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  AsyncButton(
                    onPressed: () => _handleLogin(appAuth),
                    child: Text(
                      l10n.get('login'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.get('dont_have_account'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        ),
                        child: Text(
                          l10n.get('signup'),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 1000),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AppAuthProvider appAuth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (credential.user != null) {
        // Fetch user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          await appAuth.setUserWithData(
            credential.user!,
            userData['name'] as String,
            userData['email'] as String,
          );

          // Explicitly fetch vehicle data
          if (!mounted) return;
          final vehicleProvider =
              Provider.of<VehicleProvider>(context, listen: false);
          await vehicleProvider.fetchVehicle();
        } else {
          await appAuth.setUser(credential.user!);
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on auth.FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = l10n.get('no_user_found');
          break;
        case 'wrong-password':
          errorMessage = l10n.get('wrong_password');
          break;
        case 'user-disabled':
          errorMessage = l10n.get('account_disabled');
          break;
        default:
          errorMessage = e.message ?? l10n.get('login_failed');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _handleGoogleLogin(AppAuthProvider appAuth) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create user document if it doesn't exist
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': userCredential.user!.displayName ?? '',
            'email': userCredential.user!.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        final userData = userDoc.exists
            ? userDoc.data()!
            : {
                'name': userCredential.user!.displayName ?? '',
                'email': userCredential.user!.email ?? '',
              };

        await appAuth.setUserWithData(
          userCredential.user!,
          userData['name'] as String,
          userData['email'] as String,
        );

        // Explicitly fetch vehicle data
        if (!mounted) return;
        final vehicleProvider =
            Provider.of<VehicleProvider>(context, listen: false);
        await vehicleProvider.fetchVehicle();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${l10n.get('google_signin_failed')}: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  String? _photoUrl;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<AppAuthProvider>(
      builder: (context, auth, _) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const LanguageSelector().animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.get('create_account'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(duration: const Duration(milliseconds: 600)),
                      SlideEffect(
                        begin: const Offset(-0.2, 0),
                        end: const Offset(0, 0),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.get('join_community'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                      ),
                      SlideEffect(
                        begin: const Offset(-0.2, 0),
                        end: const Offset(0, 0),
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Profile photo
                  Center(
                    child: GestureDetector(
                      onTap: () => choosePhoto(
                        context,
                        (url) => setState(() => _photoUrl = url),
                      ),
                      child: Hero(
                        tag: 'profile_photo',
                        child: displayPhoto(
                          _photoUrl ?? '',
                          size: 120,
                        ),
                      ),
                    ),
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                      ),
                      ScaleEffect(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Form fields
                  CustomTextFormField(
                    controller: _nameController,
                    labelText: l10n.get('full_name'),
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_name');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _emailController,
                    labelText: l10n.get('email'),
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_email');
                      }
                      if (!value!.contains('@')) {
                        return l10n.get('please_enter_valid_email');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _phoneController,
                    labelText: l10n.get('phone_number'),
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_phone');
                      }
                      final phoneRegExp = RegExp(r'^\+?[\d\s-]{8,}$');
                      if (!phoneRegExp.hasMatch(value!)) {
                        return l10n.get('invalid_phone');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: l10n.get('password'),
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_password');
                      }
                      if (value!.length < 6) {
                        return l10n.get('password_min_length');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),
                  AsyncButton(
                    onPressed: () => _handleSignUp(auth),
                    child: Text(
                      l10n.get('create_account'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.get('or'),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 500),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  // Google sign-up
                  ElevatedButton.icon(
                    onPressed: () => _handleGoogleSignUp(auth),
                    icon: const Icon(Icons.account_circle_sharp),
                    label: Text(l10n.get('continue_with_google')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

                  const SizedBox(height: 24),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.get('already_have_account'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: Text(
                          l10n.get('login'),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate(
                    effects: [
                      FadeEffect(
                        delay: const Duration(milliseconds: 1000),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignUp(AppAuthProvider appAuth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await appAuth.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _phoneController.text,
      );
      
      if (!mounted) return;
      
      // Navigate to email verification screen instead of home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: _emailController.text,
          ),
        ),
      );
    } on auth.FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      String errorMessage;

      switch (e.code) {
        case 'weak-password':
          errorMessage = l10n.get('weak_password');
          break;
        case 'email-already-in-use':
          errorMessage = l10n.get('email_already_exists');
          break;
        case 'invalid-email':
          errorMessage = l10n.get('invalid_email');
          break;
        default:
          errorMessage = e.message ?? l10n.get('signup_failed');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _handleGoogleSignUp(AppAuthProvider appAuth) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (!mounted) return;
      if (userCredential.user != null) {
        await appAuth.setUser(userCredential.user!);
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${l10n.get('google_signup_failed')}: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  Timer? _timer;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    // Start verification check timer
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    // Reload user data
    await _auth.currentUser?.reload();

    setState(() {
      _isVerified = _auth.currentUser?.emailVerified ?? false;
    });

    if (_isVerified) {
      _timer?.cancel();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<AppAuthProvider>(
      builder: (context, auth, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.get('verify_email'))),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.get('check_email'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ).animate()
                .fade()
                .move(begin: const Offset(-20, 0)),
            const SizedBox(height: 12),
            Text(
              '${l10n.get('verification_email_sent')}${widget.email}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ).animate()
                .fade(delay: const Duration(milliseconds: 200))
                .move(begin: const Offset(-20, 0)),
            const SizedBox(height: 32),
            AsyncButton(
              onPressed: () async {
                try {
                  await _auth.currentUser?.sendEmailVerification();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.get('verification_email_resent'))),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${l10n.get('error')}${e.toString()}')),
                  );
                }
              },
              child: Text(
                l10n.get('resend_verification_email'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ).animate()
                .fade(delay: const Duration(milliseconds: 600))
                .scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<AppAuthProvider>(
      builder: (context, auth, _) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.get('reset_password')),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                l10n.get('forgot_password'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).animate(
                effects: [
                  FadeEffect(duration: const Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: const Offset(-0.2, 0),
                    end: const Offset(0, 0),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.get('enter_email_reset'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ).animate(
                effects: [
                  FadeEffect(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                  ),
                  SlideEffect(
                    begin: const Offset(-0.2, 0),
                    end: const Offset(0, 0),
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomTextFormField(
                controller: _emailController,
                labelText: l10n.get('email'),
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.get('please_enter_email');
                  }
                  if (!value!.contains('@')) {
                    return l10n.get('please_enter_valid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              AsyncButton(
                onPressed: () => _handleResetPassword(auth),
                child: Text(
                  l10n.get('send_reset_link'),
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
      ),
    );
  }

  Future<void> _handleResetPassword(AppAuthProvider appAuth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.get('reset_link_sent')),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } on auth.FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = l10n.get('no_user_found');
          break;
        case 'invalid-email':
          errorMessage = l10n.get('invalid_email');
          break;
        default:
          errorMessage = e.message ?? l10n.get('reset_password_failed');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
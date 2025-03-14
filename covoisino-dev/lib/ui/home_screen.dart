// home.dart
import 'package:covoisino/core/localization.dart';
import 'package:covoisino/main.dart';
import 'package:covoisino/ui/auth_screen.dart';
import 'package:covoisino/ui/history_screen.dart';
import 'package:covoisino/ui/ride_screen.dart';
import 'package:covoisino/core/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../core/providers.dart';
import '../core/models.dart';
import '../core/widgets.dart';

// HomeScreen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer2<AppStateProvider, VehicleProvider>(
      builder: (context, appState, vehicleState, _) {
        print(
            'Rebuilding HomeScreen - Sponsorship Status: ${appState.sponsorshipStatus}'); // Debug print
        final canUseApp = appState.canUseApp;
        final vehicle = vehicleState.vehicle;

        void handleQRCodeAction(bool isScanning) {
          if (!appState.canUseApp) {
            _showSponsorshipRequired(context);
            return;
          }

          if (!isScanning && vehicle == null) {
            _showVehicleRequired(context);
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  isScanning ? const QRScanScreen() : const QRDisplayScreen(),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Profile header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Consumer<AppAuthProvider>(
                    builder: (context, auth, _) => GestureDetector(
                      onTap: () => _showProfileMenu(context),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'profile_photo',
                            child: displayPhoto(
                                auth.currentUser?.photoUrl ?? '',
                              size: 60,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.currentUser?.name ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildVerificationStatus(context),
                              ],
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
                      begin: const Offset(-0.2, 0),
                      end: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                    ),
                  ],
                ),
                // Main content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Passenger section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.7),
                              AppColors.primary.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.get('need_ride'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.get('connect_drivers'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AsyncButton(
                              onPressed: () async => handleQRCodeAction(true),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.get('scan_qr'),
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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

                      const SizedBox(height: 24),

                      // Driver section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withOpacity(0.1),
                              AppColors.secondary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.get('want_help'),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                if (vehicle == null)
                                  TextButton.icon(
                                    onPressed: () => _showAddVehicle(context),
                                    icon: const Icon(Icons.add),
                                    label: Text(l10n.get('add_vehicle')),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.secondary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              vehicle == null
                                  ? l10n.get('add_vehicle_subtitle')
                                  : l10n.get('show_qr_subtitle'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            if (vehicle != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.directions_car_outlined,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${vehicle.color} ${vehicle.model}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          vehicle.licensePlate,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            AsyncButton(
                              onPressed: () async => handleQRCodeAction(false),
                              color: AppColors.secondary,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.qr_code,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.get('show_qr'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate(
                        effects: [
                          FadeEffect(
                            delay: const Duration(milliseconds: 600),
                            duration: const Duration(milliseconds: 600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        print(
            'Building verification status - Status: ${appState.sponsorshipStatus}');

        late final Color backgroundColor;
        late final Color textColor;
        late final IconData icon;
        late final String text;

        if (appState.isFullyVerified) {
          backgroundColor = Colors.green[50]!;
          textColor = Colors.green[700]!;
          icon = Icons.verified;
          text = l10n.get('verified_member');
        } else if (appState.sponsorshipStatus == SponsorshipStatus.pending) {
          backgroundColor = Colors.orange[50]!;
          textColor = Colors.orange[700]!;
          icon = Icons.pending;
          text = l10n.get('pending_verification');
        } else {
          backgroundColor = Colors.grey[100]!;
          textColor = Colors.grey[700]!;
          icon = Icons.verified_user_outlined;
          text = l10n.get('not_verified_yet');
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: textColor,
              ),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSponsorshipRequired(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.verified_user_outlined,
                size: 48,
                color: Colors.amber[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('verification_required'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('verification_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            AsyncButton(
              onPressed: () async {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddVerifierSheet(isInitialSetup: false),
                );
              },
              child: Text(
                l10n.get('get_verified'),
                style: const TextStyle(
                  fontSize: 16,
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
  void _showVehicleRequired(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 48,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('vehicle_required'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('vehicle_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            AsyncButton(
              onPressed: () async {
                Navigator.pop(context);
                _showAddVehicle(context);
              },
              color: AppColors.secondary,
              child: Text(
                l10n.get('add_vehicle'),
                style: const TextStyle(
                  fontSize: 16,
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

  void _showAddVehicle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddVehicleSheet(),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileMenuSheet(),
    );
  }
}

// ProfileMenuSheet
class ProfileMenuSheet extends StatelessWidget {
  const ProfileMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Consumer3<AppAuthProvider, AppStateProvider, VehicleProvider>(
        builder: (context, auth, appState, vehicleState, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuItem(
                icon: Icons.person_outline,
                title: l10n.get('edit_profile'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditProfile(context);
                },
              ),
              if (vehicleState.vehicle != null)
                _buildMenuItem(
                  icon: Icons.directions_car_outlined,
                  title: l10n.get('update_vehicle'),
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const AddVehicleSheet(),
                    );
                  },
                ),
              _buildMenuItem(
                icon: Icons.verified_user_outlined,
                title: l10n.get('sponsorship_status'),
                color: appState.canUseApp ? Colors.green : null,
                trailing: appState.canUseApp
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.get('verified'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const VerificationStatusSheet(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.get('language'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 140,
                      child: Consumer<LocaleProvider>(
                        builder: (context, localeProvider, _) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: localeProvider.currentLocale.languageCode,
                              icon: const Icon(Icons.arrow_drop_down),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: 'fr',
                                  child: Text('Français'),
                                ),
                              ],
                              onChanged: (String? value) {
                                if (value != null) {
                                  localeProvider.setLocale(Locale(value));
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              _buildMenuItem(
                icon: Icons.history,
                title: l10n.get('ride_history'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RideHistoryScreen()),
                ),
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                icon: Icons.logout,
                title: l10n.get('sign_out'),
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showSignOutConfirmation(context, auth);
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        },
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
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color ?? AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context, AppAuthProvider auth) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(l10n.get('sign_out')),
        content: Text(l10n.get('sign_out_confirm')),
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
              await auth.logout();
              if (!context.mounted) return;
              
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              l10n.get('sign_out'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditProfileSheet(),
    );
  }
}

// EditProfileSheet
class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppAuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _photoUrl = user?.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.get('edit_profile'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                      ),
                      ScaleEffect(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
                    enabled: false,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_email');
                      }
                      if (!value!.contains('@')) {
                        return l10n.get('please_valid_email');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Email Verification Section
                  Consumer2<AppAuthProvider, AppStateProvider>(
                    builder: (context, auth, appState, _) {
                      final isEmailVerified = appState.isEmailVerified;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isEmailVerified
                              ? Colors.green.withOpacity(0.1)
                              : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isEmailVerified
                                      ? Icons.verified_user
                                      : Icons.mark_email_unread,
                                  color: isEmailVerified
                                      ? Colors.green[700]
                                      : Colors.amber[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isEmailVerified
                                      ? l10n.get('email_verified')
                                      : l10n.get('email_verification_required'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isEmailVerified
                                        ? Colors.green[700]
                                        : Colors.amber[700],
                                  ),
                                ),
                              ],
                            ),
                            if (!isEmailVerified) ...[
                              const SizedBox(height: 12),
                              Text(
                                l10n.get('verify_email_description'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              AsyncButton(
                                onPressed: () async {
                                  try {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    await user?.sendEmailVerification();
                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n
                                            .get('verification_email_sent')),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${l10n.get('error')}${e.toString()}'),
                                      ),
                                    );
                                  }
                                },
                                color: Colors.amber[700],
                                child: Text(
                                  l10n.get('send_verification_email'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  Consumer<AppAuthProvider>(
                    builder: (context, auth, _) => AsyncButton(
                      onPressed: () => _handleSubmit(auth),
                      child: Text(
                        l10n.get('save_changes'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
    );
  }

  Future<void> _handleSubmit(AppAuthProvider auth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await auth.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        photoUrl: _photoUrl,
      );

      if (!mounted) return;

      Navigator.pop(context);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.get('profile_updated')),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context).get('error')}${e.toString()}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

// AddVehicleSheet
class AddVehicleSheet extends StatefulWidget {
  const AddVehicleSheet({super.key});

  @override
  State<AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  Color _selectedColor = Colors.black;

  final List<Color> _availableColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.grey,
    Colors.brown,
    const Color(0xFFE0E0E0), // Silver
    const Color(0xFFF5F5F5), // Pearl White
  ];

  final Map<Color, String> _colorNames = {
    Colors.black: 'Black',
    Colors.white: 'White',
    Colors.red: 'Red',
    Colors.blue: 'Blue',
    Colors.green: 'Green',
    Colors.grey: 'Grey',
    Colors.brown: 'Brown',
    const Color(0xFFE0E0E0): 'Silver',
    const Color(0xFFF5F5F5): 'Pearl White',
  };

  @override
  void initState() {
    super.initState();
    final vehicle = context.read<VehicleProvider>().vehicle;
    if (vehicle != null) {
      _modelController.text = vehicle.model;
      _plateController.text = vehicle.licensePlate;
      _selectedColor = _availableColors.firstWhere(
        (color) =>
            _colorNames[color]?.toLowerCase() == vehicle.color.toLowerCase(),
        orElse: () => Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer<VehicleProvider>(
                    builder: (context, vehicle, _) => Text(
                      vehicle.vehicle == null
                          ? l10n.get('add_vehicle')
                          : l10n.get('update_vehicle'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextFormField(
                    controller: _modelController,
                    labelText: l10n.get('vehicle_model'),
                    prefixIcon: Icons.directions_car_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_vehicle');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _plateController,
                    labelText: l10n.get('license_plate'),
                    prefixIcon: Icons.pin_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.get('please_enter_plate');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.get('vehicle_color'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableColors.map((color) {
                      final isSelected = color == _selectedColor;
                      final isLightColor = color.computeLuminance() > 0.5;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : isLightColor
                                      ? Colors.grey[300]!
                                      : Colors.white,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: isLightColor
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.get('selected_color')}${_colorNames[_selectedColor] ?? "Black"}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<VehicleProvider>(
                    builder: (context, vehicle, _) => AsyncButton(
                      onPressed: () => _handleSubmit(context, vehicle),
                      child: Text(
                        vehicle.vehicle == null
                            ? l10n.get('add_vehicle')
                            : l10n.get('update_vehicle'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
    );
  }

  Future<void> _handleSubmit(BuildContext context, VehicleProvider vehicle) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final colorName = _colorNames[_selectedColor]!;
      final l10n = AppLocalizations.of(context);
      
      if (vehicle.vehicle == null) {
        await vehicle.addVehicle(
          _modelController.text,
          _plateController.text,
          colorName,
        );
      } else {
        await vehicle.updateVehicle(
          _modelController.text,
          _plateController.text,
          colorName,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vehicle.vehicle == null
                ? l10n.get('vehicle_added')
                : l10n.get('vehicle_updated'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.get('error')}${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }
}

// VerificationStatusSheet
class VerificationStatusSheet extends StatelessWidget {
  const VerificationStatusSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<AppAuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser!;
        final verifiers = user.verifiers;
        final pendingRequests = user.pendingVerifiers;
        final bool hasNoVerifications =
            verifiers.isEmpty && pendingRequests.isEmpty;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.get('verification_status'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (hasNoVerifications) ...[
                      Center(
                        child: Text(
                          l10n.get('not_verified_yet'),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (verifiers.isNotEmpty) ...[
                      Text(
                        l10n.get('verified_by'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...verifiers.map((verifier) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.verified_user,
                                    color: Colors.green[700],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        verifier.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        verifier.phone,
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
                          )),
                    ],
                    if (pendingRequests.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        l10n.get('pending_requests'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...pendingRequests.map((request) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.hourglass_empty,
                                    color: Colors.amber[700],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        request.phone,
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
                          ))
                    ],
                    const SizedBox(height: 24),
                    AsyncButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AddVerifierSheet(),
                        );
                      },
                      child: Text(
                        l10n.get('request_verifications'),
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
            ],
          ),
        );
      },
    );
  }
}

// widgets.dart
import 'package:covoisino/core/localization.dart';
import 'package:covoisino/core/models.dart';
import 'package:covoisino/core/providers.dart';
import 'package:covoisino/main.dart';
import 'package:covoisino/ui/auth_screen.dart';
import 'package:covoisino/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// AsyncButton Widget
class AsyncButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final Color? color;

  const AsyncButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  });

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color ?? Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : widget.child,
    ).animate(
      effects: [
        FadeEffect(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
        ScaleEffect(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      ],
    );
  }

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// CustomTextFormField Widget
class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool readOnly;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  Color _getIconColor() {
    if (!widget.enabled) return Colors.grey[400]!;
    return _isFocused ? AppColors.primary : Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      style: TextStyle(
        color: widget.enabled ? Colors.black : Colors.grey[600],
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: widget.enabled
              ? (_isFocused ? AppColors.primary : Colors.grey[600])
              : Colors.grey[400],
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: _getIconColor(),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: widget.enabled ? Colors.white : Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: widget.enabled ? AppColors.primary : Colors.grey[400]!,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ).animate(
      effects: [
        FadeEffect(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
        ScaleEffect(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
}
// AddVerifierSheet Widget
class AddVerifierSheet extends StatefulWidget {
  final bool isInitialSetup;

  const AddVerifierSheet({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  State<AddVerifierSheet> createState() => _AddVerifierSheetState();
}

class _AddVerifierSheetState extends State<AddVerifierSheet> {
  final Set<String> _selectedContacts = {};
  bool _isLoading = true;
  List<User> _users = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw 'User not authenticated';

      // Get current user's document to check verifiers and pending requests
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final currentUserData = currentUserDoc.data();

      // Extract emails of existing verifiers and pending requests
      final verifierEmails =
          (currentUserData?['verifiers'] as List<dynamic>? ?? [])
              .map((v) => v['email'] as String)
              .toSet();

      final pendingEmails =
          (currentUserData?['pendingVerifiers'] as List<dynamic>? ?? [])
              .map((v) => v['email'] as String)
              .toSet();

      // Combine both sets
      final excludedEmails = {
        ...verifierEmails,
        ...pendingEmails,
        currentUser.email
      };

      // Fetch users excluding current user and existing verifiers/pending
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereNotIn: excludedEmails.toList())
          .get();

      setState(() {
        _users = usersSnapshot.docs.map((doc) {
          final data = doc.data();
          return User(
            name: data['name'] as String? ?? 'Unknown User',
            email: data['email'] as String? ?? '',
            phoneNumber: data['phoneNumber'] as String? ?? '',
            isVerified: true,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendVerificationRequests(List<String> emails) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Add to pending verifiers in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'pendingVerifiers': emails
            .map((email) => {
                  'email': email,
                  'requestedAt': DateTime.now().toIso8601String()
                })
            .toList(),
      });

      // Send verification emails through Netlify Function
      for (final email in emails) {
        final response = await http.post(
          Uri.parse(
              'https://covoisino.netlify.app/.netlify/functions/sendVerificationEmail'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sponsorEmail': email,
            'userId': currentUser.uid,
            'userName': currentUser.displayName ?? 'Unknown User',
          }),
        );

        if (response.statusCode != 200) {
          throw Exception(
              'Failed to send verification email: ${response.body}');
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.get('failed_send_verification')}$e')),
      );
    }
  }

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
                  widget.isInitialSetup ? 'Get Verified' : 'Select Contacts',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.get('not_verified_yet'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Error: $_error',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        TextButton(
                          onPressed: _fetchUsers,
                          child: Text(l10n.get('retry')),
                        ),
                      ],
                    ),
                  )
                else if (_users.isEmpty)
                  Center(
                    child: Text(
                      'No users available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isSelected = _selectedContacts.contains(user.email);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value ?? false) {
                                    _selectedContacts.add(user.email);
                                  } else {
                                    _selectedContacts.remove(user.email);
                                  }
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
                AsyncButton(
                  onPressed: () async {
                    if (_selectedContacts.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.get('please_select_contact')),
                        ),
                      );
                      return;
                    }

                    await _sendVerificationRequests(_selectedContacts.toList());
                  },
                  child: Text(
                    'Send ${_selectedContacts.length} Request${_selectedContacts.length != 1 ? 's' : ''}',
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
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: localeProvider.currentLocale.languageCode,
            icon: const Icon(Icons.language),
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Text('🇬🇧 '),
                    Text('English'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'fr',
                child: Row(
                  children: [
                    const Text('🇫🇷 '),
                    Text('Français'),
                  ],
                ),
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
    );
  }
}

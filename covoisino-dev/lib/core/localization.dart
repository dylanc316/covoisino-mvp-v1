// lib/core/localization.dart

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Onboarding & Auth
      'welcome_to': 'Welcome to\nCovoisino',
      'community_driven_rides': 'Community-driven rides with trusted neighbors',
      'get_started': 'Get Started',
      'already_have_account': 'Already have an account?',
      'welcome_back': 'Welcome\nBack!',
      'continue_journey': 'Continue your journey with trusted neighbors',
      'login': 'Login',
      'signup': 'Sign Up',
      'create_account': 'Create\nAccount',
      'join_community': 'Join our trusted community',
      'or_continue_with': 'or continue with',
      'dont_have_account': 'Don\'t have an account? ',
      'forgot_password': 'Forgot Password?',
      'reset_password': 'Reset Password',
      'enter_email_reset': 'Enter your email to receive a reset link',
      'send_reset_link': 'Send Reset Link',
      'reset_link_sent': 'Reset link sent to your email',

      // Form Fields & Validation
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'verification_code': 'Verification Code',
      'please_enter_email': 'Please enter your email',
      'please_enter_valid_email': 'Please enter a valid email',
      'please_enter_password': 'Please enter your password',
      'please_enter_name': 'Please enter your name',
      'password_min_length': 'Password must be at least 6 characters',
      
      // Email Verification
      'verify_email': 'Verify Email',
      'check_email': 'Check your email',
      'enter_verification_code': 'Enter the verification code sent to ',
      'verify_email_button': 'Verify Email',
      "email_verification_required": "Email Verification Required",
      "email_verified": "Email Verified",
      "verify_email_description":
          "Please verify your email address to fully access all features.",
      "send_verification_email": "Send Verification Email",
      "verification_email_sent": "Verification email has been sent",
      "email_verification_pending": "Email verification pending",
      "email_and_sponsorship_required":
          "Email verification and sponsorship required",
      "verification_complete": "Verification complete",
      "please_verify_email": "Please verify your email to continue",
      "check_inbox": "Check your inbox for the verification link",
      
      // Buttons & Actions
      'continue_with_google': 'Continue with Google',
      'google': 'Google',
      'cancel': 'Cancel',
      'back': 'Back',
      'or': 'or',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm': 'Confirm',

      // Profile & Account
      'profile': 'Profile',
      'account_settings': 'Account Settings',
      'edit_profile': 'Edit Profile',
      'verified_member': 'Verified Member',
      'change_photo': 'Change Photo',
      'remove_photo': 'Remove Photo',
      
      // QR Scan Screen
      'scan_qr_code': 'Scan QR Code',
      'position_qr': 'Position the QR code within the frame',
      'simulate_scan': 'Simulate Scan',
      
      // QR Display Screen
      'your_qr_code': 'Your QR Code',
      'show_to_passengers': 'Show this to passengers to start the ride',
      'simulate_passenger_scan': 'Simulate Passenger Scan',
      
      // Ride Confirmation
      'new_passenger': 'New Passenger',
      'confirm_ride': 'Confirm Ride',
      'vehicle_details': 'Vehicle Details',
      'safety_check': 'Safety Check',
      'verify_passenger': 'Verify that the passenger matches their profile picture before accepting.',
      'verify_driver': 'Verify the driver and vehicle details match before starting your ride.',
      'accept_ride': 'Accept Ride',
      'start_ride': 'Start Ride',
      
      // Ride Screen
      'emergency': 'EMERGENCY',
      'end_ride': 'End Ride',
      'end_ride_confirmation': 'Are you sure you want to end this ride?',
      
      // Emergency Screen
      'emergency_services': 'Emergency Services',
      'get_assistance': 'Get immediate assistance',
      'emergency_actions': 'Emergency Actions',
      'call_emergency': 'Call Emergency Services',
      'connect_responders': 'Connect with emergency responders',
      'share_location': 'Share Location',
      'send_location': 'Send your current location',
      'back_to_safety': 'Back to Safety',
      'call_confirmation': 'Do you want to call emergency services (112)?',
      'sharing_location': 'Sharing location with emergency services...',
      'could_not_launch_call': 'Could not launch emergency call',
      'location_permission_denied': 'Location permission denied',
      'location_permissions_permanently_denied': 'Location permissions are permanently denied, please enable them in settings',
      'settings': 'Settings',
      'emergency_message': 'EMERGENCY: I need help with my ride!',
      'my_location': 'My current location',
      'emergency_location_share': 'Emergency Location Share',
      'location_shared_successfully': 'Location shared successfully',
      
      // Messages & Errors
      'error': 'Error: ',
      'success': 'Success!',
      'warning': 'Warning',
      'info': 'Information',
      'loading': 'Loading...',
      'please_wait': 'Please wait...',
      'try_again': 'Try Again',
      'something_went_wrong': 'Something went wrong',
      'no_internet': 'No internet connection',
      'connection_error': 'Connection error',
      'invalid_credentials': 'Invalid email or password',
      'session_expired': 'Session expired. Please login again',

      // Home screen
      'need_ride': 'Need a ride?',
      'connect_drivers': 'Connect with trusted drivers',
      'scan_qr': 'Scan QR Code',
      'want_help': 'Want to help?',
      'add_vehicle': 'Add Vehicle',
      'add_vehicle_subtitle': 'Add your vehicle details to start driving',
      'show_qr_subtitle': 'Show your QR code to passengers',
      'show_qr': 'Show QR Code',
      'pending_verification': 'Pending Verification',
      'update_vehicle': 'Update Vehicle',
      'sponsorship_status': 'Sponsorship Status',
      'verified': 'Verified',
      'language': 'Language',
      'sign_out': 'Sign Out',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      'verification_required': 'Verification Required',
      'verification_subtitle':
          'Get verified by trusted members to use this feature',
      'get_verified': 'Get Verified',
      'vehicle_required': 'Vehicle Required',
      'vehicle_subtitle': 'Add your vehicle details to start accepting rides',
      'vehicle_model': 'Vehicle Model',
      'license_plate': 'License Plate',
      'vehicle_color': 'Vehicle Color',
      'please_enter_vehicle': 'Please enter vehicle model',
      'please_enter_plate': 'Please enter license plate',
      'selected_color': 'Selected: ',
      'save_changes': 'Save Changes',
      'profile_updated': 'Profile updated successfully',
      'vehicle_added': 'Vehicle added successfully',
      'vehicle_updated': 'Vehicle updated successfully',
      'please_valid_email': 'Please enter a valid email',

      // Verification Status Sheet
      'verification_status': 'Verification Status',
      'verified_by': 'Verified By',
      'pending_requests': 'Pending Requests',
      'request_verifications': 'Request More Verifications',

      // Ride screen
      'initiating_emergency_call': 'Initiating emergency call...',
      'call': 'Call',

      // Email Verification
      'verification_email_resent': 'Verification email has been resent',
      'resend_verification_email': 'Resend Verification Email',
      'email_not_verified': 'Please verify your email to continue',

      // Firebase Auth Errors
      'weak_password': 'Password is too weak. Please use at least 6 characters',
      'email_already_exists': 'An account already exists with this email',
      'invalid_email': 'Please enter a valid email address',
      'wrong_password': 'Incorrect password',
      'user_not_found': 'No account found with this email',
      'signup_failed': 'Failed to create account',
      'login_failed': 'Login failed',
      'google_signin_failed': 'Google sign-in failed',
      'google_signup_failed': 'Google sign-up failed',
      'account_disabled': 'This account has been disabled',
      'reset_password_failed': 'Failed to send password reset email',
      'no_user_found': 'No account found with this email address',

      // New translations
      'ride_history': 'Ride History',
      'no_rides_yet': 'No rides yet',
      'driver': 'Driver',
      'rider': 'Passenger',

      // Phone number related translations
      'phone_number': 'Phone Number',
      'please_enter_phone': 'Please enter your phone number',
      'invalid_phone': 'Please enter a valid phone number',

      'not_verified_yet': 'Not Verified Yet',

      // Random translations
      'please_select_contact': 'Please select at least one contact',
      'retry': 'Retry',
      'failed_send_verification': 'Failed to send verification requests: ',
      'choose_from_gallery': 'Choose from Gallery',
      'take_photo': 'Take Photo',
    },
    'fr': {
      // Onboarding & Auth
      'welcome_to': 'Bienvenue sur\nCovoisino',
      'community_driven_rides': 'Covoiturage communautaire entre voisins de confiance',
      'get_started': 'Commencer',
      'already_have_account': 'Déjà un compte ?',
      'welcome_back': 'Bon\nRetour !',
      'continue_journey': 'Continuez votre voyage avec des voisins de confiance',
      'login': 'Connexion',
      'signup': 'S\'inscrire',
      'create_account': 'Créer un\nCompte',
      'join_community': 'Rejoignez notre communauté de confiance',
      'or_continue_with': 'ou continuer avec',
      'dont_have_account': 'Pas encore de compte ? ',
      'forgot_password': 'Mot de passe oublié ?',
      'reset_password': 'Réinitialiser le mot de passe',
      'enter_email_reset': 'Entrez votre email pour recevoir un lien de réinitialisation',
      'send_reset_link': 'Envoyer le lien',
      'reset_link_sent': 'Lien de réinitialisation envoyé à votre email',

      // Form Fields & Validation
      'email': 'Email',
      'password': 'Mot de passe',
      'full_name': 'Nom complet',
      'verification_code': 'Code de vérification',
      'please_enter_email': 'Veuillez entrer votre email',
      'please_enter_valid_email': 'Veuillez entrer un email valide',
      'please_enter_password': 'Veuillez entrer votre mot de passe',
      'please_enter_name': 'Veuillez entrer votre nom',
      'password_min_length': 'Le mot de passe doit contenir au moins 6 caractères',
      
      // Email Verification
      'verify_email': 'Vérifier l\'email',
      'check_email': 'Vérifiez votre email',
      'enter_verification_code': 'Entrez le code de vérification envoyé à ',
      'verify_email_button': 'Vérifier l\'email',
      
      // Buttons & Actions
      'continue_with_google': 'Continuer avec Google',
      'google': 'Google',
      'cancel': 'Annuler',
      'back': 'Retour',
      'or': 'ou',
      'save': 'Sauvegarder',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'confirm': 'Confirmer',

      // Profile & Account
      'profile': 'Profil',
      'account_settings': 'Paramètres du compte',
      'edit_profile': 'Modifier le profil',
      'verified_member': 'Membre vérifié',
      'change_photo': 'Changer la photo',
      'remove_photo': 'Supprimer la photo',
      
      // QR Scan Screen
      'scan_qr_code': 'Scanner le code QR',
      'position_qr': 'Positionnez le code QR dans le cadre',
      'simulate_scan': 'Simuler le scan',
      
      // QR Display Screen
      'your_qr_code': 'Votre code QR',
      'show_to_passengers': 'Montrez-le aux passagers pour commencer le trajet',
      'simulate_passenger_scan': 'Simuler le scan passager',
      
      // Ride Confirmation
      'new_passenger': 'Nouveau passager',
      'confirm_ride': 'Confirmer le trajet',
      'vehicle_details': 'Détails du véhicule',
      'safety_check': 'Vérification de sécurité',
      'verify_passenger': 'Vérifiez que le passager correspond à sa photo de profil avant d\'accepter.',
      'verify_driver': 'Vérifiez que le conducteur et les détails du véhicule correspondent avant de commencer.',
      'accept_ride': 'Accepter le trajet',
      'start_ride': 'Commencer le trajet',
      
      // Ride Screen
      'emergency': 'URGENCE',
      'end_ride': 'Terminer le trajet',
      'end_ride_confirmation': 'Êtes-vous sûr de vouloir terminer ce trajet ?',
      
      // Emergency Screen
      'emergency_services': 'Services d\'urgence',
      'get_assistance': 'Obtenir une assistance immédiate',
      'emergency_actions': 'Actions d\'urgence',
      'call_emergency': 'Appeler les services d\'urgence',
      'connect_responders': 'Contactez les services d\'urgence',
      'share_location': 'Partager la localisation',
      'send_location': 'Envoyer votre position actuelle',
      'back_to_safety': 'Retour à la sécurité',
      'call_confirmation': 'Voulez-vous appeler les services d\'urgence (112) ?',
      'sharing_location': 'Partage de la localisation avec les services d\'urgence...',
      'could_not_launch_call': 'Impossible de lancer l\'appel d\'urgence',
      'location_permission_denied': 'Permission de localisation refusée',
      'location_permissions_permanently_denied': 'Les permissions de localisation sont définitivement refusées, veuillez les activer dans les paramètres',
      'settings': 'Paramètres',
      'emergency_message': 'URGENCE : J\'ai besoin d\'aide avec mon trajet !',
      'my_location': 'Ma position actuelle',
      'emergency_location_share': 'Partage de position d\'urgence',
      'location_shared_successfully': 'Position partagée avec succès',
      
      // Messages & Errors
      'error': 'Erreur : ',
      'success': 'Succès !',
      'warning': 'Attention',
      'info': 'Information',
      'loading': 'Chargement...',
      'please_wait': 'Veuillez patienter...',
      'try_again': 'Réessayer',
      'something_went_wrong': 'Une erreur est survenue',
      'no_internet': 'Pas de connexion internet',
      'connection_error': 'Erreur de connexion',
      'invalid_credentials': 'Email ou mot de passe invalide',
      'session_expired': 'Session expirée. Veuillez vous reconnecter',

      // Home screen
      'need_ride': 'Besoin d\'un trajet ?',
      'connect_drivers': 'Connectez-vous avec des conducteurs de confiance',
      'scan_qr': 'Scanner le code QR',
      'want_help': 'Voulez-vous aider ?',
      'add_vehicle': 'Ajouter un véhicule',
      'add_vehicle_subtitle':
          'Ajoutez les détails de votre véhicule pour commencer à conduire',
      'show_qr_subtitle': 'Montrez votre code QR aux passagers',
      'show_qr': 'Afficher le code QR',
      'pending_verification': 'Vérification en attente',
      'update_vehicle': 'Mettre à jour le véhicule',
      'sponsorship_status': 'Statut de parrainage',
      'verified': 'Vérifié',
      'language': 'Langue',
      'sign_out': 'Déconnexion',
      'sign_out_confirm': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'verification_required': 'Vérification requise',
      'verification_subtitle':
          'Faites-vous vérifier par des membres de confiance pour utiliser cette fonctionnalité',
      'get_verified': 'Se faire vérifier',
      'vehicle_required': 'Véhicule requis',
      'vehicle_subtitle':
          'Ajoutez les détails de votre véhicule pour commencer à accepter des trajets',
      'vehicle_model': 'Modèle du véhicule',
      'license_plate': 'Plaque d\'immatriculation',
      'vehicle_color': 'Couleur du véhicule',
      'please_enter_vehicle': 'Veuillez entrer le modèle du véhicule',
      'please_enter_plate': 'Veuillez entrer la plaque d\'immatriculation',
      'selected_color': 'Sélectionné : ',
      'save_changes': 'Enregistrer les modifications',
      'profile_updated': 'Profil mis à jour avec succès',
      'vehicle_added': 'Véhicule ajouté avec succès',
      'vehicle_updated': 'Véhicule mis à jour avec succès',
      'please_valid_email': 'Veuillez entrer un email valide',

      // Verification Status Sheet
      'verification_status': 'Statut de vérification',
      'verified_by': 'Vérifié par',
      'pending_requests': 'Demandes en attente',
      'request_verifications': 'Demander plus de vérifications',

      // Ride screen
      'initiating_emergency_call': 'Appel d\'urgence en cours...',
      'call': 'Appeler',

      // Email Verification
      'verification_email_sent': 'Un email de vérification a été envoyé à ',
      'verification_email_resent': 'L\'email de vérification a été renvoyé',
      'resend_verification_email': 'Renvoyer l\'email de vérification',
      'email_not_verified': 'Veuillez vérifier votre email pour continuer',
      "email_verification_required": "Vérification d'e-mail requise",
      "email_verified": "E-mail vérifié",
      "verify_email_description":
          "Veuillez vérifier votre adresse e-mail pour accéder à toutes les fonctionnalités.",
      "send_verification_email": "Envoyer l'e-mail de vérification",
      "email_verification_pending": "Vérification d'e-mail en attente",
      "email_and_sponsorship_required":
          "Vérification d'e-mail et parrainage requis",
      "verification_complete": "Vérification terminée",
      "please_verify_email": "Veuillez vérifier votre e-mail pour continuer",
      "check_inbox":
          "Vérifiez votre boîte de réception pour le lien de vérification",

      // Firebase Auth Errors
      'weak_password':
          'Le mot de passe est trop faible. Utilisez au moins 6 caractères',
      'email_already_exists': 'Un compte existe déjà avec cet email',
      'invalid_email': 'Veuillez entrer une adresse email valide',
      'wrong_password': 'Mot de passe incorrect',
      'user_not_found': 'Aucun compte trouvé avec cet email',
      'signup_failed': 'Échec de la création du compte',
      'login_failed': 'Échec de la connexion',
      'google_signin_failed': 'Échec de la connexion avec Google',
      'google_signup_failed': 'Échec de l\'inscription avec Google',
      'account_disabled': 'Ce compte a été désactivé',
      'reset_password_failed':
          'Échec de l\'envoi de l\'email de réinitialisation',
      'no_user_found': 'Aucun compte trouvé avec cette adresse email',

      // New translations
      'ride_history': 'Historique des trajets',
      'no_rides_yet': 'Aucun trajet encore',
      'driver': 'Conducteur',
      'rider': 'Passager',

      // Phone number related translations
      'phone_number': 'Numéro de téléphone',
      'please_enter_phone': 'Veuillez entrer votre numéro de téléphone',
      'invalid_phone': 'Veuillez entrer un numéro de téléphone valide',

      'not_verified_yet': 'Non vérifié encore',

      // Random translations
      'please_select_contact': 'Veuillez sélectionner au moins un contact',
      'retry': 'Réessayer',
      'failed_send_verification': 'Échec de l\'envoi des demandes de vérification : ',
      'choose_from_gallery': 'Choisir depuis la Galerie',
      'take_photo': 'Prendre une Photo',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('fr', ''), // French
  ];

  static bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.isSupported(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../meditation/data/models/meditation_session.dart';
import '../../settings/data/models/user_settings_model.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    if (kIsWeb) {
      // On web, use Supabase OAuth redirect flow.
      // Explicitly pass Uri.base.toString() which resolves to the <base href> tag
      // (e.g. /shunya-meditation-app/) to fix Safari stripping the path.
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.toString(),
      );
      // OAuth redirect — won't return an AuthResponse immediately
      return null;
    }

    // Native flow for mobile
    const webClientId = String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue: '',
    );
    const iosClientId = String.fromEnvironment(
      'GOOGLE_IOS_CLIENT_ID',
      defaultValue: '',
    );

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId.isNotEmpty ? iosClientId : null,
      serverClientId: webClientId.isNotEmpty ? webClientId : null,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('No ID Token found');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Whether Apple Sign-In is enabled (controlled by env var)
  bool get isAppleSignInEnabled {
    const enabled = String.fromEnvironment(
      'APPLE_SIGN_IN_ENABLED',
      defaultValue: 'false',
    );
    return enabled.toLowerCase() == 'true';
  }

  /// Sign in with Apple (uses Supabase OAuth flow)
  Future<bool> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb ? Uri.base.toString() : 'com.anamiapps.shunya://login-callback/',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
    
    // Clear all local data on sign out
    try {
      await Hive.box<MeditationSession>('meditation_sessions').clear();
      await Hive.box<UserSettingsModel>('user_settings').clear();
      await Hive.box('app_state').clear();
    } catch (_) {}

    await _client.auth.signOut();
  }

  /// Create or get user settings on first login
  Future<void> ensureUserSettings() async {
    final user = currentUser;
    if (user == null) return;

    final existing = await _client
        .from('user_settings')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing == null) {
      await _client.from('user_settings').insert({
        'user_id': user.id,
        'daily_tap_goal': 1080,
        'daily_time_goal_seconds': 600,
        'haptic_interval': 1,
        'audio_reminder_enabled': false,
        'audio_reminder_sound': 'om',
      });
    }
  }
}


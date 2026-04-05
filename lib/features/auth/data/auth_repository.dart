import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
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
        redirectTo: 'com.shunya.shunya://login-callback/',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
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

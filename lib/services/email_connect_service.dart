import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kEmail = 'connected_email';
const _kName = 'connected_name';
const _kPhoto = 'connected_photo';

class EmailConnectService {
  final _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<String?> connectEmail() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail, account.email);
    await prefs.setString(_kName, account.displayName ?? '');
    if (account.photoUrl != null) await prefs.setString(_kPhoto, account.photoUrl!);
    await _googleSignIn.disconnect();
    return account.email;
  }

  Future<void> disconnectEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmail);
    await prefs.remove(_kName);
    await prefs.remove(_kPhoto);
  }

  Future<Map<String, String?>> getConnectedInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_kEmail),
      'name': prefs.getString(_kName),
      'photo': prefs.getString(_kPhoto),
    };
  }
}

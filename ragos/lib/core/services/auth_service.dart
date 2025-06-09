import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final _logger = Logger();


class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  Future<User?> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await cred.user!.updateDisplayName(fullName);
    await cred.user!.sendEmailVerification();

    // Store partial profile (we'll add rooms later)
    await _db.collection('users').doc(cred.user!.uid).set({
      'fullName' : fullName,
      'phone'    : phone,
      'email'    : email,
      'createdAt': FieldValue.serverTimestamp(),
      'verified' : false,
    });

    return cred.user;
  }

  Future<void> completeProfile({
    required int kitchens,
    required int bedrooms,
    required int livingRooms,
    required int extraRooms,
    required String caregiverPhone,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).update({
      'rooms': {
        'kitchens'   : kitchens,
        'bedrooms'   : bedrooms,
        'livingRooms': livingRooms,
        'extraRooms' : extraRooms,
      },
      'caregiverPhone': caregiverPhone,
    });
  }

    Future<User?> login(String email, String pwd) async {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
            email: email, password: pwd);
        final user = credential.user;
        _logger.i("✅ Login successful: uid=${user?.uid}, email=${user?.email}");
        return user;
      } catch (e, stackTrace) {
        _logger.e("❌ Login failed for $email", error: e, stackTrace: stackTrace);
        return null;
      }
    }




  Future<void> logout() => _auth.signOut();

  Stream<User?> authChanges() => _auth.authStateChanges();
}

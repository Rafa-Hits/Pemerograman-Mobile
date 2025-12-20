import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService(this._firebaseAuth, this._firestore);

  // ==============================
  // AUTH STATE
  // ==============================
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

// ==============================
  // ADMIN: CREATE USER DATA (AMAN)
  // ==============================
  Future<void> createUserAsAdmin({
    required String nama,
    required String email,
    required UserRole peran,
  }) async {
    // Cari apakah user sudah pernah login
    final query =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      throw Exception(
        'User belum login ke sistem. '
        'Minta user login sekali terlebih dahulu.',
      );
    }

    // Update role saja (AMAN)
    await query.docs.first.reference.update({
      'peran': peran.name,
      'wajibGantiPassword': false,
    });
  }

  // ==============================
  // ENSURE USER DOCUMENT (KUNCI UTAMA)
  // ==============================
  Future<void> _ensureUserDataExists(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        nama: user.email?.split('@').first ?? 'Pengguna',
        peran: UserRole.peserta, // default aman
        wajibGantiPassword: false,
      );

      await docRef.set(newUser.toMap());
    }
  }

  // ==============================
  // SIGN UP (KHUSUS PESERTA)
  // ==============================
  Future<void> signUpAsPeserta({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          email: email,
          nama: nama,
          peran: UserRole.peserta,
          wajibGantiPassword: false,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        await sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // ==============================
  // SIGN IN (SEMUA ROLE)
  // ==============================
Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      // 🔥 PAKSA REFRESH TOKEN (CUSTOM CLAIMS)
      await user.getIdToken(true);

      await _ensureUserDataExists(user);
    }
  }
  // ==============================
  // SIGN OUT
  // ==============================
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // ==============================
  // ADMIN: SET ROLE USER (AMAN)
  // ==============================
  Future<void> setUserRoleByEmail({
    required String email,
    required UserRole peran,
  }) async {
    final query =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      throw Exception('User belum login atau belum terdaftar.');
    }

    await query.docs.first.reference.update({'peran': peran.name});
  }

  // ==============================
  // CHANGE PASSWORD (WAJIB GANTI)
  // ==============================
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Pengguna tidak ditemukan.');
    }

    await reauthenticateWithPassword(oldPassword);
    await user.updatePassword(newPassword);

    await _firestore.collection('users').doc(user.uid).update({
      'wajibGantiPassword': false,
    });
  }

  // ==============================
  // REAUTHENTICATE
  // ==============================
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Pengguna tidak ditemukan.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  // ==============================
  // EMAIL VERIFICATION
  // ==============================
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ==============================
  // RESET PASSWORD
  // ==============================
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found') {
        throw Exception(e.message);
      }
    }
  }
}

// ==============================
// PROVIDERS (TIDAK DIUBAH)
// ==============================
final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  ),
);


final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);


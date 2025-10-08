import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Box<UserModel> _userBox = Hive.box<UserModel>('userBox');

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile'], signInOption: SignInOption.standard);

  // ---------------- Email / Password ----------------
  Future<User?> registerWithEmail({required String name, required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      await user?.updateDisplayName(name);

      final userModel = UserModel(uid: user!.uid, name: name, email: email);

      await _userBox.put('user', userModel);
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> signInWithEmail({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      final userModel = UserModel(uid: user!.uid, name: user.displayName ?? '', email: email);

      final existingUser = _userBox.get('user');
      if (existingUser == null || existingUser.uid != userModel.uid) {
        await _userBox.put('user', userModel);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Xóa Hive cho an toàn
        await _userBox.clear();
      }
      throw Exception(e.message);
    }
  }

  // ---------------- Google Sign-In ----------------
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null;

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final userCredential = await _auth.signInWithCredential(credential);
  //     final user = userCredential.user;
  //     if (user == null) return null;

  //     final userModel = UserModel(
  //       uid: user.uid,
  //       name: user.displayName ?? '',
  //       email: user.email ?? '',
  //       profilePictureUrl: user.photoURL,
  //     );

  //     await _userBox.put('user', userModel);
  //     return user;
  //   } catch (e) {
  //     print('Lỗi Google Sign-In: $e');
  //     return null;
  //   }
  // }

  // ---------------- Sign Out ----------------
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _userBox.clear();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }
}

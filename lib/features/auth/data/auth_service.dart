import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Box<UserModel> _userBox = Hive.box<UserModel>('userBox');

  // ---------------- Email / Password ----------------
  Future<User?> registerWithEmail({required String name, required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      await user?.updateDisplayName(name);

      final userModel = UserModel(uid: user!.uid, name: name, email: email);

      await _userBox.put(userModel.uid, userModel);
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

    final existingUser = _userBox.get(userModel.uid);
    if (existingUser == null || existingUser.uid != userModel.uid) {
      await _userBox.put(userModel.uid, userModel); 
    }

    return user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      await _userBox.clear();
    }
    throw Exception(e.message);
  }
}

  // ---------------- Sign Out ----------------
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  UserModel? getUserByUid(String uid) {
    return _userBox.get(uid);
  }

  // Future<void> deleteUser() async {
  //   try {
      
  //     await _userBox.clear();
  //     await _currentUserBox.clear();
  //     print("Deleted user data from Hive boxes.");
  //   } catch (e) {
  //     throw Exception('Error deleting user: $e');
  //   }
  // }
}

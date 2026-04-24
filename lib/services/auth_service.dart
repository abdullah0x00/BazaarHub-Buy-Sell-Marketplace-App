import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: "marketplace-app-a554e.firebasestorage.app");

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? firebaseUser = result.user;

      if (firebaseUser != null) {
        final doc = await _db.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          final user = UserModel.fromJson(doc.data()!);
          await _saveUser(user);
          return user;
        } else {
          // Create new user if not exists
          final newUser = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
            avatar: firebaseUser.photoURL,
            createdAt: DateTime.now(),
            role: UserRole.buyer,
          );
          await _db.collection('users').doc(newUser.id).set(newUser.toJson());
          await _saveUser(newUser);
          return newUser;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<String?> uploadProfilePicture(String userId, File imageFile) async {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        throw Exception('Image file not found on device.');
      }

      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      
      // Upload with metadata
      final uploadTask = await ref.putFile(
        imageFile, 
        SettableMetadata(contentType: 'image/jpeg')
      );

      if (uploadTask.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception('Upload failed with state: ${uploadTask.state}');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'project-not-found') {
        throw Exception('Firebase Storage is not enabled. Go to Firebase Console > Storage and click Get Started.');
      }
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (result.user != null) {
        final doc = await _db.collection('users').doc(result.user!.uid).get();
        if (doc.exists) {
          final user = UserModel.fromJson(doc.data()!);
          if (user.isBlocked) throw Exception('Your account has been blocked.');
          await _saveUser(user);
          return user;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'configuration-not-found' || (e.message?.contains('CONFIGURATION_NOT_FOUND') ?? false)) {
        throw Exception('Firebase Configuration Error: \n1. Enable Email/Password in Firebase Console.\n2. Disable reCAPTCHA Enterprise in Auth Settings.\n3. Add SHA-256 to Project Settings.');
      }
      throw Exception(e.message ?? 'Authentication failed');
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (result.user == null) throw Exception('Registration failed');

      final newUser = UserModel(
        id: result.user!.uid,
        name: name,
        email: email.toLowerCase().trim(),
        createdAt: DateTime.now(),
        role: UserRole.buyer,
      );

      await _db.collection('users').doc(newUser.id).set(newUser.toJson());
      await _saveUser(newUser);
      return newUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'configuration-not-found' || (e.message?.contains('CONFIGURATION_NOT_FOUND') ?? false)) {
        throw Exception('Firebase Configuration Error: \n1. Enable Email/Password in Firebase Console.\n2. Disable reCAPTCHA Enterprise in Auth Settings.\n3. Add SHA-256 to Project Settings.');
      }
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<List<UserModel>> getPendingSellers() async {
    final snapshot = await _db.collection('users')
        .where('role', isEqualTo: 'seller')
        .where('isApprovedSeller', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<void> approveSeller(String userId) async {
    await _db.collection('users').doc(userId).update({'isApprovedSeller': true});
  }

  Future<void> toggleBlockUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      final user = UserModel.fromJson(doc.data()!);
      await _db.collection('users').doc(userId).update({'isBlocked': !user.isBlocked});
    }
  }

  Future<UserModel> updateProfile(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toJson());
    await _saveUser(user);
    return user;
  }

  Future<UserModel> applyForSeller({
    required UserModel user,
    required String shopName,
    required String cnic,
    required String phone,
    required String bankAccount,
  }) async {
    final updatedUser = user.copyWith(
      role: UserRole.seller,
      shopName: shopName,
      cnic: cnic,
      phone: phone,
      bankAccount: bankAccount,
      isApprovedSeller: true, 
    );
    
    await _db.collection('users').doc(user.id).update(updatedUser.toJson());
    await _saveUser(updatedUser);
    return updatedUser;
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keyAuthToken);
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.keyUserData);
    if (userData == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userData));
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyUserData,
      jsonEncode(user.toJson()),
    );
    await prefs.setString(AppConstants.keyAuthToken, 'token_${user.id}');
  }
}

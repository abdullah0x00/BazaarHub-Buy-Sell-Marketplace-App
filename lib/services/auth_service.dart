import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '926400748582-5ddu1c8e276a79vef4c6s4cce2lb9552.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 100% Working Upload Logic consolidated for both Products and Profile
  Future<String> uploadFile(File imageFile, {String folder = 'products'}) async {
    try {
      if (!imageFile.existsSync()) {
        throw Exception('File does not exist on device.');
      }

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference ref = _storage
          .ref()
          .child(folder)
          .child('$fileName.jpg');

      // Read file as bytes to avoid any path/permission issues on Android
      final Uint8List bytes = await imageFile.readAsBytes();

      // Use putData instead of putFile for better reliability
      UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for completion
      TaskSnapshot snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.error) {
        throw Exception('Upload failed. Please try again.');
      }

      // Get URL
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Storage Error: ${e.code} - ${e.message}");
      if (e.code == 'unauthorized') {
        throw Exception('Permission Denied: Please check your Storage Rules in Firebase Console.');
      } else if (e.code == 'quota-exceeded') {
        throw Exception('Storage Quota Exceeded: Please upgrade to Blaze plan or check usage.');
      } else if (e.code == 'object-not-found') {
        throw Exception('Firebase Storage is not initialized properly. Go to Firebase Console -> Storage -> Click "Get Started".');
      } else if (e.code == 'retry-limit-exceeded') {
        throw Exception('Network error: Upload timed out. Please check your internet connection.');
      }
      throw Exception('Firebase Error: ${e.message}');
    } catch (e) {
      debugPrint("General Upload Error: $e");
      throw Exception('Upload failed: $e');
    }
  }

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
          UserModel user = UserModel.fromJson(doc.data()!);
          
          // Safety check for admin email
          if (user.email.toLowerCase().trim() == 'admin@bazaarhub.com' && user.role != UserRole.admin) {
            user = user.copyWith(role: UserRole.admin);
            await _db.collection('users').doc(user.id).update({'role': 'admin'});
          }

          await _saveUser(user);
          return user;
        } else {
          final newUser = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
            avatar: firebaseUser.photoURL,
            createdAt: DateTime.now(),
            role: firebaseUser.email?.toLowerCase().trim() == 'admin@bazaarhub.com' ? UserRole.admin : UserRole.buyer,
          );
          await _db.collection('users').doc(newUser.id).set(newUser.toJson());
          await _saveUser(newUser);
          return newUser;
        }
      }
      return null;
    } catch (e) {
      String message = e.toString();
      if (message.contains('Api10')) {
        message = 'Google Sign-In Error (Api10): Please add your SHA-1 key to Firebase Project Settings.';
      }
      throw Exception(message);
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
          UserModel user = UserModel.fromJson(doc.data()!);
          
          // Safety check: ensure admin email always has admin role
          if (user.email.toLowerCase().trim() == 'admin@bazaarhub.com' && user.role != UserRole.admin) {
            user = user.copyWith(role: UserRole.admin);
            // Optionally update database too
            await _db.collection('users').doc(user.id).update({'role': 'admin'});
          }

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
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Firestore Rules Error: Go to Firebase Console > Firestore > Rules and set them to "allow read, write: if true;" then click Publish.');
      }
      throw Exception(e.message ?? 'Database error');
    } catch (e) {
      throw Exception(e.toString());
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
        role: email.toLowerCase().trim() == 'admin@bazaarhub.com' ? UserRole.admin : UserRole.buyer,
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
    String? warehouseAddress,
  }) async {
    final updatedUser = user.copyWith(
      role: UserRole.seller,
      shopName: shopName,
      cnic: cnic,
      phone: phone,
      bankAccount: bankAccount,
      warehouseAddress: warehouseAddress,
      isApprovedSeller: false, // Set to false so Admin can approve
    );
    
    await _db.collection('users').doc(user.id).update(updatedUser.toJson());
    await _saveUser(updatedUser);
    return updatedUser;
  }

  Future<void> updateOnboardingStep(String userId, String step) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      final user = UserModel.fromJson(doc.data()!);
      final steps = List<String>.from(user.completedOnboardingSteps);
      if (!steps.contains(step)) {
        steps.add(step);
        await _db.collection('users').doc(userId).update({
          'completedOnboardingSteps': steps,
        });
        await _saveUser(user.copyWith(completedOnboardingSteps: steps));
      }
    }
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

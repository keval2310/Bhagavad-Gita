import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';

class UserState {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final bool isLoggedIn;

  UserState({this.id, this.email, this.name, this.role, this.isLoggedIn = false});

  factory UserState.initial() => UserState();
  
  factory UserState.fromMap(Map<String, dynamic> data) {
    return UserState(
      id: data['id'],
      email: data['email'],
      name: data['name'],
      role: data['role'],
      isLoggedIn: true,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final FirebaseService _firebase = FirebaseService();

  UserNotifier() : super(UserState.initial());

  Future<bool> login(String email, String password) async {
    final userData = await _firebase.loginUser(email, password);
    if (userData != null) {
      state = UserState.fromMap(userData);
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    final success = await _firebase.registerUser(email, password, name);
    if (success) {
      return await login(email, password);
    }
    return false;
  }

  void logout() async {
    await _firebase.logout();
    state = UserState.initial();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

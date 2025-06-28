import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _userKey = 'user_data';
  static const _profileImageKey = 'profile_image_path';

  Future<void> saveUser(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    await _storage.write(key: _userKey, value: userJson);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao decodificar dados do usuário: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }

  Future<void> clearUserData() async {
    await Future.wait([
      _storage.delete(key: _userKey),
      _storage.delete(key: _profileImageKey),
    ]);
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    await saveUser(userData);
  }

  // Métodos para gerenciar imagem do perfil
  Future<void> saveProfileImagePath(String imagePath) async {
    await _storage.write(key: _profileImageKey, value: imagePath);
  }

  Future<String?> getProfileImagePath() async {
    return await _storage.read(key: _profileImageKey);
  }

  Future<void> clearProfileImage() async {
    await _storage.delete(key: _profileImageKey);
  }
}

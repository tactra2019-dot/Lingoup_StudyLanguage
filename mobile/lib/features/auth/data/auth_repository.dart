import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/models/models.dart';
import '../../../core/network/dio_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserProfile?>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthRepository {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._dio);

  Future<UserProfile> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      });
      final token = response.data['access_token'];
      await _storage.write(key: 'auth_token', value: token);
      return UserProfile.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['access_token'];
      await _storage.write(key: 'auth_token', value: token);
      return UserProfile.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserProfile> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<UserProfile> updateProfile({String? displayName, int? selectedLanguageId}) async {
    try {
      final response = await _dio.patch('/auth/me', data: {
        if (displayName != null) 'display_name': displayName,
        if (selectedLanguageId != null) 'selected_language_id': selectedLanguageId,
      });
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final loggedIn = await _repo.isLoggedIn();
      if (loggedIn) {
        final user = await _repo.getMe();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.login(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String email, String password, String displayName) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.register(
        email: email, password: password, displayName: displayName,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repo.getMe();
      state = AsyncValue.data(user);
    } catch (_) {}
  }
}

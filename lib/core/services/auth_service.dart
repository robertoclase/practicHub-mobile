import '../config/api_config.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// Servicio de autenticación
class AuthService {
  final ApiClient _client = ApiClient();
  final StorageService _storage = StorageService();

  /// Login de usuario (alumno/profesor)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        ApiConfig.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      print('Login response: $response');

      // Manejar respuesta como Map
      final Map<String, dynamic> responseMap = response is Map<String, dynamic>
          ? response
          : {'error': 'Formato de respuesta inválido'};

      if (!responseMap.containsKey('token')) {
        throw Exception('No se recibió token de autenticación');
      }

      // Guardar datos de autenticación
      final token = responseMap['token'] as String;
      final userData = responseMap['user'] as Map<String, dynamic>;
      final role = responseMap['role'] as String? ?? userData['role'] as String? ?? 'alumno';

      print('Token: $token');
      print('User: $userData');
      print('Role: $role');

      // Bloquear acceso de admin en la app móvil
      if (role == 'admin') {
        throw Exception('Los administradores solo pueden acceder desde la web');
      }

      await _storage.saveToken(token);
      await _storage.saveUser(userData);
      await _storage.saveRole(role);

      print('Datos guardados correctamente');

      return responseMap;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  /// Login de empresa
  Future<Map<String, dynamic>> loginEmpresa(String email, String password) async {
    final response = await _client.post(
      ApiConfig.empresaLoginEndpoint,
      {
        'email': email,
        'password': password,
      },
    );

    // Guardar datos de autenticación
    final token = response['token'] as String;
    final empresaData = response['empresa'] as Map<String, dynamic>;
    final role = response['role'] as String? ?? 'empresa';

    await _storage.saveToken(token);
    await _storage.saveUser(empresaData);
    await _storage.saveRole(role);

    return response;
  }

  /// Registro de nuevo usuario
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'alumno',
  }) async {
    final response = await _client.post(
      ApiConfig.registerEndpoint,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      },
    );

    // Guardar datos de autenticación
    final token = response['token'] as String;
    final userData = response['user'] as Map<String, dynamic>;
    final userRole = response['role'] as String? ?? userData['role'] as String? ?? role;

    await _storage.saveToken(token);
    await _storage.saveUser(userData);
    await _storage.saveRole(userRole);

    return response;
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    try {
      await _client.post(ApiConfig.logoutEndpoint, {});
    } catch (e) {
      // Ignorar errores de logout en el servidor
      print('Error al hacer logout en servidor: $e');
    } finally {
      // Siempre limpiar almacenamiento local
      await _storage.clear();
    }
  }

  /// Verifica si hay un usuario autenticado
  Future<bool> isAuthenticated() async {
    return await _storage.isAuthenticated();
  }

  /// Obtiene el usuario actual del almacenamiento
  Future<User?> getCurrentUser() async {
    final userData = await _storage.getUser();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  /// Obtiene el rol del usuario actual
  Future<String?> getCurrentRole() async {
    return await _storage.getRole();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

/// Cliente HTTP genérico para comunicación con la API
class ApiClient {
  final StorageService _storage = StorageService();

  /// Headers comunes para todas las peticiones
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Realiza una petición GET
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición POST
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición PUT
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición DELETE
  Future<void> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.delete(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _parseErrorMessage(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Maneja la respuesta HTTP
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      // Retorna directamente lo que venga (puede ser Map o List)
      return json.decode(response.body);
    } else {
      throw _parseErrorMessage(response);
    }
  }

  /// Parsea el mensaje de error de la respuesta
  String _parseErrorMessage(http.Response response) {
    try {
      final errorData = json.decode(response.body) as Map<String, dynamic>;
      
      // Manejo de errores de validación de Laravel
      if (errorData.containsKey('errors')) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first as String;
        }
      }
      
      // Mensaje de error genérico
      if (errorData.containsKey('message')) {
        return errorData['message'] as String;
      }
      
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    } catch (e) {
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  }

  /// Maneja errores de conexión y timeout
  String _handleError(dynamic error) {
    if (error is http.ClientException) {
      return 'Error de conexión. Verifica tu internet.';
    } else if (error is FormatException) {
      return 'Error al procesar la respuesta del servidor.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Tiempo de espera agotado. Intenta de nuevo.';
    } else if (error is String) {
      return error;
    }
    return 'Error inesperado: ${error.toString()}';
  }
}

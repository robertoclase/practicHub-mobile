import 'package:flutter/foundation.dart' show kIsWeb;

// Configuración de la API
class ApiConfig {
  // URL base de la API
  // Para web: localhost
  // Para emulador Android: 10.0.2.2 mapea a localhost del host
  // Para dispositivo físico: usar IP de la red local
  static String get baseUrl {
    if (kIsWeb) {
      // En web, usar localhost
      return 'http://localhost:8000/api';
    } else {
      // En Android/iOS usar 10.0.2.2 para emuladores
      return 'http://10.0.2.2:8000/api';
    }
  }
  
  // Endpoints de autenticación
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String empresaLoginEndpoint = '/empresa/login';
  
  // Endpoints de alumno
  static const String misPracticasEndpoint = '/alumno/mis-practicas';
  static const String misPartesEndpoint = '/alumno/mis-partes';
  static const String misValoracionesEndpoint = '/alumno/mis-valoraciones';
  
  // Endpoints de profesor
  static const String profesorSeguimientosEndpoint = '/profesor/mis-seguimientos';
  static const String profesorAlumnosEndpoint = '/profesor/mis-alumnos';
  static const String profesorPartesPendientesEndpoint = '/profesor/partes-pendientes';
  static const String profesorValidarParteEndpoint = '/profesor/partes';
  static const String profesorValoracionesEndpoint = '/profesor/valoraciones';
  
  // Endpoints de empresa
  static const String empresaAlumnosEndpoint = '/empresa/mis-alumnos';
  static const String empresaPartesPendientesEndpoint = '/empresa/partes-pendientes';
  static const String empresaValidarParteEndpoint = '/empresa/partes';
  
  // Endpoints comunes
  static const String empresasListadoEndpoint = '/empresas/listado';
  static const String parteDiariosEndpoint = '/partes-diarios';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

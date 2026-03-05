import '../config/api_config.dart';
import '../models/seguimiento_practica.dart';
import '../models/parte_diario.dart';
import '../models/empresa.dart';
import '../models/valoracion.dart';
import 'api_client.dart';

/// Extrae una lista de una respuesta de la API (puede ser List o Map con 'data')
List<dynamic> _asList(dynamic response) {
  if (response is List) return response;
  if (response is Map) {
    final data = response['data'];
    if (data is List) return data;
  }
  return [];
}

/// Extrae un Map de una respuesta de la API (puede ser Map directo o Map con 'data')
Map<String, dynamic> _asMap(dynamic response) {
  if (response is Map<String, dynamic>) {
    return response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
  }
  return {};
}

/// Servicio para gestionar seguimientos de prácticas
class SeguimientosService {
  final ApiClient _client = ApiClient();

  /// Obtiene seguimientos según el rol del usuario
  Future<List<SeguimientoPractica>> getSeguimientos(String role) async {
    String endpoint;
    
    switch (role) {
      case 'alumno':
        endpoint = ApiConfig.misPracticasEndpoint;
        break;
      case 'profesor':
        endpoint = ApiConfig.profesorSeguimientosEndpoint;
        break;
      case 'empresa':
        endpoint = ApiConfig.empresaAlumnosEndpoint;
        break;
      default:
        endpoint = ApiConfig.misPracticasEndpoint;
    }
    
    final response = await _client.get(endpoint);
    return _asList(response)
        .map((json) => SeguimientoPractica.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene el detalle de un seguimiento específico (role-aware)
  Future<SeguimientoPractica> getSeguimientoDetalle(int id, String role) async {
    String endpoint;
    switch (role) {
      case 'empresa':
        endpoint = '/empresa/seguimientos/$id';
        break;
      case 'profesor':
        endpoint = '/seguimientos/$id';
        break;
      default: // alumno
        endpoint = '/alumno/mis-practicas/$id';
    }
    final response = await _client.get(endpoint);
    return SeguimientoPractica.fromJson(_asMap(response));
  }
}

/// Servicio para gestionar partes diarios
class PartesService {
  final ApiClient _client = ApiClient();

  /// Obtiene partes diarios (con filtro opcional por seguimiento)
  Future<List<ParteDiario>> getPartes({int? seguimientoId}) async {
    final String endpoint = seguimientoId != null
        ? '/alumno/practicas/$seguimientoId/partes'
        : ApiConfig.misPartesEndpoint;
    
    final response = await _client.get(endpoint);
    return _asList(response)
        .map((json) => ParteDiario.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene partes pendientes de validación según el rol
  Future<List<ParteDiario>> getPartesPendientes(String role) async {
    final String endpoint = role == 'profesor'
        ? ApiConfig.profesorPartesPendientesEndpoint
        : ApiConfig.empresaPartesPendientesEndpoint;
    
    final response = await _client.get(endpoint);
    return _asList(response)
        .map((json) => ParteDiario.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene el detalle de un parte específico
  Future<ParteDiario> getParteDetalle(int id) async {
    // /partes-diarios/{id} es accesible con auth:sanctum para todos los roles
    final response = await _client.get('/partes-diarios/$id');
    return ParteDiario.fromJson(_asMap(response));
  }

  /// Crea un nuevo parte diario
  Future<ParteDiario> createParte({
    required int seguimientoId,
    required DateTime fecha,
    required int horasTrabajadas,
    required String descripcionActividades,
    String? incidencias,
    String? observaciones,
  }) async {
    // Usa ruta específica de alumno que valida que el seguimiento le pertenece
    final response = await _client.post(
      '/alumno/mis-partes',
      {
        'seguimiento_practica_id': seguimientoId,
        'fecha': fecha.toIso8601String().split('T')[0],
        'horas_realizadas': horasTrabajadas,
        'actividades_realizadas': descripcionActividades,
        if (incidencias != null && incidencias.isNotEmpty) 'dificultades': incidencias,
        if (observaciones != null && observaciones.isNotEmpty) 'observaciones': observaciones,
      },
    );
    
    final data = _asMap(response);
    return ParteDiario.fromJson(data);
  }

  /// Valida un parte (profesor o empresa)
  Future<ParteDiario> validarParte({
    required int parteId,
    required bool validado,
    String? observaciones,
    bool isEmpresa = false,
  }) async {
    final String endpoint = isEmpresa
        ? '${ApiConfig.empresaValidarParteEndpoint}/$parteId/validar'
        : '${ApiConfig.profesorValidarParteEndpoint}/$parteId/validar';

    final body = <String, dynamic>{};
    if (isEmpresa) {
      // empresa: campo validado_tutor, puede enviar simplemente true
    } else {
      body['validado'] = validado;
      if (observaciones != null && observaciones.isNotEmpty) {
        body['observaciones'] = observaciones;
      }
    }

    final response = await _client.put(endpoint, body);

    // La API de empresa devuelve {"message":..., "parte": {...}}
    // La API de profesor devuelve directamente el parte o {"parte": {...}}
    final map = _asMap(response);
    if (map.containsKey('parte') && map['parte'] is Map<String, dynamic>) {
      return ParteDiario.fromJson(map['parte'] as Map<String, dynamic>);
    }
    return ParteDiario.fromJson(map);
  }
}

/// Servicio para gestionar empresas
class EmpresasService {
  final ApiClient _client = ApiClient();

  /// Obtiene todas las empresas (listado público)
  Future<List<Empresa>> getEmpresas() async {
    final response = await _client.get(ApiConfig.empresasListadoEndpoint);
    return _asList(response)
        .map((json) => Empresa.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene el detalle de una empresa
  Future<Empresa> getEmpresaDetalle(int id) async {
    // /empresas/{id} accesible con auth:sanctum; /empresas/listado es solo listing público
    final response = await _client.get('/empresas/$id');
    return Empresa.fromJson(_asMap(response));
  }
}

/// Servicio para gestionar valoraciones
class ValoracionesService {
  final ApiClient _client = ApiClient();

  /// Obtiene valoraciones del alumno autenticado
  Future<List<Valoracion>> getMisValoraciones() async {
    final response = await _client.get(ApiConfig.misValoracionesEndpoint);
    return _asList(response)
        .map((json) => Valoracion.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Crea una nueva valoración (profesor)
  Future<Valoracion> crearValoracion({
    required int seguimientoId,
    required double puntuacion,
    required String comentarios,
  }) async {
    final response = await _client.post(
      ApiConfig.profesorValoracionesEndpoint,
      {
        'seguimiento_practica_id': seguimientoId,
        'puntuacion': puntuacion,
        'comentarios': comentarios,
      },
    );
    return Valoracion.fromJson(_asMap(response));
  }
}

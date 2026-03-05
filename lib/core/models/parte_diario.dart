import 'package:equatable/equatable.dart';

/// Modelo de Parte Diario
class ParteDiario extends Equatable {
  final int id;
  final int seguimientoPracticaId;
  final DateTime fecha;
  final int horasTrabajadas;
  final String? descripcionActividades;
  final String? incidencias;
  final String? observaciones;
  final bool? validado; // Validado por profesor
  final bool? validadoEmpresa;
  final String? observacionesProfesor;
  final String? observacionesEmpresa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relación opcional con seguimiento
  final Map<String, dynamic>? seguimientoPractica;

  const ParteDiario({
    required this.id,
    required this.seguimientoPracticaId,
    required this.fecha,
    required this.horasTrabajadas,
    this.descripcionActividades,
    this.incidencias,
    this.observaciones,
    this.validado,
    this.validadoEmpresa,
    this.observacionesProfesor,
    this.observacionesEmpresa,
    this.createdAt,
    this.updatedAt,
    this.seguimientoPractica,
  });

  /// Crea un ParteDiario desde JSON
  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  factory ParteDiario.fromJson(Map<String, dynamic> json) {
    return ParteDiario(
      id: _toInt(json['id']),
      seguimientoPracticaId: _toInt(json['seguimiento_practica_id']),
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'].toString())
          : DateTime.now(),
      // La API usa 'horas_realizadas', soportamos también 'horas_trabajadas' como fallback
      horasTrabajadas: _toInt(json['horas_realizadas'] ?? json['horas_trabajadas'] ?? 0),
      // La API usa 'actividades_realizadas'
      descripcionActividades: json['actividades_realizadas'] as String? ?? json['descripcion_actividades'] as String?,
      // La API usa 'dificultades'
      incidencias: json['dificultades'] as String? ?? json['incidencias'] as String?,
      observaciones: json['observaciones'] as String?,
      // La API usa 'validado_profesor' y 'validado_tutor'
      validado: json['validado_profesor'] == 1 || json['validado_profesor'] == true || json['validado'] == true,
      validadoEmpresa: json['validado_tutor'] == 1 || json['validado_tutor'] == true || json['validado_empresa'] == true,
      observacionesProfesor: json['observaciones_profesor'] as String?,
      observacionesEmpresa: json['observaciones_empresa'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : null,
      seguimientoPractica: json['seguimiento_practica'] as Map<String, dynamic>?,
    );
  }

  /// Convierte el ParteDiario a JSON
  Map<String, dynamic> toJson() {
    return {
      'seguimiento_practica_id': seguimientoPracticaId,
      'fecha': fecha.toIso8601String().split('T')[0],
      'horas_realizadas': horasTrabajadas,
      if (descripcionActividades != null && descripcionActividades!.isNotEmpty)
        'actividades_realizadas': descripcionActividades,
      if (incidencias != null && incidencias!.isNotEmpty)
        'dificultades': incidencias,
      if (observaciones != null && observaciones!.isNotEmpty)
        'observaciones': observaciones,
    };
  }

  /// Verifica si el parte está validado (ambos: profesor y empresa)
  bool isValidatedByAll() {
    return (validado == true) && (validadoEmpresa == true);
  }

  /// Verifica si está parcialmente validado
  bool isPartiallyValidated() {
    return (validado == true) || (validadoEmpresa == true);
  }

  /// Verifica si está pendiente de validación
  bool isValidated() {
    return (validado == true) || (validadoEmpresa == true);
  }

  @override
  List<Object?> get props => [
        id,
        seguimientoPracticaId,
        fecha,
        horasTrabajadas,
        descripcionActividades,
        incidencias,
        observaciones,
        validado,
        validadoEmpresa,
        observacionesProfesor,
        observacionesEmpresa,
      ];
}

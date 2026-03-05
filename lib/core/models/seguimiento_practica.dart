import 'package:equatable/equatable.dart';
import 'empresa.dart';
import 'user.dart';

/// Modelo de Seguimiento de Práctica
class SeguimientoPractica extends Equatable {
  final int id;
  final int empresaId;
  final int profesorId;
  final int cursoAcademicoId;
  final int userId; // ID del alumno
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int horasTotales;
  final String estado;
  final String? objetivos;
  final String? actividades;

  // Relaciones opcionales (si vienen en la respuesta)
  final Empresa? empresa;
  final User? alumno;
  final Map<String, dynamic>? profesor;
  final Map<String, dynamic>? cursoAcademico;
  final int? totalPartes;
  final int? totalValoraciones;

  const SeguimientoPractica({
    required this.id,
    required this.empresaId,
    required this.profesorId,
    required this.cursoAcademicoId,
    required this.userId,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horasTotales,
    this.estado = 'activa',
    this.objetivos,
    this.actividades,
    this.empresa,
    this.alumno,
    this.profesor,
    this.cursoAcademico,
    this.totalPartes,
    this.totalValoraciones,
  });

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }
  static int? _toIntOrNull(dynamic val) => val == null ? null : _toInt(val);

  /// Crea un SeguimientoPractica desde JSON
  factory SeguimientoPractica.fromJson(Map<String, dynamic> json) {
    return SeguimientoPractica(
      id: _toInt(json['id']),
      empresaId: _toInt(json['empresa_id']),
      profesorId: _toIntOrNull(json['profesor_id']) ?? 0,
      cursoAcademicoId: _toIntOrNull(json['curso_academico_id']) ?? 0,
      userId: _toInt(json['user_id']),
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'].toString())
          : DateTime.now(),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'].toString())
          : DateTime.now(),
      horasTotales: _toIntOrNull(json['horas_totales']) ?? 0,
      estado: json['estado'] as String? ?? 'activa',
      objetivos: json['objetivos'] as String?,
      actividades: json['actividades'] as String?,
      empresa: json['empresa'] != null
          ? Empresa.fromJson(json['empresa'] as Map<String, dynamic>)
          : null,
      alumno: json['alumno'] != null
          ? User.fromJson(json['alumno'] as Map<String, dynamic>)
          : null,
      profesor: json['profesor'] as Map<String, dynamic>?,
      cursoAcademico: json['curso_academico'] as Map<String, dynamic>?,
      totalPartes: json['partes_diarios'] is List
          ? (json['partes_diarios'] as List).length
          : null,
      totalValoraciones: json['valoraciones'] is List
          ? (json['valoraciones'] as List).length
          : null,
    );
  }

  /// Convierte el SeguimientoPractica a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'profesor_id': profesorId,
      'curso_academico_id': cursoAcademicoId,
      'user_id': userId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'horas_totales': horasTotales,
      'estado': estado,
      if (objetivos != null) 'objetivos': objetivos,
      if (actividades != null) 'actividades': actividades,
    };
  }

  /// Verifica si la práctica está activa
  bool get isActiva => estado == 'activa';

  /// Obtiene el nombre de la empresa si está disponible
  String get empresaNombre => empresa?.nombre ?? 'Empresa #$empresaId';

  /// Obtiene el nombre del alumno si está disponible
  String get alumnoNombre => alumno?.name ?? 'Alumno #$userId';

  @override
  List<Object?> get props => [
        id,
        empresaId,
        profesorId,
        cursoAcademicoId,
        userId,
        titulo,
        descripcion,
        fechaInicio,
        fechaFin,
        horasTotales,
        estado,
      ];
}

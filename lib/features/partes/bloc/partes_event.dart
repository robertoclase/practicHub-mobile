import 'package:equatable/equatable.dart';

abstract class PartesEvent extends Equatable {
  const PartesEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar lista de partes según rol
class LoadPartes extends PartesEvent {
  final int? seguimientoId; // Opcional: filtrar por seguimiento

  const LoadPartes({this.seguimientoId});

  @override
  List<Object?> get props => [seguimientoId];
}

/// Cargar partes pendientes de validación (profesor/empresa)
class LoadPartesPendientes extends PartesEvent {
  const LoadPartesPendientes();
}

/// Cargar detalle de un parte específico
class LoadParteDetail extends PartesEvent {
  final int parteId;

  const LoadParteDetail(this.parteId);

  @override
  List<Object?> get props => [parteId];
}

/// Crear un nuevo parte diario
class CreateParte extends PartesEvent {
  final int seguimientoId;
  final DateTime fecha;
  final int horasTrabajadas;
  final String descripcionActividades;
  final String? incidencias;
  final String? observaciones;

  const CreateParte({
    required this.seguimientoId,
    required this.fecha,
    required this.horasTrabajadas,
    required this.descripcionActividades,
    this.incidencias,
    this.observaciones,
  });

  @override
  List<Object?> get props => [
        seguimientoId,
        fecha,
        horasTrabajadas,
        descripcionActividades,
        incidencias,
        observaciones,
      ];
}

/// Validar un parte (profesor o empresa)
class ValidarParte extends PartesEvent {
  final int parteId;
  final bool validado;
  final String? observaciones;
  final bool isEmpresa; // true = validar como empresa, false = como profesor

  const ValidarParte({
    required this.parteId,
    required this.validado,
    this.observaciones,
    this.isEmpresa = false,
  });

  @override
  List<Object?> get props => [parteId, validado, observaciones, isEmpresa];
}

/// Refrescar lista de partes
class RefreshPartes extends PartesEvent {
  const RefreshPartes();
}

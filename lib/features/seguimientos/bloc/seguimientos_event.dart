import 'package:equatable/equatable.dart';

abstract class SeguimientosEvent extends Equatable {
  const SeguimientosEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la lista de seguimientos según el rol del usuario
class LoadSeguimientos extends SeguimientosEvent {
  const LoadSeguimientos();
}

/// Evento para cargar el detalle de un seguimiento específico
class LoadSeguimientoDetail extends SeguimientosEvent {
  final int seguimientoId;

  const LoadSeguimientoDetail(this.seguimientoId);

  @override
  List<Object?> get props => [seguimientoId];
}

/// Evento para refrescar la lista
class RefreshSeguimientos extends SeguimientosEvent {
  const RefreshSeguimientos();
}

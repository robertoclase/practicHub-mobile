import 'package:equatable/equatable.dart';
import '../../../core/models/seguimiento_practica.dart';

abstract class SeguimientosState extends Equatable {
  const SeguimientosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class SeguimientosInitial extends SeguimientosState {
  const SeguimientosInitial();
}

/// Estado de carga
class SeguimientosLoading extends SeguimientosState {
  const SeguimientosLoading();
}

/// Estado de lista cargada con éxito
class SeguimientosLoaded extends SeguimientosState {
  final List<SeguimientoPractica> seguimientos;

  const SeguimientosLoaded(this.seguimientos);

  @override
  List<Object?> get props => [seguimientos];
}

/// Estado de detalle de un seguimiento cargado
class SeguimientoDetailLoaded extends SeguimientosState {
  final SeguimientoPractica seguimiento;

  const SeguimientoDetailLoaded(this.seguimiento);

  @override
  List<Object?> get props => [seguimiento];
}

/// Estado de error
class SeguimientosError extends SeguimientosState {
  final String message;

  const SeguimientosError(this.message);

  @override
  List<Object?> get props => [message];
}

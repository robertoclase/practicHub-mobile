import 'package:equatable/equatable.dart';
import '../../../core/models/parte_diario.dart';

abstract class PartesState extends Equatable {
  const PartesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PartesInitial extends PartesState {
  const PartesInitial();
}

/// Estado de carga
class PartesLoading extends PartesState {
  const PartesLoading();
}

/// Lista de partes cargada
class PartesLoaded extends PartesState {
  final List<ParteDiario> partes;

  const PartesLoaded(this.partes);

  @override
  List<Object?> get props => [partes];
}

/// Detalle de un parte cargado
class ParteDetailLoaded extends PartesState {
  final ParteDiario parte;

  const ParteDetailLoaded(this.parte);

  @override
  List<Object?> get props => [parte];
}

/// Parte creado con éxito
class ParteCreated extends PartesState {
  final ParteDiario parte;

  const ParteCreated(this.parte);

  @override
  List<Object?> get props => [parte];
}

/// Parte validado con éxito
class ParteValidated extends PartesState {
  final ParteDiario parte;

  const ParteValidated(this.parte);

  @override
  List<Object?> get props => [parte];
}

/// Error
class PartesError extends PartesState {
  final String message;

  const PartesError(this.message);

  @override
  List<Object?> get props => [message];
}

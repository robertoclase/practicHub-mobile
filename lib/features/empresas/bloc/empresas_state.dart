import 'package:equatable/equatable.dart';
import '../../../core/models/empresa.dart';

abstract class EmpresasState extends Equatable {
  const EmpresasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class EmpresasInitial extends EmpresasState {
  const EmpresasInitial();
}

/// Cargando
class EmpresasLoading extends EmpresasState {
  const EmpresasLoading();
}

/// Lista cargada
class EmpresasLoaded extends EmpresasState {
  final List<Empresa> empresas;
  final String? searchQuery;

  const EmpresasLoaded(this.empresas, {this.searchQuery});

  @override
  List<Object?> get props => [empresas, searchQuery];
}

/// Detalle cargado
class EmpresaDetailLoaded extends EmpresasState {
  final Empresa empresa;

  const EmpresaDetailLoaded(this.empresa);

  @override
  List<Object?> get props => [empresa];
}

/// Error
class EmpresasError extends EmpresasState {
  final String message;

  const EmpresasError(this.message);

  @override
  List<Object?> get props => [message];
}

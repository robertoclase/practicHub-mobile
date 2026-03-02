import 'package:equatable/equatable.dart';

abstract class EmpresasEvent extends Equatable {
  const EmpresasEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar lista de empresas
class LoadEmpresas extends EmpresasEvent {
  const LoadEmpresas();
}

/// Buscar empresas por nombre
class SearchEmpresas extends EmpresasEvent {
  final String query;

  const SearchEmpresas(this.query);

  @override
  List<Object?> get props => [query];
}

/// Cargar detalle de una empresa
class LoadEmpresaDetail extends EmpresasEvent {
  final int empresaId;

  const LoadEmpresaDetail(this.empresaId);

  @override
  List<Object?> get props => [empresaId];
}

/// Refrescar lista
class RefreshEmpresas extends EmpresasEvent {
  const RefreshEmpresas();
}

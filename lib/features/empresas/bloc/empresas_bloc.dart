import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../core/models/empresa.dart';
import 'empresas_event.dart';
import 'empresas_state.dart';

class EmpresasBloc extends Bloc<EmpresasEvent, EmpresasState> {
  final EmpresasService _empresasService;
  List<Empresa> _allEmpresas = [];

  EmpresasBloc({
    required EmpresasService empresasService,
  })  : _empresasService = empresasService,
        super(const EmpresasInitial()) {
    on<LoadEmpresas>(_onLoadEmpresas);
    on<SearchEmpresas>(_onSearchEmpresas);
    on<LoadEmpresaDetail>(_onLoadEmpresaDetail);
    on<RefreshEmpresas>(_onRefreshEmpresas);
  }

  Future<void> _onLoadEmpresas(
    LoadEmpresas event,
    Emitter<EmpresasState> emit,
  ) async {
    emit(const EmpresasLoading());

    try {
      _allEmpresas = await _empresasService.getEmpresas();
      emit(EmpresasLoaded(_allEmpresas));
    } catch (e) {
      emit(EmpresasError('Error al cargar empresas: ${e.toString()}'));
    }
  }

  Future<void> _onSearchEmpresas(
    SearchEmpresas event,
    Emitter<EmpresasState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(EmpresasLoaded(_allEmpresas));
      return;
    }

    final query = event.query.toLowerCase();
    final filtered = _allEmpresas.where((empresa) {
      final nombre = empresa.nombre.toLowerCase();
      final direccion = empresa.direccion.toLowerCase();
      final cif = empresa.cif.toLowerCase();
      
      return nombre.contains(query) ||
          direccion.contains(query) ||
          cif.contains(query);
    }).toList();

    emit(EmpresasLoaded(filtered, searchQuery: event.query));
  }

  Future<void> _onLoadEmpresaDetail(
    LoadEmpresaDetail event,
    Emitter<EmpresasState> emit,
  ) async {
    emit(const EmpresasLoading());

    try {
      final empresa = await _empresasService.getEmpresaDetalle(event.empresaId);
      emit(EmpresaDetailLoaded(empresa));
    } catch (e) {
      emit(EmpresasError('Error al cargar detalle: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshEmpresas(
    RefreshEmpresas event,
    Emitter<EmpresasState> emit,
  ) async {
    try {
      _allEmpresas = await _empresasService.getEmpresas();
      emit(EmpresasLoaded(_allEmpresas));
    } catch (e) {
      emit(EmpresasError('Error al refrescar: ${e.toString()}'));
    }
  }
}

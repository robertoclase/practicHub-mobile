import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/storage_service.dart';
import 'seguimientos_event.dart';
import 'seguimientos_state.dart';

class SeguimientosBloc extends Bloc<SeguimientosEvent, SeguimientosState> {
  final SeguimientosService _seguimientosService;
  final StorageService _storageService;

  SeguimientosBloc({
    required SeguimientosService seguimientosService,
    required StorageService storageService,
  })  : _seguimientosService = seguimientosService,
        _storageService = storageService,
        super(const SeguimientosInitial()) {
    on<LoadSeguimientos>(_onLoadSeguimientos);
    on<LoadSeguimientoDetail>(_onLoadSeguimientoDetail);
    on<RefreshSeguimientos>(_onRefreshSeguimientos);
  }

  Future<void> _onLoadSeguimientos(
    LoadSeguimientos event,
    Emitter<SeguimientosState> emit,
  ) async {
    emit(const SeguimientosLoading());

    try {
      final role = await _storageService.getRole();
      final seguimientos = await _seguimientosService.getSeguimientos(role ?? 'alumno');
      
      emit(SeguimientosLoaded(seguimientos));
    } catch (e) {
      emit(SeguimientosError('Error al cargar seguimientos: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSeguimientoDetail(
    LoadSeguimientoDetail event,
    Emitter<SeguimientosState> emit,
  ) async {
    emit(const SeguimientosLoading());

    try {
      final seguimiento = await _seguimientosService.getSeguimientoDetalle(event.seguimientoId);
      emit(SeguimientoDetailLoaded(seguimiento));
    } catch (e) {
      emit(SeguimientosError('Error al cargar detalles: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshSeguimientos(
    RefreshSeguimientos event,
    Emitter<SeguimientosState> emit,
  ) async {
    try {
      final role = await _storageService.getRole();
      final seguimientos = await _seguimientosService.getSeguimientos(role ?? 'alumno');
      
      emit(SeguimientosLoaded(seguimientos));
    } catch (e) {
      emit(SeguimientosError('Error al refrescar: ${e.toString()}'));
    }
  }
}

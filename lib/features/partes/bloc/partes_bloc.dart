import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/parte_diario.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/storage_service.dart';
import 'partes_event.dart';
import 'partes_state.dart';

class PartesBloc extends Bloc<PartesEvent, PartesState> {
  final PartesService _partesService;
  final StorageService _storageService;

  PartesBloc({
    required PartesService partesService,
    required StorageService storageService,
  })  : _partesService = partesService,
        _storageService = storageService,
        super(const PartesInitial()) {
    on<LoadPartes>(_onLoadPartes);
    on<LoadPartesPendientes>(_onLoadPartesPendientes);
    on<LoadParteDetail>(_onLoadParteDetail);
    on<CreateParte>(_onCreateParte);
    on<ValidarParte>(_onValidarParte);
    on<RefreshPartes>(_onRefreshPartes);
  }

  Future<void> _onLoadPartes(
    LoadPartes event,
    Emitter<PartesState> emit,
  ) async {
    emit(const PartesLoading());

    try {
      final role = await _storageService.getRole() ?? 'alumno';
      List<ParteDiario> partes;

      // Profesor y empresa ven los partes pendientes de validar, no los del alumno
      if (role == 'profesor' || role == 'empresa') {
        partes = await _partesService.getPartesPendientes(role);
      } else {
        partes = await _partesService.getPartes(
          seguimientoId: event.seguimientoId,
        );
      }
      emit(PartesLoaded(partes));
    } catch (e) {
      emit(PartesError('Error al cargar partes: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPartesPendientes(
    LoadPartesPendientes event,
    Emitter<PartesState> emit,
  ) async {
    emit(const PartesLoading());

    try {
      final role = await _storageService.getRole();
      final partes = await _partesService.getPartesPendientes(role ?? 'alumno');
      emit(PartesLoaded(partes));
    } catch (e) {
      emit(PartesError('Error al cargar partes pendientes: ${e.toString()}'));
    }
  }

  Future<void> _onLoadParteDetail(
    LoadParteDetail event,
    Emitter<PartesState> emit,
  ) async {
    emit(const PartesLoading());

    try {
      final parte = await _partesService.getParteDetalle(event.parteId);
      emit(ParteDetailLoaded(parte));
    } catch (e) {
      emit(PartesError('Error al cargar detalle: ${e.toString()}'));
    }
  }

  Future<void> _onCreateParte(
    CreateParte event,
    Emitter<PartesState> emit,
  ) async {
    emit(const PartesLoading());

    try {
      final parte = await _partesService.createParte(
        seguimientoId: event.seguimientoId,
        fecha: event.fecha,
        horasTrabajadas: event.horasTrabajadas,
        descripcionActividades: event.descripcionActividades,
        incidencias: event.incidencias,
        observaciones: event.observaciones,
      );
      emit(ParteCreated(parte));
    } catch (e) {
      emit(PartesError('Error al crear parte: ${e.toString()}'));
    }
  }

  Future<void> _onValidarParte(
    ValidarParte event,
    Emitter<PartesState> emit,
  ) async {
    emit(const PartesLoading());

    try {
      final parte = await _partesService.validarParte(
        parteId: event.parteId,
        validado: event.validado,
        observaciones: event.observaciones,
        isEmpresa: event.isEmpresa,
      );
      emit(ParteValidated(parte));
    } catch (e) {
      emit(PartesError('Error al validar parte: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshPartes(
    RefreshPartes event,
    Emitter<PartesState> emit,
  ) async {
    try {
      final role = await _storageService.getRole() ?? 'alumno';
      List<ParteDiario> partes;
      if (role == 'profesor' || role == 'empresa') {
        partes = await _partesService.getPartesPendientes(role);
      } else {
        partes = await _partesService.getPartes();
      }
      emit(PartesLoaded(partes));
    } catch (e) {
      emit(PartesError('Error al refrescar: ${e.toString()}'));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthBloc() : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Verifica si hay una sesión activa
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        final userData = await _authService.getCurrentUser();
        final role = await _authService.getCurrentRole();
        
        if (role == 'empresa') {
          // Para empresas, cargar datos desde storage
          final empresaData = await _storageService.getUser();
          emit(Authenticated(empresa: empresaData, role: role!));
        } else if (userData != null) {
          emit(Authenticated(user: userData, role: role ?? 'alumno'));
        } else {
          emit(const Unauthenticated());
        }
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Procesa el login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      Map<String, dynamic> response;
      
      if (event.userType == 'empresa') {
        response = await _authService.loginEmpresa(event.email, event.password);
        final empresaData = response['empresa'] as Map<String, dynamic>;
        final role = response['role'] as String;
        emit(Authenticated(empresa: empresaData, role: role));
      } else {
        response = await _authService.login(event.email, event.password);
        final userData = response['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        final role = response['role'] as String? ?? user.role;
        emit(Authenticated(user: user, role: role));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const Unauthenticated());
    }
  }

  /// Procesa el registro
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final response = await _authService.register(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
        role: event.role,
      );
      
      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);
      final role = response['role'] as String? ?? user.role;
      
      emit(Authenticated(user: user, role: role));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const Unauthenticated());
    }
  }

  /// Procesa el logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authService.logout();
      emit(const Unauthenticated());
    } catch (e) {
      // Siempre deslogear localmente aunque falle el servidor
      emit(const Unauthenticated());
    }
  }
}

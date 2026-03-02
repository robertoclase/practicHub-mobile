import 'package:equatable/equatable.dart';
import '../../../core/models/user.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado: Cargando (verificando sesión)
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado: Cargando (procesando login/registro)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado: Autenticado
class Authenticated extends AuthState {
  final User? user;
  final Map<String, dynamic>? empresa; // Si es empresa
  final String role;

  const Authenticated({
    this.user,
    this.empresa,
    required this.role,
  });

  @override
  List<Object?> get props => [user, empresa, role];

  bool get isAlumno => role == 'alumno';
  bool get isProfesor => role == 'profesor';
  bool get isEmpresa => role == 'empresa';
  bool get isAdmin => role == 'admin';
}

/// Estado: No autenticado
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Estado: Error de autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

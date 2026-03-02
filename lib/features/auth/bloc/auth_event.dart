import 'package:equatable/equatable.dart';

/// Eventos de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Verificar si hay sesión activa
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Evento: Iniciar sesión
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String userType; // 'user' o 'empresa'

  const LoginRequested({
    required this.email,
    required this.password,
     required this.userType,
  });

  @override
  List<Object?> get props => [email, password, userType];
}

/// Evento: Registrarse
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role; // 'alumno' o 'profesor'

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.role = 'alumno',
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation, role];
}

/// Evento: Cerrar sesión
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

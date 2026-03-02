import 'package:equatable/equatable.dart';

/// Modelo de Usuario (Alumno o Profesor)
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role; // 'admin', 'alumno', 'profesor', 'empresa'
  final int? profesorId; // Si es profesor, ID del registro en tabla profesors

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profesorId,
  });

  /// Convierte un valor a int, aceptando String o int
  static int _toInt(dynamic val) => val is int ? val : int.parse(val.toString());
  static int? _toIntOrNull(dynamic val) => val == null ? null : _toInt(val);

  /// Crea un User desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _toInt(json['id']),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'alumno',
      profesorId: _toIntOrNull(json['profesor_id']),
    );
  }

  /// Convierte el User a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (profesorId != null) 'profesor_id': profesorId,
    };
  }

  /// Verifica si el usuario es alumno
  bool get isAlumno => role == 'alumno';

  /// Verifica si el usuario es profesor
  bool get isProfesor => role == 'profesor';

  /// Verifica si el usuario es admin
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, name, email, role, profesorId];

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    int? profesorId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profesorId: profesorId ?? this.profesorId,
    );
  }
}

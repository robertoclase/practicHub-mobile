import 'package:equatable/equatable.dart';

/// Modelo de Empresa
class Empresa extends Equatable {
  final int id;
  final String nombre;
  final String cif;
  final String direccion;
  final String telefono;
  final String email;
  final String sector;
  final String tutorEmpresa;
  final String emailTutor;
  final bool activo;

  const Empresa({
    required this.id,
    required this.nombre,
    required this.cif,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.sector,
    required this.tutorEmpresa,
    required this.emailTutor,
    this.activo = true,
  });

  static int _toInt(dynamic val) => val is int ? val : int.parse(val.toString());

  /// Crea una Empresa desde JSON
  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: _toInt(json['id']),
      nombre: json['nombre'] as String? ?? '',
      cif: json['cif'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      email: json['email'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      tutorEmpresa: json['tutor_empresa'] as String? ?? '',
      emailTutor: json['email_tutor'] as String? ?? '',
      activo: json['activo'] == 1 || json['activo'] == true,
    );
  }

  /// Convierte la Empresa a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'cif': cif,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'sector': sector,
      'tutor_empresa': tutorEmpresa,
      'email_tutor': emailTutor,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        cif,
        direccion,
        telefono,
        email,
        sector,
        tutorEmpresa,
        emailTutor,
        activo,
      ];
}

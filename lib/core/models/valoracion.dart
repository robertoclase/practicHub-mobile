import 'package:equatable/equatable.dart';

/// Modelo de Valoración
class Valoracion extends Equatable {
  final int id;
  final int seguimientoPracticaId;
  final int profesorId;
  final int puntuacion; // 1-10
  final String aspectoValorado;
  final String comentarios;
  final DateTime? createdAt;

  // Relaciones opcionales
  final Map<String, dynamic>? seguimientoPractica;
  final Map<String, dynamic>? profesor;

  const Valoracion({
    required this.id,
    required this.seguimientoPracticaId,
    required this.profesorId,
    required this.puntuacion,
    required this.aspectoValorado,
    required this.comentarios,
    this.createdAt,
    this.seguimientoPractica,
    this.profesor,
  });

  static int _toInt(dynamic val) => val is int ? val : int.parse(val.toString());

  /// Crea una Valoracion desde JSON
  factory Valoracion.fromJson(Map<String, dynamic> json) {
    return Valoracion(
      id: _toInt(json['id']),
      seguimientoPracticaId: _toInt(json['seguimiento_practica_id']),
      profesorId: _toInt(json['profesor_id']),
      puntuacion: _toInt(json['puntuacion']),
      aspectoValorado: json['aspecto_valorado'] as String? ?? '',
      comentarios: json['comentarios'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      seguimientoPractica: json['seguimiento_practica'] as Map<String, dynamic>?,
      profesor: json['profesor'] as Map<String, dynamic>?,
    );
  }

  /// Convierte la Valoracion a JSON
  Map<String, dynamic> toJson() {
    return {
      'seguimiento_practica_id': seguimientoPracticaId,
      'puntuacion': puntuacion,
      'aspecto_valorado': aspectoValorado,
      'comentarios': comentarios,
    };
  }

  /// Obtiene el nombre del profesor si está disponible
  String get profesorNombre {
    if (profesor != null && profesor!['user'] != null) {
      return profesor!['user']['name'] as String? ?? 'Profesor #$profesorId';
    }
    return 'Profesor #$profesorId';
  }

  /// Convierte la puntuación a estrellas (de 5)
  double get estrellas => (puntuacion / 2.0);

  @override
  List<Object?> get props => [
        id,
        seguimientoPracticaId,
        profesorId,
        puntuacion,
        aspectoValorado,
        comentarios,
      ];
}

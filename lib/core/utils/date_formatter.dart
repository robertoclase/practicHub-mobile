import 'package:intl/intl.dart';

/// Utilidad para formatear fechas
class DateFormatter {
  /// Formatea una fecha a formato dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea una fecha a formato completo: 15 de marzo de 2026
  static String formatDateLong(DateTime date) {
    return DateFormat("d 'de' MMMM 'de' yyyy", 'es_ES').format(date);
  }

  /// Formatea una fecha a formato dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Parsea una cadena de fecha en formato yyyy-MM-dd
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// Convierte DateTime a String en formato yyyy-MM-dd (para API)
  static String toApiFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Calcula la diferencia de días entre dos fechas
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}

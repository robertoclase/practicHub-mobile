import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/storage_service.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_message.dart';
import '../bloc/seguimientos_bloc.dart';
import '../bloc/seguimientos_event.dart';
import '../bloc/seguimientos_state.dart';
import '../../../core/utils/date_formatter.dart';

class SeguimientoDetailPage extends StatelessWidget {
  final int seguimientoId;

  const SeguimientoDetailPage({
    super.key,
    required this.seguimientoId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SeguimientosBloc(
        seguimientosService: SeguimientosService(),
        storageService: StorageService(),
      )..add(LoadSeguimientoDetail(seguimientoId)),
      child: const SeguimientoDetailView(),
    );
  }
}

class SeguimientoDetailView extends StatelessWidget {
  const SeguimientoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Práctica'),
      ),
      body: BlocBuilder<SeguimientosBloc, SeguimientosState>(
        builder: (context, state) {
          if (state is SeguimientosLoading) {
            return const LoadingIndicator();
          }

          if (state is SeguimientosError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () {
                // No hacer nada, el usuario puede volver atrás
              },
            );
          }

          if (state is SeguimientoDetailLoaded) {
            final seguimiento = state.seguimiento;
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera con empresa
                  _HeaderSection(seguimiento: seguimiento),
                  
                  const SizedBox(height: 8),
                  
                  // Información del periodo
                  _PeriodoSection(seguimiento: seguimiento),
                  
                  const SizedBox(height: 8),
                  
                  // Información del alumno
                  _AlumnoSection(seguimiento: seguimiento),
                  
                  const SizedBox(height: 8),
                  
                  // Información del profesor tutor
                  if (seguimiento.profesor != null)
                    _ProfesorSection(profesor: seguimiento.profesor!),
                  
                  const SizedBox(height: 8),
                  
                  // Información de la empresa
                  if (seguimiento.empresa != null)
                    _EmpresaSection(empresa: seguimiento.empresa!),
                  
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final dynamic seguimiento;

  const _HeaderSection({required this.seguimiento});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.business_center,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            seguimiento.empresa?.nombre ?? 'Empresa no asignada',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            seguimiento.empresa?.direccion ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodoSection extends StatelessWidget {
  final dynamic seguimiento;

  const _PeriodoSection({required this.seguimiento});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fechaFin = DateFormatter.parseDate(seguimiento.fechaFin) ?? DateTime.now();
    final diasRestantes = DateFormatter.daysBetween(
      DateTime.now(),
      fechaFin,
    );
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Periodo de Prácticas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.play_arrow,
                    label: 'Fecha Inicio',
                    value: DateFormatter.formatDateLong(seguimiento.fechaInicio),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.stop,
                    label: 'Fecha Fin',
                    value: DateFormatter.formatDateLong(seguimiento.fechaFin),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (seguimiento.horasTotales != null)
              _InfoItem(
                icon: Icons.access_time,
                label: 'Horas Totales',
                value: '${seguimiento.horasTotales} horas',
                color: theme.colorScheme.primary,
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: diasRestantes > 0
                    ? Colors.blue[50]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    diasRestantes > 0
                        ? Icons.info_outline
                        : Icons.check_circle_outline,
                    color: diasRestantes > 0 ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      diasRestantes > 0
                          ? 'Quedan $diasRestantes días'
                          : 'Prácticas finalizadas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: diasRestantes > 0 ? Colors.blue[700] : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlumnoSection extends StatelessWidget {
  final dynamic seguimiento;

  const _AlumnoSection({required this.seguimiento});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Alumno',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoItem(
              icon: Icons.person,
              label: 'Nombre',
              value: seguimiento.alumno?.name ?? 'No especificado',
              color: theme.colorScheme.secondary,
            ),
            if (seguimiento.alumno?.email != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.email,
                label: 'Email',
                value: seguimiento.alumno!.email,
                color: theme.colorScheme.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfesorSection extends StatelessWidget {
  final dynamic profesor;

  const _ProfesorSection({required this.profesor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profesor Tutor',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoItem(
              icon: Icons.school,
              label: 'Nombre',
              value: profesor['user']?['name'] as String? ?? profesor['name'] as String? ?? '',
              color: Colors.purple,
            ),
            if (profesor['user']?['email'] != null || profesor['email'] != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.email,
                label: 'Email',
                value: profesor['user']?['email'] as String? ?? profesor['email'] as String? ?? '',
                color: Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmpresaSection extends StatelessWidget {
  final dynamic empresa;

  const _EmpresaSection({required this.empresa});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de la Empresa',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (empresa.cif != null)
              _InfoItem(
                icon: Icons.badge,
                label: 'CIF',
                value: empresa.cif,
                color: Colors.orange,
              ),
            if (empresa.telefono != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.phone,
                label: 'Teléfono',
                value: empresa.telefono,
                color: Colors.orange,
              ),
            ],
            if (empresa.emailContacto != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.email,
                label: 'Email de Contacto',
                value: empresa.emailContacto,
                color: Colors.orange,
              ),
            ],
            if (empresa.tutorEmpresa.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.person_outline,
                label: 'Persona de Contacto',
                value: empresa.tutorEmpresa,
                color: Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

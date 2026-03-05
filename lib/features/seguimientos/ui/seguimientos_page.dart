import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/storage_service.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_message.dart';
import '../../../widgets/empty_state.dart';
import '../bloc/seguimientos_bloc.dart';
import '../bloc/seguimientos_event.dart';
import '../bloc/seguimientos_state.dart';
import 'seguimiento_detail_page.dart';
import '../../../core/utils/date_formatter.dart';

class SeguimientosPage extends StatelessWidget {
  const SeguimientosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SeguimientosBloc(
        seguimientosService: SeguimientosService(),
        storageService: StorageService(),
      )..add(const LoadSeguimientos()),
      child: const SeguimientosView(),
    );
  }
}

class SeguimientosView extends StatelessWidget {
  const SeguimientosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Prácticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SeguimientosBloc>().add(const RefreshSeguimientos());
            },
          ),
        ],
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
                context.read<SeguimientosBloc>().add(const LoadSeguimientos());
              },
            );
          }

          if (state is SeguimientosLoaded) {
            if (state.seguimientos.isEmpty) {
              return const EmptyState(
                icon: Icons.business_center_outlined,
                message: 'No tienes prácticas asignadas',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SeguimientosBloc>().add(const RefreshSeguimientos());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.seguimientos.length,
                itemBuilder: (context, index) {
                  final seguimiento = state.seguimientos[index];
                  return _SeguimientoCard(seguimiento: seguimiento);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SeguimientoCard extends StatelessWidget {
  final dynamic seguimiento;

  const _SeguimientoCard({required this.seguimiento});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeguimientoDetailPage(seguimientoId: seguimiento.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Si viene el alumno (profesor/empresa viendo a sus alumnos), mostrar alumno
              // Si no (el propio alumno), mostrar empresa
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      seguimiento.alumno != null ? Icons.person : Icons.business,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Alumno viendo su práctica → muestra empresa
                          // Profesor/empresa → muestra nombre del alumno
                          seguimiento.alumno != null
                              ? (seguimiento.alumno?.name ?? 'Alumno')
                              : (seguimiento.empresa?.nombre ?? 'Empresa no asignada'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          seguimiento.alumno != null
                              ? (seguimiento.alumno?.email ?? '')
                              : (seguimiento.empresa?.direccion ?? ''),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Información del periodo
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: 'Inicio',
                    value: DateFormatter.formatDate(seguimiento.fechaInicio),
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.event,
                    label: 'Fin',
                    value: DateFormatter.formatDate(seguimiento.fechaFin),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Profesor tutor (si existe)
              if (seguimiento.profesor != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tutor: ${seguimiento.profesor?['user']?['name'] ?? seguimiento.profesor?['name'] ?? ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
              
              // Horas totales
              if (seguimiento.horasTotales != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Horas totales: ${seguimiento.horasTotales}h',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/storage_service.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_message.dart';
import '../../../widgets/custom_button.dart';
import '../../../core/utils/date_formatter.dart';
import '../bloc/partes_bloc.dart';
import '../bloc/partes_event.dart';
import '../bloc/partes_state.dart';

class ParteDetailPage extends StatelessWidget {
  final int parteId;

  const ParteDetailPage({
    super.key,
    required this.parteId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PartesBloc(
        partesService: PartesService(),
        storageService: StorageService(),
      )..add(LoadParteDetail(parteId)),
      child: const ParteDetailView(),
    );
  }
}

class ParteDetailView extends StatelessWidget {
  const ParteDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Parte'),
      ),
      body: BlocConsumer<PartesBloc, PartesState>(
        listener: (context, state) {
          if (state is ParteValidated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parte validado correctamente')),
            );
            // Recargar detalle
            final parteId = state.parte.id;
            context.read<PartesBloc>().add(LoadParteDetail(parteId));
          } else if (state is PartesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PartesLoading) {
            return const LoadingIndicator();
          }

          if (state is PartesError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () {
                // No hacer nada, puede volver atrás
              },
            );
          }

          if (state is ParteDetailLoaded) {
            final parte = state.parte;
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera con estado
                  _HeaderSection(parte: parte),
                  
                  const SizedBox(height: 8),
                  
                  // Información básica
                  _InfoSection(parte: parte),
                  
                  const SizedBox(height: 8),
                  
                  // Actividades
                  _ActividadesSection(parte: parte),
                  
                  // Incidencias (si existen)
                  if (parte.incidencias != null && parte.incidencias!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _IncidenciasSection(incidencias: parte.incidencias!),
                  ],
                  
                  // Observaciones (si existen)
                  if (parte.observaciones != null && parte.observaciones!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ObservacionesSection(observaciones: parte.observaciones!),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Validaciones
                  _ValidacionesSection(parte: parte),
                  
                  const SizedBox(height: 24),
                  
                  // Botones de validación (si corresponde)
                  _ValidationButtons(parte: parte),
                  
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
  final dynamic parte;

  const _HeaderSection({required this.parte});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValidado = parte.isValidatedByAll();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isValidado
              ? [Colors.green, Colors.green.shade700]
              : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValidado ? Icons.check_circle : Icons.schedule,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatDateLong(parte.fecha),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isValidado
                          ? 'Validado completamente'
                          : parte.isPartiallyValidated()
                              ? 'Validación parcial'
                              : 'Pendiente de validar',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final dynamic parte;

  const _InfoSection({required this.parte});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.access_time,
                label: 'Horas Trabajadas',
                value: '${parte.horasTrabajadas}h',
                color: theme.colorScheme.primary,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: _InfoItem(
                icon: Icons.calendar_today,
                label: 'Registrado',
                value: DateFormatter.formatDate(parte.createdAt ?? parte.fecha),
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActividadesSection extends StatelessWidget {
  final dynamic parte;

  const _ActividadesSection({required this.parte});

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
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Descripción de Actividades',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              parte.descripcionActividades ?? 'Sin descripción',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidenciasSection extends StatelessWidget {
  final String incidencias;

  const _IncidenciasSection({required this.incidencias});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Incidencias Reportadas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              incidencias,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.orange[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObservacionesSection extends StatelessWidget {
  final String observaciones;

  const _ObservacionesSection({required this.observaciones});

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
            Row(
              children: [
                Icon(
                  Icons.notes,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Observaciones',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              observaciones,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidacionesSection extends StatelessWidget {
  final dynamic parte;

  const _ValidacionesSection({required this.parte});

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
              'Estado de Validaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ValidacionItem(
              icon: Icons.school,
              label: 'Validación Profesor',
              isValidado: parte.validado == true,
              observaciones: parte.observacionesProfesor,
            ),
            const SizedBox(height: 12),
            _ValidacionItem(
              icon: Icons.business,
              label: 'Validación Empresa',
              isValidado: parte.validadoEmpresa == true,
              observaciones: parte.observacionesEmpresa,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidacionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isValidado;
  final String? observaciones;

  const _ValidacionItem({
    required this.icon,
    required this.label,
    required this.isValidado,
    this.observaciones,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValidado ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValidado ? Colors.green : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isValidado ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (observaciones != null && observaciones!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    observaciones!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            isValidado ? Icons.check_circle : Icons.pending,
            color: isValidado ? Colors.green : Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

class _ValidationButtons extends StatelessWidget {
  final dynamic parte;

  const _ValidationButtons({required this.parte});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StorageService().getRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final role = snapshot.data!;
        
        // Solo mostrar botones a profesores y empresas
        if (role != 'profesor' && role != 'empresa') {
          return const SizedBox.shrink();
        }
        
        // Verificar si ya está validado
        final yaValidado = role == 'profesor'
            ? parte.validado == true
            : parte.validadoEmpresa == true;
        
        if (yaValidado) {
          return const SizedBox.shrink();
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CustomButton(
                text: 'Validar Parte',
                onPressed: () => _showValidationDialog(context, true, role == 'empresa'),
                fullWidth: true,
                icon: Icons.check,
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Rechazar',
                onPressed: () => _showValidationDialog(context, false, role == 'empresa'),
                fullWidth: true,
                icon: Icons.close,
                backgroundColor: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showValidationDialog(BuildContext context, bool validar, bool isEmpresa) {
    final observacionesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(validar ? 'Validar Parte' : 'Rechazar Parte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              validar
                  ? '¿Confirmas que deseas validar este parte diario?'
                  : '¿Por qué rechazas este parte?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PartesBloc>().add(
                    ValidarParte(
                      parteId: parte.id,
                      validado: validar,
                      observaciones: observacionesController.text.isEmpty
                          ? null
                          : observacionesController.text,
                      isEmpresa: isEmpresa,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: validar ? Colors.green : Colors.red,
            ),
            child: Text(validar ? 'Validar' : 'Rechazar'),
          ),
        ],
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
    
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

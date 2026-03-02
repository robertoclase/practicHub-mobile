import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/storage_service.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_message.dart';
import '../../../widgets/empty_state.dart';
import '../../../core/utils/date_formatter.dart';
import '../bloc/partes_bloc.dart';
import '../bloc/partes_event.dart';
import '../bloc/partes_state.dart';
import 'crear_parte_page.dart';
import 'parte_detail_page.dart';

class PartesPage extends StatefulWidget {
  final int? seguimientoId;

  const PartesPage({super.key, this.seguimientoId});

  @override
  State<PartesPage> createState() => _PartesPageState();
}

class _PartesPageState extends State<PartesPage> {
  String _currentFilter = 'todos'; // todos, pendientes

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PartesBloc(
        partesService: PartesService(),
        storageService: StorageService(),
      )..add(LoadPartes(seguimientoId: widget.seguimientoId)),
      child: PartesView(
        seguimientoId: widget.seguimientoId,
        currentFilter: _currentFilter,
        onFilterChanged: (filter) {
          setState(() {
            _currentFilter = filter;
          });
        },
      ),
    );
  }
}

class PartesView extends StatelessWidget {
  final int? seguimientoId;
  final String currentFilter;
  final Function(String) onFilterChanged;

  const PartesView({
    super.key,
    this.seguimientoId,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partes Diarios'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              onFilterChanged(value);
              if (value == 'pendientes') {
                context.read<PartesBloc>().add(const LoadPartesPendientes());
              } else {
                context.read<PartesBloc>().add(LoadPartes(seguimientoId: seguimientoId));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'todos',
                child: Text('Todos los partes'),
              ),
              const PopupMenuItem(
                value: 'pendientes',
                child: Text('Pendientes de validar'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PartesBloc>().add(const RefreshPartes());
            },
          ),
        ],
      ),
      body: BlocConsumer<PartesBloc, PartesState>(
        listener: (context, state) {
          if (state is ParteCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parte creado correctamente')),
            );
            context.read<PartesBloc>().add(LoadPartes(seguimientoId: seguimientoId));
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
                context.read<PartesBloc>().add(LoadPartes(seguimientoId: seguimientoId));
              },
            );
          }

          if (state is PartesLoaded) {
            if (state.partes.isEmpty) {
              return EmptyState(
                icon: Icons.description_outlined,
                message: currentFilter == 'pendientes'
                    ? 'No hay partes pendientes'
                    : 'No tienes partes diarios registrados',
                actionLabel: seguimientoId != null ? 'Crear Parte' : null,
                onAction: seguimientoId != null
                    ? () => _navigateToCreateParte(context)
                    : null,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PartesBloc>().add(const RefreshPartes());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.partes.length,
                itemBuilder: (context, index) {
                  final parte = state.partes[index];
                  return _ParteCard(parte: parte);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: seguimientoId != null
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToCreateParte(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Parte'),
            )
          : null,
    );
  }

  void _navigateToCreateParte(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearPartePage(seguimientoId: seguimientoId!),
      ),
    ).then((_) {
      // Recargar después de crear
      context.read<PartesBloc>().add(LoadPartes(seguimientoId: seguimientoId));
    });
  }
}

class _ParteCard extends StatelessWidget {
  final dynamic parte;

  const _ParteCard({required this.parte});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValidadoCompleto = parte.isValidatedByAll();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParteDetailPage(parteId: parte.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con fecha y estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(parte).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(parte),
                      color: _getStatusColor(parte),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.formatDateLong(parte.fecha),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(parte),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(parte),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isValidadoCompleto)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Validado',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Información del parte
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.access_time,
                    label: 'Horas',
                    value: '${parte.horasTrabajadas}h',
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  if (parte.incidencias != null && parte.incidencias!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 14, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Con incidencias',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Descripción
              Text(
                parte.descripcionActividades ?? 'Sin descripción',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic parte) {
    if (parte.isValidatedByAll()) {
      return Colors.green;
    } else if (parte.isPartiallyValidated()) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  IconData _getStatusIcon(dynamic parte) {
    if (parte.isValidatedByAll()) {
      return Icons.check_circle;
    } else if (parte.isPartiallyValidated()) {
      return Icons.pending;
    } else {
      return Icons.schedule;
    }
  }

  String _getStatusText(dynamic parte) {
    if (parte.isValidatedByAll()) {
      return 'Validado completamente';
    } else if (parte.isPartiallyValidated()) {
      return 'Validación parcial';
    } else {
      return 'Pendiente de validar';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

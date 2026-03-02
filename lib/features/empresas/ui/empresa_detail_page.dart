import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_message.dart';
import '../bloc/empresas_bloc.dart';
import '../bloc/empresas_event.dart';
import '../bloc/empresas_state.dart';

class EmpresaDetailPage extends StatelessWidget {
  final int empresaId;

  const EmpresaDetailPage({
    super.key,
    required this.empresaId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmpresasBloc(
        empresasService: EmpresasService(),
      )..add(LoadEmpresaDetail(empresaId)),
      child: const EmpresaDetailView(),
    );
  }
}

class EmpresaDetailView extends StatelessWidget {
  const EmpresaDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Empresa'),
      ),
      body: BlocBuilder<EmpresasBloc, EmpresasState>(
        builder: (context, state) {
          if (state is EmpresasLoading) {
            return const LoadingIndicator();
          }

          if (state is EmpresasError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () {
                // No hacer nada, puede volver atrás
              },
            );
          }

          if (state is EmpresaDetailLoaded) {
            final empresa = state.empresa;
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera
                  _HeaderSection(empresa: empresa),
                  
                  const SizedBox(height: 8),
                  
                  // Información de contacto
                  _ContactoSection(empresa: empresa),
                  
                  const SizedBox(height: 8),
                  
                  // Información adicional
                  _InfoSection(empresa: empresa),
                  
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
  final dynamic empresa;

  const _HeaderSection({required this.empresa});

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
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            empresa.nombre,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (empresa.cif != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CIF: ${empresa.cif}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactoSection extends StatelessWidget {
  final dynamic empresa;

  const _ContactoSection({required this.empresa});

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
              'Información de Contacto',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (empresa.tutorEmpresa.isNotEmpty)
              _InfoItem(
                icon: Icons.person,
                label: 'Persona de Contacto',
                value: empresa.tutorEmpresa,
                color: Colors.blue,
              ),
            
            if (empresa.emailContacto != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.email,
                label: 'Email',
                value: empresa.emailContacto!,
                color: Colors.orange,
              ),
            ],
            
            if (empresa.telefono != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.phone,
                label: 'Teléfono',
                value: empresa.telefono!,
                color: Colors.green,
              ),
            ],
            
            if (empresa.telefonoContacto != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.phone_android,
                label: 'Teléfono Contacto',
                value: empresa.telefonoContacto!,
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final dynamic empresa;

  const _InfoSection({required this.empresa});

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
              'Información General',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (empresa.direccion != null)
              _InfoItem(
                icon: Icons.location_on,
                label: 'Dirección',
                value: empresa.direccion!,
                color: Colors.red,
              ),
            
            if (empresa.horario != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.access_time,
                label: 'Horario',
                value: empresa.horario!,
                color: theme.colorScheme.primary,
              ),
            ],
            
            if (empresa.sector != null) ...[
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.category,
                label: 'Sector',
                value: empresa.sector!,
                color: Colors.purple,
              ),
            ],
            
            if (empresa.descripcion != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descripción',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          empresa.descripcion!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
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

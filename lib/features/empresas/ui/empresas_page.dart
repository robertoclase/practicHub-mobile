import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_message.dart';
import '../../../widgets/empty_state.dart';
import '../bloc/empresas_bloc.dart';
import '../bloc/empresas_event.dart';
import '../bloc/empresas_state.dart';
import 'empresa_detail_page.dart';

class EmpresasPage extends StatelessWidget {
  const EmpresasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmpresasBloc(
        empresasService: EmpresasService(),
      )..add(const LoadEmpresas()),
      child: const EmpresasView(),
    );
  }
}

class EmpresasView extends StatefulWidget {
  const EmpresasView({super.key});

  @override
  State<EmpresasView> createState() => _EmpresasViewState();
}

class _EmpresasViewState extends State<EmpresasView> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar empresa...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (query) {
                  context.read<EmpresasBloc>().add(SearchEmpresas(query));
                },
              )
            : const Text('Empresas'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  context.read<EmpresasBloc>().add(const SearchEmpresas(''));
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EmpresasBloc>().add(const RefreshEmpresas());
            },
          ),
        ],
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
                context.read<EmpresasBloc>().add(const LoadEmpresas());
              },
            );
          }

          if (state is EmpresasLoaded) {
            if (state.empresas.isEmpty) {
              return EmptyState(
                icon: Icons.business_outlined,
                message: state.searchQuery != null
                    ? 'No se encontraron empresas para "${state.searchQuery}"'
                    : 'No hay empresas disponibles',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<EmpresasBloc>().add(const RefreshEmpresas());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.empresas.length,
                itemBuilder: (context, index) {
                  final empresa = state.empresas[index];
                  return _EmpresaCard(empresa: empresa);
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

class _EmpresaCard extends StatelessWidget {
  final dynamic empresa;

  const _EmpresaCard({required this.empresa});

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
              builder: (_) => EmpresaDetailPage(empresaId: empresa.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con icono y nombre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          empresa.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (empresa.cif != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'CIF: ${empresa.cif}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              
              if (empresa.direccion != null) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        empresa.direccion!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (empresa.telefono != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      empresa.telefono!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
              
              if (empresa.tutorEmpresa.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      empresa.tutorEmpresa,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
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

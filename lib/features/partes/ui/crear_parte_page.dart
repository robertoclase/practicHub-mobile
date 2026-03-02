import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/storage_service.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_formatter.dart';
import '../bloc/partes_bloc.dart';
import '../bloc/partes_event.dart';
import '../bloc/partes_state.dart';

class CrearPartePage extends StatefulWidget {
  final int seguimientoId;

  const CrearPartePage({
    super.key,
    required this.seguimientoId,
  });

  @override
  State<CrearPartePage> createState() => _CrearPartePageState();
}

class _CrearPartePageState extends State<CrearPartePage> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _horasController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _incidenciasController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Fecha por defecto: hoy
    _selectedDate = DateTime.now();
    _fechaController.text = DateFormatter.formatDate(_selectedDate!);
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horasController.dispose();
    _descripcionController.dispose();
    _incidenciasController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PartesBloc(
        partesService: PartesService(),
        storageService: StorageService(),
      ),
      child: BlocConsumer<PartesBloc, PartesState>(
        listener: (context, state) {
          if (state is ParteCreated) {
            Navigator.of(context).pop(true); // Retornar true para indicar éxito
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
          final isLoading = state is PartesLoading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Nuevo Parte Diario'),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info header
                        Card(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Registra tus actividades diarias durante las prácticas',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Fecha
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: _fechaController,
                              label: 'Fecha',
                              prefixIcon: Icons.calendar_today,
                              validator: Validators.validateRequired,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Horas trabajadas
                        CustomTextField(
                          controller: _horasController,
                          label: 'Horas trabajadas',
                          prefixIcon: Icons.access_time,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            final horas = int.tryParse(value);
                            if (horas == null) {
                              return 'Debe ser un número';
                            }
                            if (horas < 1 || horas > 12) {
                              return 'Debe estar entre 1 y 12 horas';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Descripción de actividades
                        CustomTextField(
                          controller: _descripcionController,
                          label: 'Descripción de actividades',
                          prefixIcon: Icons.description,
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            if (value.length < 20) {
                              return 'Mínimo 20 caracteres';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Incidencias (opcional)
                        CustomTextField(
                          controller: _incidenciasController,
                          label: 'Incidencias (opcional)',
                          prefixIcon: Icons.warning_amber,
                          maxLines: 3,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Observaciones (opcional)
                        CustomTextField(
                          controller: _observacionesController,
                          label: 'Observaciones (opcional)',
                          prefixIcon: Icons.notes,
                          maxLines: 3,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botón crear
                        CustomButton(
                          text: 'Crear Parte Diario',
                          onPressed: isLoading ? null : _handleSubmit,
                          isLoading: isLoading,
                          fullWidth: true,
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const LoadingIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaController.text = DateFormatter.formatDate(picked);
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una fecha')),
        );
        return;
      }

      context.read<PartesBloc>().add(
            CreateParte(
              seguimientoId: widget.seguimientoId,
              fecha: _selectedDate!,
              horasTrabajadas: int.parse(_horasController.text),
              descripcionActividades: _descripcionController.text,
              incidencias: _incidenciasController.text.isEmpty
                  ? null
                  : _incidenciasController.text,
              observaciones: _observacionesController.text.isEmpty
                  ? null
                  : _observacionesController.text,
            ),
          );
    }
  }
}

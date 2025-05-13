import 'package:flutter/material.dart';
import 'package:medialert/domain/entities/cima_medication.dart';
import 'package:medialert/presentation/providers/medication_provider.dart';
import 'package:medialert/presentation/widgets/time_picker_dialog.dart'
    as custom_time_picker;
import 'package:provider/provider.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _customFrequencyController = TextEditingController();
  final _notesController = TextEditingController();

  final List<DateTime> _reminders = [];
  String? _registrationNumber;
  bool _isSearching = false;

  // Opciones de frecuencia predefinidas
  final List<String> _frequencyOptions = [
    'Cada hora',
    'Cada 4 horas',
    'Cada 8 horas',
    'Otro'
  ];

  // Valor seleccionado del dropdown
  String _selectedFrequency = 'Cada 8 horas';

  // Flag para indicar si se está usando frecuencia personalizada
  bool _isCustomFrequency = false;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de frecuencia con el valor predeterminado
    _frequencyController.text = _selectedFrequency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _customFrequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addReminder() async {
    final time = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => const custom_time_picker.TimePickerDialog(),
    );

    if (time != null) {
      final now = DateTime.now();
      final reminder = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      setState(() {
        _reminders.add(reminder);
      });
    }
  }

  void _removeReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
  }

  void _searchMedication(String query) {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    Provider.of<MedicationProvider>(context, listen: false)
        .searchCimaMedicationsByName(query);
  }

  void _selectCimaMedication(CimaMedication medication) {
    setState(() {
      _nameController.text = medication.name;
      if (medication.dosage != null) {
        _dosageController.text = medication.dosage!;
      }
      _registrationNumber = medication.registrationNumber;
      _isSearching = false;
    });
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      if (_reminders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes añadir al menos un recordatorio'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Usar la frecuencia correcta (predefinida o personalizada)
      final frequency = _isCustomFrequency
          ? _customFrequencyController.text
          : _selectedFrequency;

      Provider.of<MedicationProvider>(context, listen: false).addMedication(
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: frequency,
        reminders: _reminders,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        registrationNumber: _registrationNumber,
      );

      Navigator.pop(context);
    }
  }

  // Método para generar recordatorios automáticos basados en la frecuencia
  void _generateAutomaticReminders(TimeOfDay firstDoseTime, String frequency) {
    // Limpiar recordatorios existentes
    setState(() {
      _reminders.clear();
    });

    // Hora de inicio seleccionada por el usuario
    final now = DateTime.now();
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
      firstDoseTime.hour,
      firstDoseTime.minute,
    );

    int intervalHours;
    int totalReminders = 4; // Siempre generar 4 recordatorios

    // Determinar intervalo según la frecuencia
    switch (frequency) {
      case 'Cada hora':
        intervalHours = 1;
        break;
      case 'Cada 4 horas':
        intervalHours = 4;
        break;
      case 'Cada 8 horas':
        intervalHours = 8;
        break;
      default:
        return; // No hacer nada para frecuencias personalizadas
    }

    // Generar recordatorios
    for (int i = 0; i < totalReminders; i++) {
      final reminderTime = startTime.add(Duration(hours: i * intervalHours));
      setState(() {
        _reminders.add(reminderTime);
      });
    }
  }

  // Método para mostrar el diálogo de selección de hora inicial
  Future<void> _showFirstDoseTimeDialog() async {
    final time = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => const custom_time_picker.TimePickerDialog(),
    );

    if (time != null) {
      _generateAutomaticReminders(time, _selectedFrequency);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Medicamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombre del Medicamento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ingresa el nombre del medicamento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _searchMedication(_nameController.text);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del medicamento';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.length > 3) {
                    _searchMedication(value);
                  }
                },
              ),
              if (_isSearching)
                Consumer<MedicationProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (provider.searchResults.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No se encontraron resultados'),
                      );
                    }

                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: provider.searchResults.length,
                        itemBuilder: (context, index) {
                          final medication = provider.searchResults[index];
                          return ListTile(
                            title: Text(medication.name),
                            subtitle: medication.activeIngredient != null
                                ? Text(medication.activeIngredient!)
                                : null,
                            onTap: () {
                              _selectCimaMedication(medication);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              const Text(
                'Dosis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  hintText: 'Ej: 500mg, 1 tableta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la dosis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Frecuencia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Reemplazar TextFormField por DropdownButtonFormField
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _selectedFrequency,
                items: _frequencyOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFrequency = newValue!;
                    _isCustomFrequency = newValue == 'Otro';

                    // Actualizar el controlador de frecuencia para mantener compatibilidad
                    _frequencyController.text = newValue;

                    // Si se selecciona una frecuencia predefinida, mostrar diálogo para hora inicial
                    if (newValue != 'Otro') {
                      _showFirstDoseTimeDialog();
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una frecuencia';
                  }
                  return null;
                },
              ),

              // Campo de texto para frecuencia personalizada (visible solo si se selecciona "Otro")
              if (_isCustomFrequency) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customFrequencyController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Dos veces al día, Cada 12 horas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (_isCustomFrequency &&
                        (value == null || value.isEmpty)) {
                      return 'Por favor ingresa la frecuencia personalizada';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recordatorios',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir'),
                    onPressed: _addReminder,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_reminders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No hay recordatorios configurados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        '${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeReminder(index),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              const Text(
                'Notas (Opcional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Añade notas adicionales',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMedication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

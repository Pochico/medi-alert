import 'package:flutter/material.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/presentation/providers/medication_provider.dart';
import 'package:medialert/presentation/widgets/time_picker_dialog.dart'
    as custom_time_picker;
import 'package:provider/provider.dart';

class EditMedicationScreen extends StatefulWidget {
  final String medicationId;

  const EditMedicationScreen({
    super.key,
    required this.medicationId,
  });

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _notesController = TextEditingController();

  List<DateTime> _reminders = [];
  String? _registrationNumber;
  // ignore: unused_field
  Medication? _medication;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMedicationDetails();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicationDetails() async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    await provider.loadMedications();

    if (!mounted) return;

    final medication = provider.medications.firstWhere(
      (med) => med.id == widget.medicationId,
      orElse: () => throw Exception('Medicamento no encontrado'),
    );

    setState(() {
      _medication = medication;
      _nameController.text = medication.name;
      _dosageController.text = medication.dosage;
      _frequencyController.text = medication.frequency;
      _notesController.text = medication.notes ?? '';
      _reminders = List.from(medication.reminders);
      _registrationNumber = medication.registrationNumber;
      _isLoading = false;
    });
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

  void _updateMedication() {
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

      Provider.of<MedicationProvider>(context, listen: false).editMedication(
        id: widget.medicationId,
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
        reminders: _reminders,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        registrationNumber: _registrationNumber,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Medicamento'),
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del medicamento';
                  }
                  return null;
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
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(
                  hintText: 'Ej: Cada 8 horas, Una vez al día',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la frecuencia';
                  }
                  return null;
                },
              ),
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
                  onPressed: _updateMedication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Actualizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:medialert/core/utils/time_format_util.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/presentation/providers/medication_provider.dart';
import 'package:medialert/presentation/routes/app_router.dart';
import 'package:provider/provider.dart';

class MedicationDetailsScreen extends StatefulWidget {
  final String medicationId;

  const MedicationDetailsScreen({
    super.key,
    required this.medicationId,
  });

  @override
  State<MedicationDetailsScreen> createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  Medication? _medication;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMedicationDetails();
    });
  }

  Future<void> _loadMedicationDetails() async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    await provider.loadMedications();

    if (!mounted) return;

    setState(() {
      _medication = provider.medications.firstWhere(
        (med) => med.id == widget.medicationId,
        orElse: () => throw Exception('Medicamento no encontrado'),
      );
      _isLoading = false;
    });
  }

  void _recordIntake() {
    if (_medication == null) return;

    Provider.of<MedicationProvider>(context, listen: false)
        .recordMedicationIntake(
      medicationId: _medication!.id,
      medicationName: _medication!.name,
      dosage: _medication!.dosage,
      intakeTime: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toma registrada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_medication == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Medicamento'),
        ),
        body: const Center(
          child: Text('Medicamento no encontrado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Medicamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.editMedicationRoute,
                arguments: _medication!.id,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _medication!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dosis: ${_medication!.dosage}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Frecuencia: ${_medication!.frequency}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recordatorios',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: true,
                          onChanged: (value) {
                            // Implementar lógica para activar/desactivar recordatorios
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _medication!.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _medication!.reminders[index];
                        return ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            TimeFormatUtil.formatTime(context, reminder),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_medication!.notes != null &&
                _medication!.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _medication!.notes!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _recordIntake,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Registrar Toma'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Implementar lógica para eliminar medicamento
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.red,
                ),
                child: const Text('Eliminar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

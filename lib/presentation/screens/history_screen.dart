import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medialert/presentation/providers/medication_provider.dart';
import 'package:medialert/presentation/widgets/intake_card.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _filterMedicationName;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicationProvider>(context, listen: false)
          .loadMedicationIntakes();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Historial'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre del medicamento',
                hintText: 'Dejar en blanco para todos',
              ),
              onChanged: (value) {
                _filterMedicationName = value.isEmpty ? null : value;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    child: Text(_startDate == null
                        ? 'Fecha inicio'
                        : DateFormat('dd/MM/yyyy').format(_startDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: Text(_endDate == null
                        ? 'Fecha fin'
                        : DateFormat('dd/MM/yyyy').format(_endDate!)),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<MedicationProvider>(context, listen: false)
                  .filterIntakes(
                medicationName: _filterMedicationName,
                startDate: _startDate,
                endDate: _endDate,
              );
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Tomas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.intakes.isEmpty) {
            return const Center(
              child: Text(
                'No hay registros de tomas',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Ordenar por fecha más reciente
          final sortedIntakes = List.from(provider.intakes)
            ..sort((a, b) => b.intakeTime.compareTo(a.intakeTime));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedIntakes.length,
            itemBuilder: (context, index) {
              final intake = sortedIntakes[index];
              return IntakeCard(intake: intake);
            },
          );
        },
      ),
    );
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medialert/core/error/exceptions.dart';
import 'package:medialert/data/models/cima_medication_model.dart';

abstract class CimaRemoteDataSource {
  Future<List<CimaMedicationModel>> searchMedications(String query);
  Future<CimaMedicationModel> getMedicationDetails(String registrationNumber);
}

class CimaRemoteDataSourceImpl implements CimaRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'https://cima.aemps.es/cima/rest';

  CimaRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CimaMedicationModel>> searchMedications(String query) async {
    final response = await client.get(
      Uri.parse('$baseUrl/medicamentos?nombre=$query'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> resultsList = jsonResponse['resultados'] ?? [];

      return resultsList
          .map((json) => CimaMedicationModel.fromJson(json))
          .toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<CimaMedicationModel> getMedicationDetails(
      String registrationNumber) async {
    final response = await client.get(
      Uri.parse('$baseUrl/medicamento?nregistro=$registrationNumber'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return CimaMedicationModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}

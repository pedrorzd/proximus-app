import 'dart:convert'; // Necessário para decodificar a resposta JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa o pacote http
import 'api_keys.dart'; // Importa nossa chave de API

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _addressController = TextEditingController();

  // Transformamos a função em "async" para poder esperar a resposta da internet
  void _searchAddress() async {
    final address = _addressController.text;
    if (address.isEmpty) {
      print('O campo de endereço está vazio.');
      return; // Encerra a função se não há texto
    }

    // 1. Construindo a URL para a API de Geocoding
    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$googleApiKey');

    try {
      // 2. Fazendo a requisição HTTP e esperando (await) a resposta
      final response = await http.get(url);

      // 3. Verificando se a requisição foi bem sucedida (código 200)
      if (response.statusCode == 200) {
        // 4. Decodificando a resposta JSON para um formato que o Dart entende (Map)
        final body = json.decode(response.body);

        // 5. Extraindo a latitude e longitude do resultado
        if (body['status'] == 'OK') {
          final location = body['results'][0]['geometry']['location'];
          final double lat = location['lat'];
          final double lng = location['lng'];

          print('Endereço encontrado com sucesso!');
          print('Latitude: $lat, Longitude: $lng');

          // PRÓXIMO PASSO: Usar essas coordenadas para mostrar o mapa!

        } else {
          print('Erro da API do Google: ${body['error_message']}');
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Ocorreu um erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // O build do widget continua exatamente o mesmo de antes
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proximus - Avalie sua Localidade'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Digite um endereço',
                border: OutlineInputBorder(),
                hintText: 'Ex: Av. Paulista, 1000, São Paulo',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchAddress,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Buscar Localização',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
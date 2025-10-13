import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import do geolocator
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'api_keys.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _addressController = TextEditingController();

  GoogleMapController? _mapController;
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-23.55052, -46.633308),
    zoom: 12,
  );

  final Set<Marker> _markers = {};

  // NOVO: Lista de serviços essenciais que vamos procurar
  final List<String> _essentialServices = [
    'supermarket',
    'pharmacy',
    'hospital',
    'school',
    'bakery', // Padaria
  ];

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToPlace(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );
  }

  // MODIFICADO: Agora a função aceita o "tipo" de local a ser buscado
  Future<void> _searchNearbyPlaces(double lat, double lng, String placeType) async {
    const double radius = 1500;

    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$placeType&key=$googleApiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['status'] == 'OK') {
          final List<dynamic> results = body['results'];
          if (results.isEmpty) {
            print('Nenhum(a) $placeType encontrado(a) por perto.');
            return;
          }

          // Lógica para encontrar o local mais próximo
          double minDistance = double.infinity;
          Map<String, dynamic>? closestPlace;

          for (var place in results) {
            final placeLocation = place['geometry']['location'];
            final double placeLat = placeLocation['lat'];
            final double placeLng = placeLocation['lng'];

            // Usando o geolocator para calcular a distância em metros
            final double distance = Geolocator.distanceBetween(lat, lng, placeLat, placeLng);

            if (distance < minDistance) {
              minDistance = distance;
              closestPlace = place;
            }
          }

          if (closestPlace != null) {
            final String name = closestPlace['name'];
            print('--- O(A) $placeType MAIS PRÓXIMO(A) É: ---');
            print('$name (${minDistance.toStringAsFixed(0)} metros)');
            print('-----------------------------------------');
          }

        } else {
          print('Places API Error para $placeType: ${body['error_message']}');
        }
      }
    } catch (e) {
      print('Ocorreu um erro ao buscar por $placeType: $e');
    }
  }

  void _searchAddress() async {
    // ... (início da função continua o mesmo)
    final address = _addressController.text;
    if (address.isEmpty) {
      print('O campo de endereço está vazio.');
      return;
    }

    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$googleApiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'OK') {
          final location = body['results'][0]['geometry']['location'];
          final double lat = location['lat'];
          final double lng = location['lng'];

          _goToPlace(lat, lng);
          setState(() {
            _markers.clear();
            _markers.add(Marker(
              markerId: const MarkerId('searched_location'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: 'Localização Encontrada', snippet: address),
            ));
          });

          print('\n--- BUSCANDO SERVIÇOS ESSENCIAIS ---');
          // MODIFICADO: Fazemos um loop e buscamos cada serviço da nossa lista
          for (String service in _essentialServices) {
            await _searchNearbyPlaces(lat, lng, service);
          }

        } else { /* ... (tratamento de erro continua o mesmo) */ }
      }
    } catch (e) { /* ... (tratamento de erro continua o mesmo) */ }
  }

  @override
  Widget build(BuildContext context) {
    // A função build continua exatamente a mesma
    return Scaffold(
      appBar: AppBar( /* ... */ ),
      body: Column( /* ... */ ),
    );
  }
}
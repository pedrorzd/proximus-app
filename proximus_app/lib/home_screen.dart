import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'api_keys.dart';

// MODIFICADO: Classe PlaceInfo agora guarda as coordenadas do local
class PlaceInfo {
  final String name;
  final String type;
  final double distanceInMeters;
  final double lat; // Latitude do local encontrado
  final double lng; // Longitude do local encontrado

  PlaceInfo({
    required this.name,
    required this.type,
    required this.distanceInMeters,
    required this.lat,
    required this.lng,
  });

  String get distanceString {
    return '${distanceInMeters.toStringAsFixed(0)} metros';
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- (Variáveis de estado não mudam) ---
  final TextEditingController _addressController = TextEditingController();
  GoogleMapController? _mapController;
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-23.55052, -46.633308),
    zoom: 12,
  );
  final Set<Marker> _markers = {};
  final List<PlaceInfo> _nearbyPlacesList = [];
  bool _isLoading = false;
  bool _searchCompleted = false;

  double? _lastSearchedLat;
  double? _lastSearchedLng;

  double? _locationScore;
  final List<String> _locationHighlights = [];

  final Map<String, bool> _essentialServices = {
    'supermarket': true,
    'pharmacy': true,
    'hospital': true,
    'school': true,
    'bakery': true,
  };

  // --- (Funções de UI _onMapCreated, _goToPlace, _formatPlaceType, _getIconForPlaceType não mudam) ---
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
  String _formatPlaceType(String type) {
    switch (type) {
      case 'supermarket': return 'Supermercado';
      case 'pharmacy': return 'Farmácia';
      case 'hospital': return 'Hospital';
      case 'school': return 'Escola';
      case 'bakery': return 'Padaria';
      default: return type;
    }
  }
  IconData _getIconForPlaceType(String type) {
    switch (type) {
      case 'supermarket': return Icons.shopping_cart;
      case 'pharmacy': return Icons.local_pharmacy;
      case 'hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'bakery': return Icons.bakery_dining;
      default: return Icons.place;
    }
  }

  // MODIFICADO: Função agora NÃO mexe em 'tempMarkers'
  // Ela apenas encontra o local e retorna o objeto PlaceInfo completo
  Future<PlaceInfo?> _fetchClosestPlace(double lat, double lng, String placeType) async {
    const double radius = 1500;
    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$placeType&key=$googleApiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'OK') {
          final List<dynamic> results = body['results'];
          if (results.isEmpty) return null;
          double minDistance = double.infinity;
          Map<String, dynamic>? closestPlace;
          for (var place in results) {
            final placeLocation = place['geometry']['location'];
            final distance = Geolocator.distanceBetween(lat, lng, placeLocation['lat'], placeLocation['lng']);
            if (distance < minDistance) {
              minDistance = distance;
              closestPlace = place;
            }
          }
          if (closestPlace != null) {
            final String name = closestPlace['name'];
            final placeLocation = closestPlace['geometry']['location'];
            final double placeLat = placeLocation['lat'];
            final double placeLng = placeLocation['lng'];

            // Retorna o objeto PlaceInfo completo
            return PlaceInfo(
              name: name,
              type: placeType,
              distanceInMeters: minDistance,
              lat: placeLat,
              lng: placeLng,
            );
          }
        }
      }
    } catch (e) {
      print('Ocorreu um erro ao buscar por $placeType: $e');
    }
    return null;
  }

  // --- (Função _calculateLocationScore não muda) ---
  Map<String, dynamic> _calculateLocationScore(List<PlaceInfo> places) {
    double score = 0.0;
    List<String> highlights = [];
    const double proximityThreshold = 1000.0;
    if (places.any((place) => place.type == 'supermarket' && place.distanceInMeters <= proximityThreshold)) {
      score += 2;
      highlights.add('Perto de Supermercado');
    }
    if (places.any((place) => place.type == 'pharmacy' && place.distanceInMeters <= proximityThreshold)) {
      score += 2;
      highlights.add('Perto de Farmácia');
    }
    if (places.any((place) => place.type == 'hospital' && place.distanceInMeters <= proximityThreshold)) {
      score += 2;
      highlights.add('Perto de Hospital');
    }
    if (places.any((place) => place.type == 'school' && place.distanceInMeters <= proximityThreshold)) {
      score += 2;
      highlights.add('Perto de Escola');
    }
    if (places.any((place) => place.type == 'bakery' && place.distanceInMeters <= proximityThreshold)) {
      score += 2;
      highlights.add('Perto de Padaria');
    }
    return {'score': score, 'highlights': highlights};
  }

  // MODIFICADO: Função agora faz buscas em PARALELO
  Future<void> _performNearbySearch() async {
    if (_lastSearchedLat == null || _lastSearchedLng == null) return;

    setState(() {
      _isLoading = true;
      _searchCompleted = false;
      _markers.clear();
      _nearbyPlacesList.clear();
      _locationScore = 0.0;
      _locationHighlights.clear();
    });

    final Set<Marker> tempMarkers = {};
    final List<PlaceInfo> tempList = [];

    // 1. Adiciona o marcador principal (do endereço)
    tempMarkers.add(Marker(
      markerId: const MarkerId('searched_location'),
      position: LatLng(_lastSearchedLat!, _lastSearchedLng!),
      infoWindow: InfoWindow(title: 'Localização Encontrada', snippet: _addressController.text),
    ));

    // 2. Cria a lista de serviços a serem buscados
    final List<String> selectedServices = [];
    _essentialServices.forEach((service, isSelected) {
      if (isSelected) {
        selectedServices.add(service);
      }
    });

    // 3. (NOVO) Prepara a lista de "Futuros" (chamadas de API)
    final List<Future<PlaceInfo?>> searchFutures = [];

    for (String service in selectedServices) {
      // Adiciona a chamada de API à lista, SEM 'await'
      searchFutures.add(
          _fetchClosestPlace(_lastSearchedLat!, _lastSearchedLng!, service)
      );
    }

    // 4. (NOVO) Executa TODAS as buscas em paralelo e espera por elas
    final List<PlaceInfo?> results = await Future.wait(searchFutures);

    // 5. (NOVO) Processa os resultados que voltaram
    for (final placeInfo in results) {
      if (placeInfo != null) {
        // Adiciona o resultado à lista da UI
        tempList.add(placeInfo);

        // Adiciona o marcador para este local
        tempMarkers.add(
          Marker(
            markerId: MarkerId('marker_${placeInfo.type}'),
            position: LatLng(placeInfo.lat, placeInfo.lng),
            infoWindow: InfoWindow(
              title: placeInfo.name,
              snippet: '${_formatPlaceType(placeInfo.type)} (${placeInfo.distanceString})',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ),
        );
      }
    }

    // 6. Calcula a nota (como antes)
    final Map<String, dynamic> scoreResult = _calculateLocationScore(tempList);
    final double score = scoreResult['score'];
    final List<String> highlights = scoreResult['highlights'];

    // 7. Atualiza a tela UMA VEZ com todos os dados
    setState(() {
      _markers.addAll(tempMarkers);
      _nearbyPlacesList.addAll(tempList);
      _locationScore = score;
      _locationHighlights.addAll(highlights);
      _isLoading = false;
      _searchCompleted = true;
    });
  }

  // --- (Função _searchAddress não muda) ---
  void _searchAddress() async {
    FocusScope.of(context).unfocus();
    final address = _addressController.text;
    if (address.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchCompleted = false;
      _markers.clear();
      _nearbyPlacesList.clear();
      _lastSearchedLat = null;
      _lastSearchedLng = null;
      _locationScore = 0.0;
      _locationHighlights.clear();
    });

    try {
      final Uri url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$googleApiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'OK') {
          final location = body['results'][0]['geometry']['location'];
          _lastSearchedLat = location['lat'];
          _lastSearchedLng = location['lng'];
          _goToPlace(_lastSearchedLat!, _lastSearchedLng!);
          await _performNearbySearch(); // Chama a função paralela
          return;
        }
      }
    } catch (e) {
      print('Ocorreu um erro CATASTRÓFICO na busca: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // --- (Função _buildFilterChips não muda) ---
  // MODIFICADO: Widget para construir os chips de filtro (Layout 3-2)
  Widget _buildFilterChips() {
    // Helper local para criar um chip individual (evita repetição de código)
    Widget buildChip(String serviceKey) {
      return FilterChip(
        label: Text(_formatPlaceType(serviceKey)),
        selected: _essentialServices[serviceKey]!,
        avatar: Icon(
          _getIconForPlaceType(serviceKey),
          size: 18,
        ),
        selectedColor: Colors.deepPurple.withOpacity(0.2),
        onSelected: (bool selected) {
          setState(() {
            _essentialServices[serviceKey] = selected;
          });
          if (_searchCompleted) {
            _performNearbySearch();
          }
        },
      );
    }

    // Retorna a estrutura de layout 3-2 centralizada
    return Column(
      children: [
        // Fileira de Cima (3 filtros)
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza a fileira
          children: [
            buildChip('school'),
            const SizedBox(width: 8.0),
            buildChip('bakery'),
            const SizedBox(width: 8.0),
            buildChip('hospital'),
          ],
        ),
        // Espaço entre as fileiras
        const SizedBox(height: 4.0),
        // Fileira de Baixo (2 filtros)
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza a fileira
          children: [
            buildChip('supermarket'),
            const SizedBox(width: 8.0),
            buildChip('pharmacy'),
          ],
        ),
      ],
    );
  }
  // --- (Método build() da UI não muda) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proximus - Avalie sua Localidade'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // PARTE 1: Barra de busca e filtros
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Digite um endereço',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _searchAddress(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchAddress,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  )
                      : const Text('Buscar Localização'),
                ),
                const SizedBox(height: 10),
                _buildFilterChips(),
              ],
            ),
          ),

          // PARTE 2: Mapa e Gaveta de Resultados
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: _initialCameraPosition,
                  markers: _markers,
                ),

                if (_searchCompleted)
                  DraggableScrollableSheet(
                    initialChildSize: 0.4,
                    minChildSize: 0.1,
                    maxChildSize: 0.8,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // Puxador
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            // Nota e Destaques
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Nota da Localidade (0-10):',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black54),
                                    ),
                                    Text(
                                      _locationScore?.toStringAsFixed(1) ?? '0.0',
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        alignment: WrapAlignment.center,
                                        children: _locationHighlights.isNotEmpty
                                            ? _locationHighlights.map((highlight) => Chip(
                                          label: Text(highlight, style: const TextStyle(fontSize: 12)),
                                          avatar: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                          backgroundColor: Colors.green.withOpacity(0.1),
                                        )).toList()
                                            : [
                                          Chip(
                                            label: const Text('Nenhum serviço essencial muito próximo', style: TextStyle(fontSize: 12)),
                                            avatar: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 16),
                                            backgroundColor: Colors.orange.withOpacity(0.1),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Divider(indent: 16, endIndent: 16),

                            // Título da Lista
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Locais Mais Próximos:',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),

                            // A Lista de Cards (ListView.builder)
                            _nearbyPlacesList.isEmpty
                                ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _essentialServices.values.any((isSelected) => isSelected)
                                    ? const Text('Nenhum serviço selecionado encontrado nas proximidades.')
                                    : const Text('Nenhum filtro selecionado. Marque os serviços que deseja buscar.'),
                              ),
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: _nearbyPlacesList.length,
                              itemBuilder: (context, index) {
                                final place = _nearbyPlacesList[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: Icon(
                                      _getIconForPlaceType(place.type),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(_formatPlaceType(place.type)),
                                    trailing: Text(place.distanceString),
                                    dense: true,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
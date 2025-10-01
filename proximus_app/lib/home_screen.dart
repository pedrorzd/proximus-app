import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controlador para pegar o texto que o usuário digitar
  final TextEditingController _addressController = TextEditingController();

  void _searchAddress() {
    final address = _addressController.text;
    if (address.isNotEmpty) {
      // Por enquanto, vamos apenas imprimir o endereço no console
      // Aqui é onde vamos chamar a API do Google no futuro!
      print('Endereço buscado: $address');
    } else {
      print('O campo de endereço está vazio.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Campo de texto para o endereço
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Digite um endereço',
                border: OutlineInputBorder(),
                hintText: 'Ex: Av. Paulista, 1000, São Paulo',
              ),
            ),
            const SizedBox(height: 20), // Um pequeno espaço vertical

            // Botão para buscar
            ElevatedButton(
              onPressed: _searchAddress, // Chama nossa função de busca
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
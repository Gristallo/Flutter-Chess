import 'package:flutter/material.dart';
import 'chess_board_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedDifficulty = 'facile'; // Valore di default

  // Metodo per navigare alla schermata di gioco, passando la difficoltà
  void _navigateToGame(BuildContext context, bool vsComputer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessBoardScreen(
          vsComputer: vsComputer,
          aiDepth: _getAiDepth(_selectedDifficulty), // Passa il livello di difficoltà
        ),
      ),
    );
  }

  // Funzione che restituisce il livello di profondità dell'IA
  int _getAiDepth(String difficulty) {
  if (difficulty == 'facile') {
    return 2; // Facile: Mossa casuale
  } else if (difficulty == 'medio') {
    return 4; // Medio: Profondità 4
  } else {
    return 6; // Difficile: Profondità 6
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dropdown per selezionare la difficoltà
            DropdownButton<String>(
              value: _selectedDifficulty,
              items: <String>['facile', 'medio', 'difficile']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDifficulty = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToGame(context, false),
              child: const Text('1 vs 1'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToGame(context, true),
              child: const Text('Sfida il PC'),
            ),
          ],
        ),
      ),
    );
  }
}



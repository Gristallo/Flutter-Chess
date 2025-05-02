import 'package:flutter/material.dart';
import 'package:chess_game/screens/chess_board_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedDifficulty = 'facile'; 
  int _selectedTime = 3; 
  bool _useTimer = false; 

  // Metodo per iniziare il gioco con il timer
  void _startGame(BuildContext context) {
    int selectedTimeInSeconds = 180; 

    // Imposta il tempo in base alla selezione dell'utente
    if (_selectedTime == 3) {
      selectedTimeInSeconds = 180;  
    } else if (_selectedTime == 5) {
      selectedTimeInSeconds = 300;  
    } else if (_selectedTime == 10) {
      selectedTimeInSeconds = 600;  
    }

    // Avvia il gioco con il timer e la modalità selezionata
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessBoardScreen(
          vsComputer: false,  // Modalità 1v1
          aiDepth: _getAiDepth(_selectedDifficulty),
          useTimer: _useTimer,  // Passa il valore del timer
          initialTime: selectedTimeInSeconds,  // Passa il tempo iniziale selezionato
        ),
      ),
    );
  }

  // Funzione per ottenere la profondità dell'IA in base alla difficoltà (da cambiare)
  int _getAiDepth(String difficulty) {
    if (difficulty == 'facile') {
      return 2;
    } else if (difficulty == 'medio') {
      return 4;
    } else {
      return 6;
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
            // Dropdown per selezionare il tempo
            DropdownButton<int>(
              value: _selectedTime,
              items: <int>[3, 5, 10]
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value minuti'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedTime = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            // Switch per abilitare/disabilitare il timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Abilita Timer: '),
                Switch(
                  value: _useTimer,
                  onChanged: (bool value) {
                    setState(() {
                      _useTimer = value; 
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startGame(context), // Avvia il gioco 1v1
              child: const Text('1 vs 1'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Avvia il gioco contro il PC, senza timer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChessBoardScreen(
                      vsComputer: true,  // Modalità contro il PC
                      aiDepth: _getAiDepth(_selectedDifficulty),
                      useTimer: false,  // Disabilita il timer quando si gioca contro il PC
                      initialTime: 0, 
                    ),
                  ),
                );
              },
              child: const Text('Sfida il PC'),
            ),
          ],
        ),
      ),
    );
  }
}







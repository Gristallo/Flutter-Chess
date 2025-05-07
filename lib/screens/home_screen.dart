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

  // Funzione per avviare il gioco 1vs1
  void _start1v1Game(BuildContext context) {
    int selectedTimeInSeconds = _selectedTime == 3
        ? 180
        : _selectedTime == 5
            ? 300
            : 600;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessBoardScreen(
          vsComputer: false, // Per 1vs1, il gioco non deve essere contro il PC
          aiDepth: 0, // Non ha senso passare aiDepth in modalità 1vs1
          useTimer: _useTimer,
          initialTime: selectedTimeInSeconds,
        ),
      ),
    );
  }

  // Funzione per avviare il gioco contro il PC con la difficoltà scelta
  void _startGameAgainstComputer(BuildContext context, String difficulty) {
    int selectedTimeInSeconds = _selectedTime == 3
        ? 180
        : _selectedTime == 5
            ? 300
            : 600;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessBoardScreen(
          vsComputer: true, // Attiva la modalità contro il PC
          aiDepth: _getAiDepth(difficulty), // Passa la difficoltà
          useTimer: _useTimer,
          initialTime: selectedTimeInSeconds,
        ),
      ),
    );
  }

  int _getAiDepth(String difficulty) {
    if (difficulty == 'facile') {
      return 2;
    } else if (difficulty == 'medio') {
      return 4;
    } else {
      return 6;
    }
  }

  // Mostra il dialogo per scegliere il timer
  void _showTimerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona il Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('3 minuti'),
                onTap: () {
                  setState(() {
                    _selectedTime = 3;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('5 minuti'),
                onTap: () {
                  setState(() {
                    _selectedTime = 5;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('10 minuti'),
                onTap: () {
                  setState(() {
                    _selectedTime = 10;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Mostra il dialogo per selezionare la difficoltà
  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona la Difficoltà'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Facile'),
                onTap: () {
                  setState(() {
                    _selectedDifficulty = 'facile';
                  });
                  Navigator.of(context).pop();
                  _startGameAgainstComputer(context, 'facile'); // Passa la difficoltà 'facile'
                },
              ),
              ListTile(
                title: const Text('Medio'),
                onTap: () {
                  setState(() {
                    _selectedDifficulty = 'medio';
                  });
                  Navigator.of(context).pop();
                  _startGameAgainstComputer(context, 'medio'); // Passa la difficoltà 'medio'
                },
              ),
              ListTile(
                title: const Text('Difficile'),
                onTap: () {
                  setState(() {
                    _selectedDifficulty = 'difficile';
                  });
                  Navigator.of(context).pop();
                  _startGameAgainstComputer(context, 'difficile'); // Passa la difficoltà 'difficile'
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Seleziona la modalità di gioco',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/images/chess_logo.png', height: 120),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _start1v1Game(context), // Avvia il gioco 1vs1
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800], 
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('1 vs 1', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showDifficultyDialog(context); // Mostra il dialogo per selezionare la difficoltà
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800], 
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Sfida il PC', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Abilita Timer: ', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: _useTimer,
                    onChanged: (bool value) {
                      setState(() {
                        _useTimer = value;
                      });
                      if (_useTimer) {
                        _showTimerDialog(); // Mostra il dialogo per il timer quando attivato
                      }
                    },
                    activeColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}















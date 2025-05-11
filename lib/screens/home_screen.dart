import 'package:flutter/material.dart';
import 'package:chess_game/screens/chess_board_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedDifficultyLabel = 'Facile'; 
  int _selectedTime = 3;
  bool _useTimer = false;

  // Funzione per avviare il gioco 1vs1
  void _start1v1Game(BuildContext context) {
    int selectedTimeInSeconds =
        _selectedTime == 3 ? 180 : _selectedTime == 5 ? 300 : 600;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessBoardScreen(
          vsComputer: false,
          aiDepth: 0,
          useTimer: _useTimer,
          initialTime: selectedTimeInSeconds,
        ),
      ),
    );
  }

  // Funzione per avviare il gioco contro il PC con la difficoltà scelta
  void _startGameAgainstComputer(BuildContext context, Difficulty difficulty) {
    int selectedTimeInSeconds =
        _selectedTime == 3 ? 180 : _selectedTime == 5 ? 300 : 600;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessBoardScreen(
          vsComputer: true,
          aiDepth: _getAiDepth(difficulty),
          useTimer: _useTimer,
          initialTime: selectedTimeInSeconds,
          difficulty: difficulty,
        ),
      ),
    );
  }

  int _getAiDepth(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.facile:
        return 1;
      case Difficulty.medio:
        return 4;
      case Difficulty.difficile:
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
                    _selectedDifficultyLabel = 'Facile';
                  });
                  Navigator.of(context).pop();
                  _startGameAgainstComputer(context, Difficulty.facile);
                },
              ),
              ListTile(
                title: const Text('Medio'),
                onTap: () {
                  setState(() {
                    _selectedDifficultyLabel = 'Medio';
                  });
                  Navigator.of(context).pop();
                  _startGameAgainstComputer(context, Difficulty.medio);
                },
              ),
              ListTile(
                title: const Text('Difficile'),
                onTap: () {
                  setState(() {
                    _selectedDifficultyLabel = 'Difficile';
                  });
                  Navigator.of(context).pop();
                  _startGameAgainstComputer(context, Difficulty.difficile);
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
                onPressed: () => _start1v1Game(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800], 
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('1 vs 1', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showDifficultyDialog(context),
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
                  Text('Difficoltà attuale: $_selectedDifficultyLabel', style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
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
                        _showTimerDialog();
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
















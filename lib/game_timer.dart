import 'dart:async';

class GameTimer {
  late Stopwatch _whiteStopwatch;  
  late Stopwatch _blackStopwatch;  
  late Timer _timer;  
  bool _isWhiteTurn = true;  // Determina se è il turno del bianco
  bool _isGameOver = false;  // Verifica se il gioco è finito

  Function(int whiteTime, int blackTime, String currentPlayer)? onTimeUpdate;
  Function(String winner)? onGameOver;

  int whiteInitialTime = 0;
  int blackInitialTime = 0;
  int whiteTimeLeft = 0;
  int blackTimeLeft = 0;

  GameTimer({this.onTimeUpdate, this.onGameOver});

  // Avvia il timer
  void start(int timeInSeconds) {
    whiteInitialTime = timeInSeconds;
    blackInitialTime = timeInSeconds;

    whiteTimeLeft = timeInSeconds;
    blackTimeLeft = timeInSeconds;

    _whiteStopwatch = Stopwatch();
    _blackStopwatch = Stopwatch();

    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isGameOver) {
        // Solo il giocatore con il turno ha il tempo decrementato
        if (_isWhiteTurn) {
          whiteTimeLeft = whiteInitialTime - _whiteStopwatch.elapsed.inSeconds;
        } else {
          blackTimeLeft = blackInitialTime - _blackStopwatch.elapsed.inSeconds;
        }

        
        onTimeUpdate?.call(whiteTimeLeft, blackTimeLeft, _isWhiteTurn ? 'Bianco' : 'Nero');

        // Verifica se il tempo è scaduto per il giocatore
        if (_isWhiteTurn && whiteTimeLeft <= 0) {
          _endGame('Nero'); 
        } else if (!_isWhiteTurn && blackTimeLeft <= 0) {
          _endGame('Bianco'); 
        }
      }
    });
  }

  void stop() {
    _timer.cancel();  // Ferma il timer quando il gioco finisce
    _isGameOver = true;
  }

  // Cambia il turno tra bianco e nero
  void switchTurn() {
    _isWhiteTurn = !_isWhiteTurn;  

    if (_isWhiteTurn) {
      // Se è il turno del bianco, avvia il cronometro del bianco e ferma il nero
      _whiteStopwatch.start();
      _blackStopwatch.stop();
    } else {
      // Se è il turno del nero, avvia il cronometro del nero e ferma il bianco
      _blackStopwatch.start();
      _whiteStopwatch.stop();
    }
  }

  void _endGame(String winner) {
    stop();
    onGameOver?.call(winner);  // Chiama la funzione di fine partita e passa il vincitore
  }

  String formatTime(int timeInSeconds) {
    int minutes = timeInSeconds ~/ 60;
    int seconds = timeInSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  int get whiteTime => whiteTimeLeft;
  int get blackTime => blackTimeLeft;
}











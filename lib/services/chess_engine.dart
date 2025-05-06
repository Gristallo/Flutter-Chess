import 'package:flutter/services.dart';

class ChessEngine {
  static const platform = MethodChannel('com.chess_game.stockfish');

  // Funzione per ottenere la mossa migliore da Stockfish
  Future<String> getBestMove(String currentPosition) async {
    try {
      final String bestMove = await platform.invokeMethod('getBestMove', {"fen": currentPosition});
      return bestMove;
    } on PlatformException catch (e) {
      print("Errore nel recupero della mossa: '${e.message}'.");
      return '';
    }
  }
}

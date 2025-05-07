import 'package:flutter/services.dart';

class ChessEngine {
  static const platform = MethodChannel('com.chess_game.stockfish');

  /// Restituisce la mossa migliore in UCI (es. "e2e4") per la FEN data,
  /// alla profondità specificata.
  Future<String> getBestMove(String fen, int depth) async {
    try {
      final String bestMove = await platform.invokeMethod(
        'getBestMove',
        {
          "fen": fen,
          "depth": depth,
        },
      );
      return bestMove;
    } on PlatformException catch (e) {
      print("Errore nel recupero della mossa: '${e.message}'.");
      return '';
    }
  }
}


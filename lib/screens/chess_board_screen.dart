import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;

class ChessBoardScreen extends StatefulWidget {
  final bool vsComputer;

  const ChessBoardScreen({Key? key, required this.vsComputer}) : super(key: key);

  @override
  _ChessBoardScreenState createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  chess.Chess _game = chess.Chess();
  int? selectedRow;
  int? selectedCol;
  List<String> validMoves = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTurnText()),
      ),
      body: AspectRatio(
        aspectRatio: 1.0,
        child: GridView.builder(
          itemCount: 64,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
          itemBuilder: (context, index) {
            final int row = index ~/ 8;
            final int col = index % 8;
            final bool isLight = (row + col) % 2 == 0;
            final square = _indexToSquare(row, col);
            final piece = _game.get(square);

            bool isSelected = (selectedRow == row && selectedCol == col);
            bool isMoveHint = validMoves.contains(square);

            return GestureDetector(
              onTap: () => _onTap(row, col),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.red
                      : isMoveHint
                          ? Colors.blue.withOpacity(0.5)
                          : (isLight ? Colors.brown[200] : Colors.brown[700]),
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Text(
                    piece != null ? _pieceSymbol(piece) : '',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onTap(int row, int col) {
    final square = _indexToSquare(row, col);

    setState(() {
      if (selectedRow == null || selectedCol == null) {
        // Primo tap: seleziona pezzo
        final piece = _game.get(square);
        if (piece != null && piece.color == _game.turn) {
          selectedRow = row;
          selectedCol = col;

          validMoves = _game
              .moves()
              .whereType<Map>()
              .where((move) => move['from'] == square)
              .map<String>((move) => move['to'] as String)
              .toList();
        }
      } else {
        // Secondo tap: prova a muovere
        final fromSquare = _indexToSquare(selectedRow!, selectedCol!);
        final toSquare = square;

        final move = _game.move({'from': fromSquare, 'to': toSquare});

        if (move != null) {
          _checkEndGame(); // 👈 controlla scacco matto o patta
          selectedRow = null;
          selectedCol = null;
          validMoves = [];
        } else {
          // Mossa non valida: deseleziona
          selectedRow = null;
          selectedCol = null;
          validMoves = [];
        }
      }
    });
  }

  String _indexToSquare(int row, int col) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + col);
    String rank = (8 - row).toString();
    return '$file$rank';
  }

  String _pieceSymbol(chess.Piece piece) {
    switch (piece.type) {
      case chess.PieceType.BISHOP:
        return piece.color == chess.Color.WHITE ? '♗' : '♝';
      case chess.PieceType.KING:
        return piece.color == chess.Color.WHITE ? '♔' : '♚';
      case chess.PieceType.KNIGHT:
        return piece.color == chess.Color.WHITE ? '♘' : '♞';
      case chess.PieceType.PAWN:
        return piece.color == chess.Color.WHITE ? '♙' : '♟';
      case chess.PieceType.QUEEN:
        return piece.color == chess.Color.WHITE ? '♕' : '♛';
      case chess.PieceType.ROOK:
        return piece.color == chess.Color.WHITE ? '♖' : '♜';
      default:
        return '';
    }
  }

  void _checkEndGame() {
    if (_game.in_checkmate) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Scacco Matto!'),
          content: Text(_game.turn == chess.Color.WHITE ? 'Nero vince!' : 'Bianco vince!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _game = chess.Chess();
                  selectedRow = null;
                  selectedCol = null;
                  validMoves = [];
                });
              },
              child: Text('Nuova partita'),
            ),
          ],
        ),
      );
    } else if (_game.in_stalemate || _game.in_draw) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Patta!'),
          content: Text('La partita è finita in pareggio.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _game = chess.Chess();
                  selectedRow = null;
                  selectedCol = null;
                  validMoves = [];
                });
              },
              child: Text('Nuova partita'),
            ),
          ],
        ),
      );
    }
  }

  String _getTurnText() {
    if (_game.in_checkmate) {
      return 'Scacco Matto!';
    } else if (_game.turn == chess.Color.WHITE) {
      return "Turno del Bianco";
    } else {
      return "Turno del Nero";
    }
  }
}

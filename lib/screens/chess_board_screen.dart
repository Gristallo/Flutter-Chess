import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

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
  final _random = Random();

  String? lastFrom;
  String? lastTo;
  String? kingInCheckSquare;

  final _audioPlayer = AudioPlayer();

  Future<void> _playCaptureSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/capture.mp3'));
    } catch (_) {}
  }

  Future<void> _playCheckSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/move-check.mp3'));
    } catch (_) {}
  }

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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
          itemBuilder: (context, index) {
            final int row = index ~/ 8;
            final int col = index % 8;
            final bool isLight = (row + col) % 2 == 0;
            final square = _indexToSquare(row, col);
            final piece = _game.get(square);

            bool isSelected = (selectedRow == row && selectedCol == col);
            bool isMoveHint = validMoves.contains(square);
            bool isLastMove = (square == lastFrom || square == lastTo);
            bool isCheckSquare = (square == kingInCheckSquare);

            return GestureDetector(
              onTap: () => _onTap(row, col),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.red
                          : isCheckSquare
                              ? Colors.orange[300]
                              : isLastMove
                                  ? Colors.yellow[300]
                                  : (isLight ? Colors.brown[200] : Colors.brown[700]),
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                  if (isMoveHint)
                    piece != null
                        ? Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.blueAccent, width: 3),
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.6),
                              ),
                            ),
                          ),
                  if (piece != null)
                    Center(
                      child: _pieceImage(piece),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _pieceImage(chess.Piece piece) {
    String color = piece.color == chess.Color.WHITE ? 'w' : 'b';
    String type = {
      chess.PieceType.PAWN: 'pawn',
      chess.PieceType.KNIGHT: 'knight',
      chess.PieceType.BISHOP: 'bishop',
      chess.PieceType.ROOK: 'rook',
      chess.PieceType.QUEEN: 'queen',
      chess.PieceType.KING: 'king',
    }[piece.type]!;

    return Image.asset(
      'assets/images/${color}_${type}.png',
      fit: BoxFit.contain,
    );
  }

  void _onTap(int row, int col) {
  final square = _indexToSquare(row, col);

  setState(() {
    if (selectedRow == null || selectedCol == null) {
      final piece = _game.get(square);
      if (piece != null && piece.color == _game.turn) {
        selectedRow = row;
        selectedCol = col;
        validMoves = getValidMoves(square);
      }
    } else {
      final fromSquare = _indexToSquare(selectedRow!, selectedCol!);
      final toSquare = square;

      final possibleMoves = _game.generate_moves({'legal': true});
      final isValidMove = possibleMoves.any((m) =>
          _squareFromIndex(m.from) == fromSquare &&
          _squareFromIndex(m.to) == toSquare);

      if (!isValidMove) {
        // Reset selezione se la mossa è illegale
        selectedRow = null;
        selectedCol = null;
        validMoves = [];
        return;
      }

      final movingPiece = _game.get(fromSquare);
      final capturedPiece = _game.get(toSquare);

      // Verifica se è una mossa valida di promozione
      final isPromotionMove = possibleMoves.any((m) =>
          _squareFromIndex(m.from) == fromSquare &&
          _squareFromIndex(m.to) == toSquare &&
          m.promotion != null);

      if (isPromotionMove) {
        _showPromotionDialog(fromSquare, toSquare);
      } else {
        final move = _game.move({'from': fromSquare, 'to': toSquare});
        if (move != null) {
          if (capturedPiece != null) _playCaptureSound();
          lastFrom = fromSquare;
          lastTo = toSquare;
          _updateCheckSquare();
          if (_game.in_check) _playCheckSound();
          _checkEndGame();
          selectedRow = null;
          selectedCol = null;
          validMoves = [];

          if (widget.vsComputer && _game.turn == chess.Color.BLACK) {
            _makeComputerMove();
          }
        } else {
          // Mossa non valida (non dovrebbe succedere, ma per sicurezza)
          selectedRow = null;
          selectedCol = null;
          validMoves = [];
        }
      }
    }
  });
}



  void _makeComputerMove() {
    final possibleMoves = _game.generate_moves({'legal': true});
    if (possibleMoves.isNotEmpty) {
      final randomMove = possibleMoves[_random.nextInt(possibleMoves.length)];
      final toSquare = _squareFromIndex(randomMove.to);
      final capturedPiece = _game.get(toSquare);

      _game.move(randomMove);
      if (capturedPiece != null) _playCaptureSound();
      lastFrom = _squareFromIndex(randomMove.from);
      lastTo = _squareFromIndex(randomMove.to);
      _updateCheckSquare();
      if (_game.in_check) _playCheckSound();
      _checkEndGame();
    }
    setState(() {
      validMoves = [];
    });
  }

  void _showPromotionDialog(String from, String to) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promozione del Pedone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _promotionOption('♛', 'q', from, to),
            _promotionOption('♜', 'r', from, to),
            _promotionOption('♝', 'b', from, to),
            _promotionOption('♞', 'n', from, to),
          ],
        ),
      ),
    );
  }

  Widget _promotionOption(String pieceSymbol, String value, String from, String to) {
    return ListTile(
      leading: Text(
        pieceSymbol,
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(_pieceName(value)),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          _game.move({'from': from, 'to': to, 'promotion': value});
          lastFrom = from;
          lastTo = to;
          _updateCheckSquare();
          if (_game.in_check) _playCheckSound();
          _checkEndGame();
          selectedRow = null;
          selectedCol = null;
          validMoves = [];
        });
      },
    );
  }

  void _updateCheckSquare() {
    if (_game.in_check) {
      final color = _game.turn;
      final kingSquare = _findKingSquare(color);
      setState(() {
        kingInCheckSquare = kingSquare;
      });
    } else {
      setState(() {
        kingInCheckSquare = null;
      });
    }
  }

  String? _findKingSquare(chess.Color color) {
    for (var file in 'abcdefgh'.split('')) {
      for (var rank in '12345678'.split('')) {
        final square = '$file$rank';
        final piece = _game.get(square);
        if (piece != null &&
            piece.type == chess.PieceType.KING &&
            piece.color == color) {
          return square;
        }
      }
    }
    return null;
  }

  List<String> getValidMoves(String fromSquare) {
    final allMoves = _game.generate_moves({'legal': true});
    return allMoves
        .where((m) => _squareFromIndex(m.from) == fromSquare)
        .map((m) => _squareFromIndex(m.to))
        .toList();
  }

  String _indexToSquare(int row, int col) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + col);
    String rank = (8 - row).toString();
    return '$file$rank';
  }

  String _squareFromIndex(int index) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + (index % 16));
    final rank = (8 - (index ~/ 16)).toString();
    return '$file$rank';
  }

  void _checkEndGame() {
    if (_game.in_checkmate) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Scacco Matto!'),
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
                  lastFrom = null;
                  lastTo = null;
                  kingInCheckSquare = null;
                });
              },
              child: const Text('Nuova partita'),
            ),
          ],
        ),
      );
    } else if (_game.in_stalemate || _game.in_draw) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Patta!'),
          content: const Text('La partita è finita in pareggio.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _game = chess.Chess();
                  selectedRow = null;
                  selectedCol = null;
                  validMoves = [];
                  lastFrom = null;
                  lastTo = null;
                  kingInCheckSquare = null;
                });
              },
              child: const Text('Nuova partita'),
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

  String _pieceName(String value) {
    switch (value) {
      case 'q':
        return 'Regina';
      case 'r':
        return 'Torre';
      case 'b':
        return 'Alfiere';
      case 'n':
        return 'Cavallo';
      default:
        return '';
    }
  }
}







































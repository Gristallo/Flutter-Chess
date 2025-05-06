import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import '../game_timer.dart';
import 'package:chess_game/services/chess_engine.dart';

class ChessBoardScreen extends StatefulWidget {
  final bool vsComputer;
  final int aiDepth;
  final bool useTimer; 
  final int initialTime;

  const ChessBoardScreen({Key? key, required this.vsComputer, this.aiDepth = 2, this.useTimer = false, required this.initialTime}) : super(key: key);

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

  List<String> _moveHistory = [];
  List<chess.Piece> _whiteCaptured = [];
  List<chess.Piece> _blackCaptured = [];
  String? lastComputerMove;

  GameTimer? _gameTimer; 

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
void initState() {
  super.initState();
  if (!widget.vsComputer && widget.useTimer) {
    _gameTimer = GameTimer(
      onTimeUpdate: _updateTimer,    
      onGameOver: _handleGameOver,   
    );
    _gameTimer?.start(widget.initialTime);  
  }
}


void _handleGameOver(String winner) {
  _gameTimer?.stop(); 
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Tempo Scaduto'),
      content: Text('$winner ha vinto per tempo!'),
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
              _moveHistory.clear();
              _whiteCaptured.clear();
              _blackCaptured.clear();
            });
          },
          child: const Text('Nuova partita'),
        ),
      ],
    ),
  );
}

 void _updateTimer(int whiteTime, int blackTime, String currentPlayer) {
  setState(() {
    if (currentPlayer == 'Bianco' && _game.turn == chess.Color.WHITE) {
      _gameTimer?.switchTurn();  
    } else if (currentPlayer == 'Nero' && _game.turn == chess.Color.BLACK) {
      _gameTimer?.switchTurn();  
    }
  });
}



  @override
  void dispose() {
    _gameTimer?.stop();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(_getTurnText()),
      backgroundColor: Colors.grey[700],
    ),
    body: Container(
      color: Colors.grey[600],
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: _buildChessBoard(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Visualizza il timer
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Bianco: ${_gameTimer?.formatTime(_gameTimer!.blackTime)}\n'  //NOTA: I timer del bianco e del nero sono invertiti: dopo tantissime prove non riuscivo a risolvere, quindi ho risolto direttamente così (brutalmente xD)
                    'Nero: ${_gameTimer?.formatTime(_gameTimer!.whiteTime)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: _buildMoveHistory()),
                const Divider(),
                Container(
                  color: Colors.grey[500],
                  child: _buildCapturedPieces(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}



  // Metodo per costruire la scacchiera
  Widget _buildChessBoard() {
    return GridView.builder(
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
        bool isLastComputerMoveFrom = (square == lastComputerMove?.split(' → ').first);
        bool isLastComputerMoveTo = (square == lastComputerMove?.split(' → ').last);

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
                              : isLastComputerMoveFrom
                                  ? Colors.green[300]
                                  : isLastComputerMoveTo
                                      ? Colors.blue[300]
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
      width: 32,
      height: 32,
    );
  }

  // Metodo per la selezione delle mosse e il loro aggiornamento
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
          selectedRow = null;
          selectedCol = null;
          validMoves = [];
          return;
        }

        final movingPiece = _game.get(fromSquare);
        final capturedPiece = _game.get(toSquare);

        final isPromotionMove = possibleMoves.any((m) =>
            _squareFromIndex(m.from) == fromSquare &&
            _squareFromIndex(m.to) == toSquare &&
            m.promotion != null);

        if (isPromotionMove) {
          _showPromotionDialog(fromSquare, toSquare);
        } else {
          final move = _game.move({'from': fromSquare, 'to': toSquare});
          if (move != null) {
            String algebraicNotation = _convertToAlgebraicNotation(fromSquare, toSquare, movingPiece, capturedPiece, isPromotionMove);
            _moveHistory.add(algebraicNotation);
            
            if (capturedPiece != null) {
              _playCaptureSound();
              if (capturedPiece.color == chess.Color.WHITE) {
                _whiteCaptured.add(capturedPiece);
              } else {
                _blackCaptured.add(capturedPiece);
              }
            }
            lastFrom = fromSquare;
            lastTo = toSquare;
            _updateCheckSquare();
            if (_game.in_check) _playCheckSound();
            _checkEndGame();
            selectedRow = null;
            selectedCol = null;
            validMoves = [];

            _gameTimer?.switchTurn();

            if (widget.vsComputer && _game.turn == chess.Color.BLACK) {
              _makeComputerMove();
            }
          }
        }
      }
    });
  }

  // Metodo per fare il movimento del computer
  void _makeComputerMove() async {
    final possibleMoves = _game.generate_moves({'legal': true});
    if (possibleMoves.isNotEmpty) {
      chess.Move bestMove;

      // Se la modalità è facile, scegli una mossa a caso
      if (widget.aiDepth == 2) {
        bestMove = possibleMoves[_random.nextInt(possibleMoves.length)];
      } else {
        // Se la modalità è medio o difficile, usa Alpha-Beta Pruning
        bestMove = _findBestMove(possibleMoves, widget.aiDepth);
      }

      await Future.delayed(const Duration(milliseconds: 500)); // Ritardo per simulare il pensiero dell'IA
      _game.move(bestMove);

      // Aggiungi la mossa dell'IA nello storico
      String algebraicNotation = _convertToAlgebraicNotation(
        _squareFromIndex(bestMove.from),
        _squareFromIndex(bestMove.to),
        _game.get(_squareFromIndex(bestMove.from)),
        _game.get(_squareFromIndex(bestMove.to)),
        false, // Perché non è una promozione in questo caso
      );
      setState(() {
        lastComputerMove = '${_squareFromIndex(bestMove.from)} → ${_squareFromIndex(bestMove.to)}'; // Registra anche la casella di arrivo
        _moveHistory.add(algebraicNotation); // Aggiungi la mossa nel registro
      });
      _updateGameState();
    }
  }

  chess.Move _findBestMove(List<chess.Move> possibleMoves, int depth) {
    int bestValue = -10000;
    chess.Move? bestMove;

    for (var move in possibleMoves) {
      _game.move(move); // Simula la mossa
      int boardValue = _minimaxAlphaBeta(depth - 1, -10000, 10000, false);
      _game.undo(); // Annula la mossa

      if (boardValue > bestValue) {
        bestValue = boardValue;
        bestMove = move;
      }
    }
    return bestMove!;
  }

  int _minimaxAlphaBeta(int depth, int alpha, int beta, bool isMaximizingPlayer) {
    if (depth == 0) {
      return _evaluateBoard(); // Valutazione della scacchiera
    }

    List<chess.Move> possibleMoves = _game.generate_moves({'legal': true});

    if (isMaximizingPlayer) {
      int maxEval = -10000;
      for (var move in possibleMoves) {
        _game.move(move); // Simula la mossa
        int eval = _minimaxAlphaBeta(depth - 1, alpha, beta, false);
        _game.undo(); // Annula la mossa

        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) {
          break; // Potatura
        }
      }
      return maxEval;
    } else {
      int minEval = 10000;
      for (var move in possibleMoves) {
        _game.move(move); // Simula la mossa
        int eval = _minimaxAlphaBeta(depth - 1, alpha, beta, true);
        _game.undo(); // Annula la mossa

        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) {
          break; // Potatura
        }
      }
      return minEval;
    }
  }

  int _evaluateBoard() {
    int evaluation = 0;

    // Aggiungi valore ai pezzi
    for (var file in 'abcdefgh'.split('')) {
      for (var rank in '12345678'.split('')) {
        final square = '$file$rank';
        final piece = _game.get(square);
        if (piece != null) {
          int pieceValue = 0;
          switch (piece.type) {
            case chess.PieceType.PAWN:
              pieceValue = 1;
              break;
            case chess.PieceType.KNIGHT:
            case chess.PieceType.BISHOP:
              pieceValue = 3;
              break;
            case chess.PieceType.ROOK:
              pieceValue = 5;
              break;
            case chess.PieceType.QUEEN:
              pieceValue = 9;
              break;
            case chess.PieceType.KING:
              pieceValue = 100;
              break;
          }

          // Considera il colore del pezzo
          if (piece.color == chess.Color.WHITE) {
            evaluation += pieceValue;
          } else {
            evaluation -= pieceValue;
          }
        }
      }
    }

    // Considera se il re è sotto scacco o meno
    if (_game.in_check) {
      evaluation += (_game.turn == chess.Color.WHITE) ? -50 : 50;
    }

    return evaluation;
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

  // Metodo per visualizzare i pezzi catturati
  Widget _buildCapturedPieces() {
    int pieceValue(chess.PieceType type) {
      switch (type) {
        case chess.PieceType.PAWN:
          return 1;
        case chess.PieceType.KNIGHT:
        case chess.PieceType.BISHOP:
          return 3;
        case chess.PieceType.ROOK:
          return 5;
        case chess.PieceType.QUEEN:
          return 9;
        default:
          return 0;
      }
    }

    int whiteScore = _whiteCaptured.fold(0, (sum, p) => sum + pieceValue(p.type));
    int blackScore = _blackCaptured.fold(0, (sum, p) => sum + pieceValue(p.type));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bianco (Tot: $whiteScore):"),
          Wrap(children: _whiteCaptured.map(_pieceImage).toList()),
          const SizedBox(height: 8),
          Text("Nero (Tot: $blackScore):"),
          Wrap(children: _blackCaptured.map(_pieceImage).toList()),
        ],
      ),
    );
  }

  // Metodo per aggiornare lo stato del gioco
  void _updateGameState() {
    setState(() {
      validMoves = [];
    });
  }

  // Metodo per aggiornare la posizione del re in scacco
  void _updateCheckSquare() {
    if (_game.in_check) {
      final color = _game.turn;
      final kingSquare = _findKingSquare(color); // Trova la posizione del re
      kingInCheckSquare = kingSquare;
    } else {
      kingInCheckSquare = null; // Re non è in scacco
    }
  }

  // Metodo per trovare la posizione del re (se il re è sotto scacco)
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
    return null; // Se il re non è trovato (non dovrebbe mai succedere)
  }

  // Metodo per visualizzare lo storico delle mosse
  Widget _buildMoveHistory() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,  // Aggiungi la possibilità di scorrere orizzontalmente
      child: Row(
        children: List.generate(_moveHistory.length, (index) {
          String move = _moveHistory[index];

          // Colora la mossa in base al giocatore (bianco o nero)
          TextStyle textStyle;
          if (index % 2 == 0) {
            textStyle = TextStyle(color: Colors.white); // Mossa del bianco
          } else {
            textStyle = TextStyle(color: Colors.black); // Mossa del nero
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${index + 1}. $move',
              style: textStyle,
            ),
          );
        }),
      ),
    );
  }

  void _checkEndGame() {
    if (_game.in_checkmate) {
      _showEndDialog(_game.turn == chess.Color.WHITE ? 'Nero vince!' : 'Bianco vince!');
    } else if (_game.in_stalemate || _game.in_draw) {
      _showEndDialog('La partita è finita in pareggio.');
    }
  }

  void _showEndDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fine partita'),
        content: Text(message),
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
                _moveHistory.clear();
                _whiteCaptured.clear();
                _blackCaptured.clear();
              });
            },
            child: const Text('Nuova partita'),
          ),
        ],
      ),
    );
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
          _moveHistory.add('$from → $to = ${_pieceName(value)}');
          _updateCheckSquare();
          _checkEndGame();
          selectedRow = null;
          selectedCol = null;
          validMoves = [];
        });
      },
    );
  }

  String _pieceName(String value) {
    switch (value) {
      case 'q': return 'Regina';
      case 'r': return 'Torre';
      case 'b': return 'Alfiere';
      case 'n': return 'Cavallo';
      default: return '';
    }
  }

  String _convertToAlgebraicNotation(
    String fromSquare,
    String toSquare,
    chess.Piece? movingPiece,
    chess.Piece? capturedPiece,
    bool isPromotionMove) {

    String move = '';

    // Aggiungi il tipo di pezzo se non è un pedone
    if (movingPiece != null && movingPiece.type != chess.PieceType.PAWN) {
      move += _getPieceSymbol(movingPiece.type);
    }

    move += fromSquare;

    // Aggiungi la cattura se c'è un pezzo catturato
    if (capturedPiece != null) {
      move += 'x';
    }

    move += toSquare;

    // Aggiungi la promozione se è un pedone promosso
    if (isPromotionMove) {
      move += '=${_getPromotionPieceSymbol()}';
    }

    // Aggiungi il segno di scacco (+) o scacco matto (#)
    if (_game.in_check) {
      move += '+';
    } else if (_game.in_checkmate) {
      move += '#';
    }

    return move;
  }

  String _getPieceSymbol(chess.PieceType type) {
    switch (type) {
      case chess.PieceType.KNIGHT:
        return 'N';
      case chess.PieceType.BISHOP:
        return 'B';
      case chess.PieceType.ROOK:
        return 'R';
      case chess.PieceType.QUEEN:
        return 'Q';
      case chess.PieceType.KING:
        return 'K';
      default:
        return '';
    }
  }

  String _getPromotionPieceSymbol() {
    return 'Q';  // Regina per promozioni
  }
}



























































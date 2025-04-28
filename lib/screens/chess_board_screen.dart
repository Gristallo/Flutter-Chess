import 'package:flutter/material.dart';

class ChessBoardScreen extends StatefulWidget {
  final bool vsComputer;

  const ChessBoardScreen({Key? key, required this.vsComputer}) : super(key: key);

  @override
  _ChessBoardScreenState createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  List<List<String?>> board = List.generate(8, (_) => List.filled(8, null));

  @override
  void initState() {
    super.initState();
    _setupBoard();
  }

  void _setupBoard() {
    // Qui puoi inizializzare i pezzi sulla scacchiera
    // Per ora lasciamo vuoto (puoi aggiungere in seguito)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vsComputer ? 'Sfida il PC' : '1 vs 1'),
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
            return Container(
              decoration: BoxDecoration(
                color: isLight ? Colors.white : Colors.grey,
              ),
              child: Center(
                child: board[row][col] != null ? Text(board[row][col]!) : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

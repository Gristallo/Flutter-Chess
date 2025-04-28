import 'package:flutter/material.dart';
import 'chess_board_screen.dart';

class HomeScreen extends StatelessWidget {
  void _navigateToGame(BuildContext context, bool vsComputer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessBoardScreen(vsComputer: vsComputer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chess Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToGame(context, false),
              child: Text('1 vs 1'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToGame(context, true),
              child: Text('Sfida il PC'),
            ),
          ],
        ),
      ),
    );
  }
}
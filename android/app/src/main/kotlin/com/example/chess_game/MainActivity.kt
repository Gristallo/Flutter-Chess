package com.example.chess_game

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import java.io.File
import java.io.InputStreamReader
import java.io.BufferedReader
import android.content.res.AssetManager
import java.io.InputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.chess_game.stockfish" 

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Copia Stockfish dalla cartella assets alla directory di esecuzione
        copyStockfishToFile()

        
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result -> 
            // Gestisci la chiamata dal lato Flutter
            if (call.method == "getBestMove") {
                val fen = call.argument<String>("fen")  // Ottieni la posizione FEN dal Dart
                if (fen != null) {
                    val bestMove = getBestMoveFromStockfish(fen)
                    result.success(bestMove)  // Rispondi con la mossa migliore
                } else {
                    result.error("INVALID_ARGUMENT", "FEN non valido", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun copyStockfishToFile() {
        val stockfishFile = File(filesDir, "stockfish")

        if (!stockfishFile.exists()) {
            try {
                // Ottieni il gestore degli asset
                val assetManager: AssetManager = assets
                // Apri il file di Stockfish dalla cartella assets
                val inputStream: InputStream = assetManager.open("stockfish/stockfish")
                // Crea un OutputStream per scrivere il file nella directory di esecuzione
                val outputStream: OutputStream = stockfishFile.outputStream()

                // Crea un buffer di byte per copiare i dati
                val buffer = ByteArray(1024)
                var length: Int
                while (inputStream.read(buffer).also { length = it } > 0) {
                    outputStream.write(buffer, 0, length)
                }
                // Chiudi i flussi
                outputStream.close()
                inputStream.close()

                // Imposta il file come eseguibile
                stockfishFile.setExecutable(true)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun getBestMoveFromStockfish(fen: String): String {
        // Esegui Stockfish usando il FEN come input
        val stockfish = File(filesDir, "stockfish")  // Ora il binario dovrebbe essere nella directory corretta
        val process = ProcessBuilder(stockfish.absolutePath, "-fen", fen)
            .redirectErrorStream(true)
            .start()

        // Leggi l'output di Stockfish per trovare la mossa migliore
        val reader = BufferedReader(InputStreamReader(process.inputStream))
        var line: String?
        var bestMove = ""

        while (reader.readLine().also { line = it } != null) {
            if (line!!.startsWith("bestmove")) {
                bestMove = line!!.substring(9).trim()  // Estrai la mossa migliore
                break
            }
        }

        // Attendi che il processo di Stockfish finisca
        process.waitFor()
        return bestMove
    }
}




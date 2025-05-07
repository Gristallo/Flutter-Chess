package com.example.chess_game

import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.*

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.chess_game.stockfish"

    /*------------------------------------------------------------*/
    /* Ciclo di vita                                              */
    /*------------------------------------------------------------*/
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        /* copyStockfishToFile()  */            
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getBestMove") {
                    val fen   = call.argument<String>("fen")
                    val depth = call.argument<Int>("depth") ?: 2

                    if (fen == null) {
                        result.error("INVALID_ARGUMENT", "FEN non valido", null)
                        return@setMethodCallHandler
                    }

                    Thread {
                        val best = getBestMoveFromStockfish(fen, depth)
                        runOnUiThread { result.success(best) }
                    }.start()
                } else {
                    result.notImplemented()
                }
            }
    }

    /*------------------------------------------------------------*/
    /* 1. Copia l’asset e rende eseguibile                        */
    /*------------------------------------------------------------*/
    /* private fun copyStockfishToFile() {
        val dest = File(filesDir, "stockfish")
        Log.d("SF", "Percorso filesDir: ${dest.absolutePath}")

        if (!dest.exists()) {
            try {
                // unico binario: assets/stockfish/arm64-v8a/stockfish
                assets.open("stockfish/arm64-v8a/stockfish").use { input ->
                    dest.outputStream().use { output -> input.copyTo(output) }
                }
                Log.d("SF", "Stockfish copiato.")
            } catch (e: IOException) {
                Log.e("SF", "Copia fallita: ${e.message}", e)
            }
        }

        // imposta sempre il bit eseguibile
        val execOK = dest.setExecutable(true, /*ownerOnly =*/ false)
        Log.d("SF", "chmod +x: $execOK  canExecute=${dest.canExecute()}")
    }
    */

    /*------------------------------------------------------------*/
    /* 2. Lancia Stockfish e restituisce bestmove                 */
    /*------------------------------------------------------------*/
    private fun getBestMoveFromStockfish(fen: String, depth: Int): String {

        val enginePath = File(applicationInfo.nativeLibraryDir, "libstockfish.so").absolutePath
        var process: Process? = null
        var stdin: BufferedWriter? = null
        var stdout: BufferedReader? = null

        return try {
            process = ProcessBuilder(enginePath)
                .redirectErrorStream(true)
                .start()

            stdin  = process.outputStream.bufferedWriter()
            stdout = process.inputStream.bufferedReader()

            /* handshake UCI */
            stdin.apply { write("uci\nisready\n"); flush() }
            while (stdout.readLine() != "readyok") { /* skip */ }

            /* posizione e calcolo */
            stdin.apply {
                write("position fen $fen\n")
                write("go depth $depth\n")
                flush()
            }

            var line: String?
            var best = ""
            while (stdout.readLine().also { line = it } != null) {
                if (line!!.startsWith("bestmove")) {
                    best = line!!.substringAfter("bestmove").trim()
                    break
                }
            }
            best

        } catch (e: Exception) {
            Log.e("SF", "Errore Stockfish: ${e.message}", e)
            ""
        } finally {
            try { stdin?.close() } catch (_: IOException) {}
            try { stdout?.close() } catch (_: IOException) {}
            process?.destroy()
        }
    }
}










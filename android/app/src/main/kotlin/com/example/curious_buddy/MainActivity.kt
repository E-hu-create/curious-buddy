package com.example.curious_buddy

import android.os.Build
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Lets the app guarantee "on-device only" speech recognition: the
        // speech_to_text plugin otherwise falls back to a recogniser that
        // may send audio online. See SpeechToTextRecognitionService.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "curious_buddy/speech")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isOnDeviceAvailable" -> result.success(
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                            SpeechRecognizer.isOnDeviceRecognitionAvailable(this)
                    )
                    else -> result.notImplemented()
                }
            }
    }
}

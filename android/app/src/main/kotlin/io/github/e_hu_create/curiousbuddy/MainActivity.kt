package io.github.e_hu_create.curiousbuddy

import android.media.AudioAttributes
import android.media.SoundPool
import android.os.Build
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var soundPool: SoundPool? = null
    private val sounds = mutableMapOf<String, Int>()

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

        // Short sound effects, on the phone's media volume.
        setUpSounds()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "curious_buddy/sounds")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "play" -> {
                        sounds[call.arguments as? String]?.let { id ->
                            soundPool?.play(id, SOUND_VOLUME, SOUND_VOLUME, 1, 0, 1f)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setUpSounds() {
        val pool = SoundPool.Builder()
            .setMaxStreams(2)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .build()
        sounds["pop"] = pool.load(this, R.raw.sfx_pop, 1)
        sounds["correct"] = pool.load(this, R.raw.sfx_correct, 1)
        sounds["gentle"] = pool.load(this, R.raw.sfx_gentle, 1)
        sounds["cheer"] = pool.load(this, R.raw.sfx_cheer, 1)
        soundPool = pool
    }

    override fun onDestroy() {
        soundPool?.release()
        soundPool = null
        super.onDestroy()
    }

    private companion object {
        /// Effects stay quieter than Buddy's voice.
        const val SOUND_VOLUME = 0.6f
    }
}

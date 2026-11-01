package io.github.e_hu_create.curiousbuddy

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.SoundPool
import android.os.Build
import android.speech.SpeechRecognizer
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var soundPool: SoundPool? = null
    private val sounds = mutableMapOf<String, Int>()
    private val clips = mutableMapOf<String, Int>()
    private var clipStream = 0
    private var voicePlayer: MediaPlayer? = null
    private var voiceResult: MethodChannel.Result? = null

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

        // Buddy's recorded voice: one clip at a time, answered when it ends.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "curious_buddy/voice")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "play" -> playVoice(
                        call.argument<String>("asset")!!,
                        (call.argument<Double>("speed") ?: 1.0).toFloat(),
                        result,
                    )
                    "stop" -> {
                        stopVoice()
                        result.success(null)
                    }
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
                    "playClip" -> {
                        soundPool?.stop(clipStream)
                        clips[call.arguments as? String]?.let { id ->
                            clipStream = soundPool?.play(id, 1f, 1f, 1, 0, 1f) ?: 0
                        }
                        result.success(null)
                    }
                    "stopClip" -> {
                        soundPool?.stop(clipStream)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun playVoice(asset: String, speed: Float, result: MethodChannel.Result) {
        stopVoice()
        try {
            val key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(asset)
            val player = MediaPlayer()
            voicePlayer = player
            voiceResult = result
            assets.openFd(key).use { player.setDataSource(it.fileDescriptor, it.startOffset, it.length) }
            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build()
            )
            player.setOnCompletionListener { finishVoice(true) }
            player.setOnErrorListener { _, what, _ ->
                failVoice("playback error $what")
                true
            }
            player.prepare()
            // Changes speed, not pitch. Setting this also starts playback.
            player.playbackParams = player.playbackParams.setSpeed(speed)
            player.start()
        } catch (error: Exception) {
            failVoice(error.toString())
        }
    }

    private fun stopVoice() = finishVoice(false)

    private fun finishVoice(finished: Boolean) {
        val result = voiceResult
        voiceResult = null
        releaseVoice()
        result?.success(finished)
    }

    private fun failVoice(message: String) {
        val result = voiceResult
        voiceResult = null
        releaseVoice()
        result?.error("voice", message, null)
    }

    private fun releaseVoice() {
        voicePlayer?.release()
        voicePlayer = null
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
        // What's That Sound? recordings. See docs/SOUNDS.md.
        mapOf(
            "rooster" to R.raw.snd_rooster,
            "cow" to R.raw.snd_cow,
            "sheep" to R.raw.snd_sheep,
            "dog" to R.raw.snd_dog,
            "cat" to R.raw.snd_cat,
            "frog" to R.raw.snd_frog,
            "bee" to R.raw.snd_bee,
            "thunder" to R.raw.snd_thunder,
            "rain" to R.raw.snd_rain,
            "sea" to R.raw.snd_sea,
            "train" to R.raw.snd_train,
            "helicopter" to R.raw.snd_helicopter,
            "clock" to R.raw.snd_clock,
        ).forEach { (name, id) -> clips[name] = pool.load(this, id, 1) }
        soundPool = pool
    }

    override fun onDestroy() {
        stopVoice()
        soundPool?.release()
        soundPool = null
        super.onDestroy()
    }

    private companion object {
        /// Effects stay a little quieter than Buddy's voice.
        const val SOUND_VOLUME = 0.85f
    }
}

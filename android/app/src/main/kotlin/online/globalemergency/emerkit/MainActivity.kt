package online.globalemergency.emerkit

import android.os.Handler
import android.os.Looper
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val handler = Handler(Looper.getMainLooper())
    private val referrerExecutor = Executors.newSingleThreadExecutor()
    private var referrerClient: InstallReferrerClient? = null
    private var referrerResult: MethodChannel.Result? = null
    private var timeout: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "online.globalemergency.emerkit/attribution").setMethodCallHandler { call, result ->
            if (call.method == "installReferrer") readInstallReferrer(result)
            else result.notImplemented()
        }
    }

    private fun finishReferrer(value: String?) {
        timeout?.let { handler.removeCallbacks(it) }
        timeout = null
        val client = referrerClient
        val result = referrerResult
        referrerClient = null
        referrerResult = null
        try { client?.endConnection() } catch (_: Exception) { }
        result?.success(value)
    }

    private fun readInstallReferrer(result: MethodChannel.Result) {
        if (referrerResult != null) {
            result.success(null)
            return
        }
        referrerResult = result
        val client = try { InstallReferrerClient.newBuilder(this).build() } catch (_: Exception) {
            finishReferrer(null)
            return
        }
        referrerClient = client
        timeout = Runnable { finishReferrer(null) }.also { handler.postDelayed(it, 2000) }
        try {
            client.startConnection(object : InstallReferrerStateListener {
                override fun onInstallReferrerSetupFinished(responseCode: Int) {
                    handler.post {
                        if (referrerClient !== client) return@post
                        referrerExecutor.execute {
                            val value = try {
                                if (responseCode == InstallReferrerClient.InstallReferrerResponse.OK)
                                    client.installReferrer.installReferrer else null
                            } catch (_: Exception) { null }
                            handler.post {
                                if (referrerClient === client) finishReferrer(value)
                            }
                        }
                    }
                }
                override fun onInstallReferrerServiceDisconnected() {
                    handler.post {
                        if (referrerClient === client) finishReferrer(null)
                    }
                }
            })
        } catch (_: Exception) {
            finishReferrer(null)
        }
    }

    override fun onDestroy() {
        finishReferrer(null)
        referrerExecutor.shutdownNow()
        super.onDestroy()
    }
}

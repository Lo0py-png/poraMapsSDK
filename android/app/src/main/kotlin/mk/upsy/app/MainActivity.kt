package mk.upsy.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL = "mk.upsy.app/maps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showRoute") {
                val departureCity = call.argument<String>("departureCity")
                val arrivalCity = call.argument<String>("arrivalCity")

                if (departureCity != null && arrivalCity != null) {
                    val intent = Intent(this, MapActivity::class.java).apply {
                        putExtra("departureCity", departureCity)
                        putExtra("arrivalCity", arrivalCity)
                    }
                    startActivity(intent)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Both departureCity and arrivalCity are required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
package com.example.roadguardian_client

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "roadguardian.app/settings"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call, result ->
				if (call.method == "openNotificationSettings") {
					try {
						val intent = Intent()
						if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
							intent.action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
							intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
						} else {
							intent.action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
							intent.data = Uri.parse("package:$packageName")
						}
						intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
						startActivity(intent)
						result.success(null)
					} catch (e: Exception) {
						try {
							val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
							intent.data = Uri.parse("package:$packageName")
							intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							startActivity(intent)
							result.success(null)
						} catch (ex: Exception) {
							result.error("UNAVAILABLE", "Cannot open settings", null)
						}
					}
				} else {
					result.notImplemented()
				}
			}
	}
}

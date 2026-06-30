package com.example.fakenotification

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.fakenotification/backend"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val includeSystem = call.argument<Boolean>("includeSystem") ?: false
                    Thread {
                        val apps = getInstalledAppsList(includeSystem)
                        Handler(Looper.getMainLooper()).post {
                            result.success(apps)
                        }
                    }.start()
                }
                "sendFakeNotification" -> {
                    val packageName = call.argument<String>("packageName")
                    val appName = call.argument<String>("appName")
                    val title = call.argument<String>("title")
                    val text = call.argument<String>("text")
                    val delayMillis = (call.argument<Number>("delayMillis") ?: 0).toLong()
                    
                    if (packageName != null && title != null && text != null && appName != null) {
                        sendNotification(packageName, appName, title, text, delayMillis)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Missing arguments", null)
                    }
                }
                "checkPermissions" -> {
                    val hasPerm = checkAndRequestPermissions()
                    result.success(hasPerm)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkAndRequestPermissions(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val perm = ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
            if (perm != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 101)
                return false
            }
        }
        return true
    }

    private fun getInstalledAppsList(includeSystem: Boolean): List<Map<String, Any>> {
        val pm = packageManager
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val appList = mutableListOf<Map<String, Any>>()

        for (appInfo in packages) {
            val isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            if (!includeSystem && isSystemApp) continue

            val appName = pm.getApplicationLabel(appInfo).toString()
            val packageName = appInfo.packageName
            
            // Getting icon as byte array
            val iconDrawable = pm.getApplicationIcon(appInfo)
            val iconBytes = drawableToByteArray(iconDrawable)
            
            val map = mapOf(
                "name" to appName,
                "packageName" to packageName,
                "icon" to (iconBytes ?: ByteArray(0))
            )
            appList.add(map)
        }
        return appList.sortedBy { (it["name"] as String).lowercase() }
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray? {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            // Handle AdaptiveIconDrawable and others
            val bmp = Bitmap.createBitmap(
                drawable.intrinsicWidth.coerceAtLeast(1),
                drawable.intrinsicHeight.coerceAtLeast(1),
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }

        // Scale down to save memory over platform channel (50x50 is usually enough for lists)
        val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 100, 100, true)
        val stream = ByteArrayOutputStream()
        scaledBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    private fun sendNotification(packageName: String, appName: String, title: String, text: String, delayMillis: Long) {
        val runnable = Runnable {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            val channelId = "fake_notification_channel"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    channelId,
                    "Fake Notifications",
                    NotificationManager.IMPORTANCE_HIGH
                )
                nm.createNotificationChannel(channel)
            }

            var iconBytes: ByteArray? = null
            try {
                val pm = packageManager
                val appInfo = pm.getApplicationInfo(packageName, 0)
                val iconDrawable = pm.getApplicationIcon(appInfo)
                iconBytes = drawableToByteArray(iconDrawable)
            } catch (e: Exception) {
                e.printStackTrace()
            }

            val builder = NotificationCompat.Builder(this, channelId)
                .setContentTitle(title)
                .setContentText(text)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setSubText(appName)

            if (iconBytes != null && iconBytes.isNotEmpty()) {
                val bmp = android.graphics.BitmapFactory.decodeByteArray(iconBytes, 0, iconBytes.size)
                builder.setLargeIcon(bmp)
            }
            
            // Small icon is required by Android, but it must be monochrome. 
            // We use the application's icon, but the full color icon will be shown as LargeIcon.
            builder.setSmallIcon(applicationInfo.icon)

            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED || Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                NotificationManagerCompat.from(this).notify(System.currentTimeMillis().toInt(), builder.build())
            }
        }

        if (delayMillis > 0) {
            Handler(Looper.getMainLooper()).postDelayed(runnable, delayMillis)
        } else {
            runnable.run()
        }
    }
}

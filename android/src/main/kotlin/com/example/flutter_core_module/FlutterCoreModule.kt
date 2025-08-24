package com.example.flutter_core_module


import android.content.Context
import android.os.Environment
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper

class FlutterCoreModule : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {

        channel = MethodChannel(binding.binaryMessenger, "flutter.core.module/channel")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            "notificationReceived"->{
                Log.d("message","Notification received method call")
                val data = call.arguments
                Handler(Looper.getMainLooper()).post {
                    channel.invokeMethod("notificationToDart", data)
                }
              //  channel.invokeMethod("notificationToDart", data)
            }
            "notificationClick"->{
                Log.d("message","Notification click received method call")
                val data = call.arguments
                Handler(Looper.getMainLooper()).post {
                    channel.invokeMethod("notificationToDart", data)
                }
               // channel.invokeMethod("notificationClickToDart", data)
            }
            "getFlavor"->{
                val flavor: String = try {
                    val context = context ?: throw IllegalStateException("Plugin context is null")
                    val buildConfigClass = Class.forName("${context.packageName}.BuildConfig")
                    // Get only the FLAVOR field
                    buildConfigClass.getDeclaredField("FLAVOR").get(null) as? String ?: BuildConfig.BUILD_TYPE
                } catch (e: Exception) {
                    BuildConfig.BUILD_TYPE ?: ""
                }

                Log.d("FlutterCoreModule", "Returning flavor: $flavor")
                result.success(flavor)
            }

            "getFlavor1" -> {

                val pkgName = context!!.packageName
                val buildConfigClass = try {
                    Class.forName("$pkgName.BuildConfig")
                } catch (e: ClassNotFoundException) {
                    // Try stripping known flavor suffixes
                    val basePkg = pkgName.replace(Regex("\\.(dev|prod)$"), "")
                    try {
                        Class.forName("$basePkg.BuildConfig")
                    } catch (ex: ClassNotFoundException) {
                        null
                    }
                }

                val flavor = try {
                    buildConfigClass?.getDeclaredField("FLAVOR")?.get(null) as? String ?: ""
                } catch (e: Exception) {
                    ""
                }
                result.success(flavor)
            }
            "getDownloadDirectory" -> {
                val path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).path
                result.success(path)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

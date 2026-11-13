# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Google Maps — SDK (com.google.android.gms.maps) is covered by the gms rule
# above; this keeps the Flutter Maps plugin renderer classes (TLHC renderer)
# and the plugin's own factory/controller classes.
-keep class com.google.maps.** { *; }
-keep class com.google.maps.flutter.** { *; }
-keep class io.flutter.plugins.googlemaps.** { *; }
-dontwarn com.google.maps.**
-dontwarn com.google.maps.flutter.**
-dontwarn io.flutter.plugins.googlemaps.**

# Google Sign-In — covered by com.google.android.gms.** above, but the Flutter
# plugin bridge uses Pigeon-generated code under io.flutter.plugins.googlesignin
# which is accessed reflectively via the method channel.
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class io.flutter.plugins.googlesignin.** { *; }
-dontwarn io.flutter.plugins.googlesignin.**

# OkHttp / HTTP client (used internally by Firebase, cached_network_image etc.)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Keep Dart entry points that are referenced via @pragma('vm:entry-point')
-keep class * {
    @com.google.firebase.messaging.FirebaseMessagingService *;
}

# Prevent stripping of reflection-based serialization used in JSON models
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
# Preserve source file names and line numbers for readable crash-report stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# geolocator_android — registers a foreground Service in AndroidManifest;
# without this keep the location service is stripped and background GPS breaks.
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# permission_handler — Flutter method-channel bridge for runtime permissions.
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# flutter_local_notifications — registers BroadcastReceivers and a Service in
# AndroidManifest (ScheduledNotificationReceiver, BootReceiver, etc.); stripping
# these breaks scheduled and boot-time notifications entirely.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Gson — flutter_local_notifications uses RuntimeTypeAdapterFactory and
# TypeToken<> to serialise/deserialise scheduled notification state. R8 strips
# generic signatures from TypeToken unless explicitly kept, causing
# ClassCastException when restoring notifications after a device reboot.
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-dontwarn com.google.gson.**

# speech_to_text — Flutter plugin bridge for Android SpeechRecognizer.
-keep class com.csdcorp.speech_to_text.** { *; }
-dontwarn com.csdcorp.speech_to_text.**

# sqflite (transitive via flutter_cache_manager) — database helper classes.
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# Kotlin runtime — usually handled by the Kotlin Gradle plugin; explicit dontwarn
# guards against R8 warnings on coroutines and stdlib internals.
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**
-keep class kotlin.Metadata { *; }

# Suppress warnings for missing classes in third-party libs
-dontwarn java.lang.instrument.**
-dontwarn sun.misc.Unsafe
-dontwarn java.nio.file.**

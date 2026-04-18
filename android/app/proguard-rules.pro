# ============================================================================
# Firebase & Google Play Services
# ============================================================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepclasseswithmembernames class com.google.firebase.** { *; }
-keepclasseswithmembernames class com.google.android.gms.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keepclasseswithmembernames class com.google.firebase.auth.** { *; }

# Cloud Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.cloud.firestore.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }

# ============================================================================
# BLoC & State Management
# ============================================================================
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class io.flutter.plugins.** { *; }

# Equatable
-keep class equatable.** { *; }

# Provider
-keep class provider.** { *; }

# ============================================================================
# Hive Database
# ============================================================================
-keep class io.hive.** { *; }
-keepclasseswithmembernames class io.hive.** { *; }
-keep class hive.** { *; }
-keepclasseswithmembernames class hive.** { *; }

# ============================================================================
# Audio & Media - Selective keeps to allow shrinking
# ============================================================================
# ExoPlayer: Keep only public API and essential callback interfaces
-keep public class com.google.android.exoplayer2.ExoPlayer { *; }
-keep public class com.google.android.exoplayer2.Player { *; }
-keep public class com.google.android.exoplayer2.source.** { *; }
-keep public class com.google.android.exoplayer2.audio.** { *; }
-keep class * implements com.google.android.exoplayer2.Renderer { *; }
-keep class * implements com.google.android.exoplayer2.source.MediaPeriod { *; }

# Just Audio: Keep binding interfaces
-keep class com.ryanheise.just_audio.JustAudioService { *; }

# Audio Session: Keep public interfaces
-keep public class com.ryanheise.audio_session.AudioSessionCompat { *; }

# ============================================================================
# Networking & Serialization - Selective keeps
# ============================================================================
# Retrofit: Keep only public API and exceptions
-keep public class retrofit2.** { *; }
-keep public class okhttp3.** { *; }
-keep public interface retrofit2.** { *; }
-keep public interface okhttp3.** { *; }

# Dio: Keep service loader
-keep class * implements retrofit2.CallAdapter$Factory { *; }

# ============================================================================
# Image & Media Processing - Selective keeps
# ============================================================================
# Glide: Keep Glide API only
-keep public class com.bumptech.glide.Glide { *; }
-keep public class com.bumptech.glide.RequestBuilder { *; }
-keep class com.bumptech.glide.load.engine.Resource { *; }

# Material: Keep viewgroup classes
-keep public class com.google.android.material.** { *; }

# Palette Generator
-keep public class androidx.palette.graphics.Palette { *; }

# Mobile Scanner (ML Kit) - Keep minimal necessary classes
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.mlkit.common.** { *; }

# Video Player: Keep only main interface
-keep class io.flutter.plugins.videoplayer.VideoPlayerPlugin { *; }

# ============================================================================
# Crypto & Security
# ============================================================================
-keep class javax.crypto.** { *; }
-keep class javax.security.** { *; }
-keep class android.security.** { *; }
-keep class androidx.security.** { *; }

# ============================================================================
# Flutter & Dart Runtime
# ============================================================================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart type annotations
-keepclasseswithmembernames class **.** {
    native <methods>;
}

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# ============================================================================
# Reflection & Dynamic Loading
# ============================================================================
-keepclasseswithmembernames class * {
    public protected <init>(...);
}

# ============================================================================
# Optimization Settings
# ============================================================================
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Removes logging calls
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ============================================================================
# Warnings
# ============================================================================
-dontwarn com.google.**
-dontwarn com.android.**
-dontwarn java.lang.invoke.**
-dontwarn java.nio.file.**
-dontwarn javax.naming.**

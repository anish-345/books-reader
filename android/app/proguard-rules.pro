# Flutter specific rules - Keep all Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# Keep main application components
-keep public class * extends android.app.Application
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# PDF and EPUB specific
-keep class com.github.barteksc.pdfviewer.** { *; }
-keep class nl.siegmann.epublib.** { *; }

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Path provider
-keep class io.flutter.plugins.pathprovider.** { *; }



# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep essential annotations for Flutter
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes *Annotation*

# Keep Kotlin metadata
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-dontwarn kotlin.Unit
-dontwarn kotlin.jvm.internal.**

# Remove debug logging (safe optimization)
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Remove unused code warnings
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn android.support.**
-dontwarn androidx.**
-dontwarn java.lang.invoke.**

# Keep serialization
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Don't warn about missing classes
-dontwarn **
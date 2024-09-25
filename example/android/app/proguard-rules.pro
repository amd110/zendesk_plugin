# Conserve toutes les classes Zendesk
-keep class com.zendesk.** { *; }
-keep class zendesk.** { *; }
-keep interface zendesk.** { *; }

# Conserve les méthodes appelées par réflexion
-keepattributes Signature
-keepattributes *Annotation*

# Conserve les classes et méthodes Retrofit utilisées par Zendesk
-keep class retrofit2.** { *; }
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}

# Conserve les classes pour la gestion des logs
-keep class com.zendesk.logger.Logger { *; }

# Conserve les classes dans les modèles JSON
-keep class com.google.gson.** { *; }

# Optionnel : Garder les annotations de type @SerializedName
-keepattributes *Annotation*

# Exclure le SDK Zendesk de l'obfuscation
-dontwarn com.zendesk.**

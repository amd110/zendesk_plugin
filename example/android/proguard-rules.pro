# Garder toutes les classes Zendesk
-keep class zendesk.** { *; }
-keep interface zendesk.** { *; }
-keep class com.zendesk.** { *; }

# Garder les annotations Retrofit (si utilisé dans Zendesk)
-keepattributes Signature
-keepattributes *Annotation*

# Garder les classes générées par Retrofit
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# Garder les classes utilisées par Gson (si Zendesk les utilise)
-keep class com.google.gson.** { *; }

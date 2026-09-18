# jordan-twa

Proyecto Android (Trusted Web Activity, generado con Bubblewrap) que empaqueta el sitio
https://www.centrocristianojordan.com como app de Google Play (`com.centrocristianojordan.app`).
El sitio vive en el repo `jordan`.

## Generar un .aab nuevo

1. El keystore NO esta en este repo. Debe estar en `C:\Users\jorge\keys\jordan-android.keystore`
   (alias `jordan`; copia de respaldo en Drive).
2. En PowerShell, desde esta carpeta: `.\release.ps1` (pide contrasena del keystore y de la clave).
3. Sube `app-release-bundle.aab` en Play Console (Pruebas cerradas - Alpha).

`release.ps1` sube `appVersionCode` y pone el mismo numero en `startUrl` (`/?appv=N`); el sitio lo usa
para la pantalla de actualizacion obligatoria (`jordan/src/components/appUpdate`). No edites esos dos
valores a mano.

## Cosas que ya fallaron una vez

- `host` en `twa-manifest.json` debe ser `www.centrocristianojordan.com` (no el package name).
- El JDK que baja Bubblewrap es de 32 bits y revienta Gradle: usar un JDK 17 de 64 bits
  (`bubblewrap updateConfig --jdkPath <ruta>` o editar `~/.bubblewrap/config.json`).
- `twa-manifest.json` debe guardarse en UTF-8 sin BOM (con BOM, Bubblewrap no lo lee).

## Recrear todo en una maquina nueva

Lo que vive **fuera** de este repo y hay que reponer:

| Cosa | Donde esta |
|---|---|
| `jordan-android.keystore` (alias `jordan`) | Respaldo en Google Drive |
| Contrasena del keystore y de la clave | Tu gestor de contrasenas (no estan en ningun archivo) |
| Cuenta de Play Console | Panel de Play Console de la app |

Pasos:

1. Instala Git, Node.js (LTS) y un **JDK 17 de 64 bits** (Temurin). Bubblewrap descarga un JDK de 32 bits que
   revienta Gradle: no aceptes que lo instale.
2. `npm i -g @bubblewrap/cli`
3. `git clone git@github.com:jorgezamy/jordan-twa.git` y `git clone git@github.com:jorgezamy/jordan.git`
   (el segundo es el sitio; `assetlinks.json` esta en `jordan/public/.well-known/`).
4. Crea `~/.bubblewrap/config.json` apuntando a tu JDK y a la carpeta del SDK (Bubblewrap descarga el Android SDK
   si le dices que si; el JDK dile que no):
   ```json
   { "jdkPath": "C:\ruta\al\jdk-17", "androidSdkPath": "C:\Users\<tu-usuario>\.bubblewrap\android_sdk" }
   ```
5. Copia el keystore de Drive a la ruta de `signingKey.path` en `twa-manifest.json`
   (`C:/Users/jorge/keys/jordan-android.keystore`); si tu usuario es otro, cambia esa ruta.
6. En PowerShell, dentro de `jordan-twa`: `.\release.ps1`. El versionCode sigue desde el de `twa-manifest.json`,
   asi que no se repite ninguno ya subido a Play.

Si se **pierde el keystore**: en Play Console, Configuracion > Integridad de la app > Firma de apps, puedes pedir
un restablecimiento de la clave de carga (la de firma real la guarda Google). Despues hay que actualizar el
fingerprint en `jordan/public/.well-known/assetlinks.json`.

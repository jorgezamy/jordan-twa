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

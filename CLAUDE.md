# CLAUDE.md

Guidance for Claude Code in this repo. See `README.md` for the human-facing release steps.

## What this is

Bubblewrap-generated Android project (Trusted Web Activity) that wraps the Next.js site in the sibling repo
`jordan` (https://www.centrocristianojordan.com) as the Play Store app `com.centrocristianojordan.app`
(closed test "Alpha"). Almost everything under `app/` and `build.gradle` is **generated** by
`bubblewrap update` from `twa-manifest.json` — change `twa-manifest.json`, never the generated files.

## Releasing

Run `.\release.ps1` from PowerShell in this folder. It bumps `appVersionCode`, sets `startUrl` to
`/?appv=<versionCode>`, runs `bubblewrap update` + `bubblewrap build`, and produces `app-release-bundle.aab`.

- **Claude cannot run it**: `bubblewrap` prompts for the keystore/key passwords interactively and hangs or
  crashes without a TTY. Give the user the command to run themselves; never ask for or store the passwords.
- Never edit `appVersionCode`, `appVersion*` or `startUrl` by hand. The site (`jordan/src/components/appUpdate`)
  reads `?appv=` and compares it to `MIN_APP_VERSION` to force outdated app installs to update, so the URL
  number must always equal the versionCode.
- **After every new `.aab`, ask the user whether to force this version** (i.e. raise `MIN_APP_VERSION` in
  `jordan/src/components/appUpdate/constants.ts` to the new versionCode and push). It is never automatic. Only
  worth forcing when the Android shell changed; do it only after Play shows the release as available, or users get
  blocked with nothing to install.
- The signing keystore is **not** in this repo (`.gitignore` blocks `*.keystore`/`*.jks`). It lives at
  `C:\Users\jorge\keys\jordan-android.keystore` (alias `jordan`), with a backup in the user's Drive.
  Never commit it, and never write passwords into any file.

## Gotchas that already broke a build

- `host` must be `www.centrocristianojordan.com`, and `fullScopeUrl` must match it. The apex domain 308-redirects,
  and `assetlinks.json` (in the `jordan` repo, `public/.well-known/`) only answers 200 on `www`. Using the package
  name as host produces an app that opens a nonexistent URL.
- Read/write `twa-manifest.json` as **UTF-8 without BOM**. A BOM makes Bubblewrap fail with
  "is not valid JSON"; reading it as ANSI (PowerShell 5.1 `Get-Content`) turns "Jordán" into `JordÃƒÂ¡n`.
- Bubblewrap's auto-downloaded JDK is 32-bit and crashes Gradle ("Could not reserve enough space for object
  heap"). `~/.bubblewrap/config.json` must point `jdkPath` at a 64-bit JDK 17 (`~/.bubblewrap/jdk64/...`).
- `EBUSY: resource busy or locked` on `app\build` means a leftover Gradle `java.exe` or OneDrive sync holds a
  file; `release.ps1` stops Gradle and clears the build dirs first. If it persists, pause OneDrive sync.
- `bubblewrap update` deletes and regenerates the project; if it fails midway, `git status` shows many deleted
  files under `app/` — rerun `.\release.ps1` (or `git checkout -- app`) to restore them.

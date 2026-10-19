#!/usr/bin/env bash
# Build the launcher APK and install it on the TV as the default home screen.
set -euo pipefail
cd "$(dirname "$0")"
: "${TV_HOST:?set TV_HOST to the TV IP address, e.g. TV_HOST=192.168.1.50 $0}"
export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 17 2>/dev/null || echo /opt/homebrew/opt/openjdk@17)}"
export ANDROID_HOME="${ANDROID_HOME:-$([ -d ~/Library/Android/sdk ] && echo ~/Library/Android/sdk || echo /opt/homebrew/share/android-commandlinetools)}"
export PATH="$JAVA_HOME/bin:$PATH"
[ -f local.properties ] || echo "sdk.dir=$ANDROID_HOME" > local.properties
./gradlew assembleDebug -q --console=plain
PY=../tools/venv/bin/python
[ -x "$PY" ] || PY=../tools/venv/Scripts/python.exe
export MSYS_NO_PATHCONV=1
# Which app owns Home differs by build (com.google.android.tvlauncher on Android TV,
# com.google.android.apps.tv.launcherx on newer Google TV), so ask the TV instead of guessing.
# Ignore an answer of our own launcher, left over from a previous run of this script.
if [ -z "${STOCK_LAUNCHER:-}" ]; then
  STOCK_LAUNCHER=$("$PY" -I ../tools/tv.py \
    'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME' \
    | tail -n 1 | cut -d/ -f1 || true)
  case "$STOCK_LAUNCHER" in
    com.gathin.tvhome | *[!a-zA-Z0-9._]* | "") STOCK_LAUNCHER=com.google.android.tvlauncher ;;
  esac
  echo "Stock launcher: $STOCK_LAUNCHER"
fi
APK=app/build/outputs/apk/debug/app-debug.apk
"$PY" -I ../tools/b64push.py "$APK" /data/local/tmp/tvhome.apk
printf '%s\n' \
  "pm install -r /data/local/tmp/tvhome.apk" \
  "rm -f /data/local/tmp/tvhome.apk" \
  "pm grant com.gathin.tvhome android.permission.ACCESS_FINE_LOCATION 2>/dev/null; echo location-granted" \
  "cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity" \
  "pm disable-user --user 0 $STOCK_LAUNCHER" \
  "cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity" \
  | "$PY" -I ../tools/tv.py --batch
# Disabling the stock launcher clears the home preference, hence the second set-home above. A system HOME
# handler with intent-filter priority > 0 (e.g. Google TV's setupwraith RecoveryActivity) still beats any
# sideloaded launcher, whose priority is capped at 0; the TV then loops on a white screen.
HOME_NOW=$("$PY" -I ../tools/tv.py 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME' | tail -n 1)
if [[ "$HOME_NOW" != com.gathin.tvhome/* ]]; then
  "$PY" -I ../tools/tv.py "pm enable $STOCK_LAUNCHER" >/dev/null
  echo "Home still resolves to $HOME_NOW, which outranks the launcher. Stock launcher re-enabled."
  echo "Disable that package (see README, Troubleshooting) and run this script again."
  exit 1
fi
echo "Installed. Press Home on the remote to see it."

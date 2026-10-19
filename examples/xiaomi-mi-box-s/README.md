# Xiaomi Mi Box S / Mi Box 4 (MIBOX4), Android TV 9

Amlogic streaming box on firmware `PI.3933`. It ships Alphonso, which recognises what is on screen
and reports it for ad targeting, alongside PatchWall and Mi analytics. For the same box on the
Android TV 12 firmware, see [`xiaomi-mibox4/`](../xiaomi-mibox4/README.md).

All commands below run from the repo root, with the box's IP set once:

```bash
export TV_HOST=192.168.1.11
```

## What [`debloat.txt`](debloat.txt) disables

Packages are disabled, never uninstalled: Alphonso, Mi analytics, Google feedback and the
bug-report uploader, PatchWall and Mi Channel rows, Xiaomi web promos, the sponsored-row feed, Play
Auto Install, Xiaomi's update and download services, Live Channels and unused Google preloads. Some
sections are personal choices (voice, casting, the phone remote, the Ambient screensaver): comment
those lines out if you use them. The notes at the top of the file cover the remote, Home and USB
power.

**USB debugging cuts power to the box's USB port.** A USB speaker or drive goes dead while it is on.
Turn it off under Settings → Device Preferences → Developer options when you're done.

## A second unit, set up 2026-10-19

This unit kept everything in the personal-choice sections: Google Assistant, Chromecast, Mi cast,
Mi video player, the phone remote, firmware updates, TalkBack, the print spooler and the Ambient
screensaver. It disabled these 14 packages only:

```bash
for p in com.miui.tv.analytics com.google.android.feedback com.google.android.tv.bugreportsender \
         tv.alphonso.alphonso_eula com.mitv.tvhome.atv com.mitv.tvhome.michannel com.xm.webcontent \
         com.google.android.tvrecommendations android.autoinstalls.config.xioami.mibox3 \
         com.mitv.download.service com.google.android.play.games com.google.android.youtube.tvmusic \
         com.google.android.videos com.google.android.tv; do
  tools/venv/bin/python -I tools/tv.py "pm disable-user --user 0 $p"
done
```

Then it installed the launcher `com.gathin.tvhome` as Home and disabled the stock
`com.google.android.tvlauncher`. The Inputs pill hides itself because the box has no HDMI-in. All
installed apps were left alone. A backup of the original package list and settings is in
`backup/mibox4-a9-*/` (not committed).

## Undo everything

```bash
tools/restore.sh examples/xiaomi-mi-box-s/debloat.txt
```

This re-enables every package in the list, turns the stock launcher back on and makes it Home
again. It is safe to run on the second unit too: enabling a package that was never disabled does
nothing. To remove the new launcher as well, run
`tools/venv/bin/python -I tools/tv.py 'pm uninstall com.gathin.tvhome'`.

## Re-enable one app, change the dock or the wallpaper

These work the same as on the Android 12 box. See
[`xiaomi-mibox4/README.md`](../xiaomi-mibox4/README.md#re-enable-a-single-app). The dock is set in
the shared `launcher/app/src/main/res/values/config.xml`, so changing it there changes every
device you reinstall the launcher on. Then run:

```bash
launcher/build-and-install.sh
```

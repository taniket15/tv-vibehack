# Xiaomi Mi Box 4 (MIBOX4), Android TV 9

Same Amlogic box as [`xiaomi-mibox4/`](../xiaomi-mibox4/README.md), but on the older Android 9
firmware `PI.3933`. The preloads differ: this firmware ships Alphonso, which recognises what is on
screen and reports it for ad targeting. It has no `com.mi.bluetooth`, `xiaomi.statistic` or Mi TV+.

All commands below run from the repo root, with the box's IP set once:

```bash
export TV_HOST=192.168.1.11
```

## What was changed

- **Disabled** (never uninstalled) the packages in [`debloat.txt`](debloat.txt): Alphonso
  (`tv.alphonso.alphonso_eula`), Mi analytics, Google feedback and bug-report uploader,
  PatchWall / Mi channel content, Xiaomi's web-content promo view, the sponsored-row feed, Play Auto
  Install, Xiaomi's boot-time downloader, and the preloads you didn't tick (Play Games, YouTube
  Music, Google TV / Play Movies, Live Channels).
- **Installed the launcher** `com.gathin.tvhome` as default home and disabled the stock
  `com.google.android.tvlauncher`. Nothing else claimed Home, so the setup wizard stays enabled.
- **No Inputs pill**: the box has no HDMI-in or tuner, so the launcher hides it.
- **Kept**: the Bluetooth remote (`com.droidlogic.ble`, `partnercustomizer`), `mitv.service`,
  Gboard, Play Store and Play Services, Google Assistant, Chromecast, Mi cast, firmware updates,
  Mi Video player, and every app you installed (SmartTube, VLC, FX, Send Files to TV, JioHotstar,
  SonyLIV, ZEE5, Aaj Tak, JioCinema, Neverthink, AMPlayer).

A backup of the original package list and settings is in `backup/mibox4-a9-*/` (not committed).

## Undo everything

```bash
tools/restore.sh examples/xiaomi-mibox4-android9/debloat.txt
```

This re-enables every package in the list, turns the stock launcher back on and makes it home
again. To remove the new launcher too, run
`tools/venv/bin/python -I tools/tv.py 'pm uninstall com.gathin.tvhome'`.

## Re-enable one app, change the dock or the wallpaper

These work the same way as on the Android 12 box. See
[`xiaomi-mibox4/README.md`](../xiaomi-mibox4/README.md#re-enable-a-single-app). The dock is set in
the shared `launcher/app/src/main/res/values/config.xml`, so changing it there changes every
device you reinstall the launcher on. Then run:

```bash
launcher/build-and-install.sh
```

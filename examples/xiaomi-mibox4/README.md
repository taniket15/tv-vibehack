# Xiaomi Mi Box 4 (MIBOX4), Android TV 12

Amlogic streaming box, firmware `STTC.230106.001.4560`. The stock home screen is the Google TV
launcher with a "Sponsored by" row and an autoplaying hero banner.

All commands below run from the repo root, with the box's IP set once:

```bash
export TV_HOST=192.168.1.18
```

## What was changed

- **Disabled** (never uninstalled) the packages in [`debloat.txt`](debloat.txt): Mi analytics and
  statistics, Google feedback, PatchWall / Mi channel / Mi TV+ content, Xiaomi's web-content promo
  view, the sponsored-row feed, Play Auto Install, Xiaomi's boot-time downloader, and the preloads
  you didn't tick (Play Music, Play Games, YouTube Music, Google TV / Play Movies, Mi Video player,
  Live Channels).
- **Installed the launcher** `com.gathin.tvhome` as default home and disabled the stock
  `com.google.android.tvlauncher`. The setup wizard's `RecoveryActivity` did not take over Home on
  this firmware, so unlike the FlipkartTV it stays enabled.
- **No Inputs pill**: the box has no HDMI-in or tuner, so the launcher hides it and the top bar
  starts at Wi-Fi.
- **Kept**: the remote and its pairing (`com.mi.bluetooth`, `partnercustomizer`), `mitv.service`,
  Gboard, Play Store and Play Services, Google Assistant, Chromecast, Mi cast, firmware updates,
  Netflix, Prime Video, JioHotstar, YouTube, plus your own SmartTube, FX File Explorer and
  Send Files to TV.

A backup of the original package list and settings is in `backup/mibox4-*/` (not committed).

## Undo everything

```bash
tools/restore.sh examples/xiaomi-mibox4/debloat.txt
```

This re-enables every package in the list, turns the stock launcher back on and makes it home
again. The new launcher stays installed but unused; remove it with
`tools/venv/bin/python -I tools/tv.py 'pm uninstall com.gathin.tvhome'`.

## Re-enable a single app

```bash
tools/venv/bin/python -I tools/tv.py 'pm enable com.mitv.videoplayer'
```

Swap in any package name from `debloat.txt`. On the box itself: Settings → Apps → See all apps →
Show system apps → pick the app → Enable. It shows up on the home screen right away.

## Change the dock

Edit `dock_apps` in
[`launcher/app/src/main/res/values/config.xml`](../../launcher/app/src/main/res/values/config.xml).
The order of the lines is the order on screen, left to right:

```xml
<string-array name="dock_apps">
    <item>com.google.android.youtube.tv</item>     <!-- YouTube -->
    <item>com.netflix.ninja</item>                <!-- Netflix -->
    <item>com.amazon.amazonvideo.livingroom</item> <!-- Prime Video -->
    <item>in.startv.hotstar</item>                <!-- JioHotstar -->
</string-array>
```

Other package names on this box: SmartTube `org.smarttube.stable`, FX `nextapp.fx`,
Send Files to TV `com.yablio.sendfilestotv`, Mi screensaver settings (the "WallPaper" tile)
`com.mitv.dream`. Hide a tile by adding its package to `hidden_apps` in the same file. Then rebuild
and install:

```bash
launcher/build-and-install.sh
```

## Change the wallpaper

The background is pitch black by design. To use a picture instead:

1. Save a 1920×1080 JPEG as `launcher/app/src/main/res/drawable-nodpi/wallpaper.jpg`. Keep it
   dark and under about 300 KB: the box has 2 GB of RAM shared with video decoding.
2. In `launcher/app/src/main/res/layout/activity_main.xml`, change the root `FrameLayout`'s
   `android:background="#FF000000"` to `android:background="@drawable/wallpaper"`.
3. Run `launcher/build-and-install.sh`.

The ambient glow behind the dock still draws on top, tinted by the focused app.

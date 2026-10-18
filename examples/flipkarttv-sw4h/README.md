# FlipkartTV (Skyworth SW4H), Android TV 10

Built by Skyworth for Flipkart, MediaTek chipset, firmware `QTG3.200617.002`. The stock home screen
is the Google TV launcher with a "Sponsored by" row and an autoplaying hero banner.

All commands below run from the repo root, with the TV's IP set once:

```bash
export TV_HOST=192.168.1.12
```

## What was changed

- **Disabled** (never uninstalled) the packages in [`debloat.txt`](debloat.txt): the Alphonso ACR
  tracker, which fingerprints whatever is on screen, HDMI included; Google feedback uploaders; the
  sponsored-row feed; partner row customisers; Play Auto Install; the retail demo players; and
  preloads you didn't tick.
- **Disabled the Google setup wizard** (`com.google.android.tungsten.setupwraith`). Its
  `RecoveryActivity` claims Home with a priority no sideloaded launcher can beat, so with the stock
  launcher off the TV looped on a white screen. Firmware updates are unaffected: Settings → System
  update is served by Play Services.
- **Installed the launcher** `com.gathin.tvhome` as default home and disabled the stock
  `com.google.android.tvlauncher`.
- **Kept**: Live TV and the Source button (`com.smartdevice.livetv`), HDMI/AV/tuner inputs,
  Bluetooth, the remote's hotkeys, Gboard and LeanKey keyboards, Play Store and Play Services,
  Google Assistant, Chromecast, YouTube, SonyLIV, Twitch, and everything for USB drives: the
  Skyworth **MEDIA** player, FX File Explorer, VLC, Send Files to TV.

A backup of the original package list and settings is in `backup/flipkarttv-*/` (not committed).

## Undo everything

```bash
tools/restore.sh examples/flipkarttv-sw4h/debloat.txt
```

This re-enables every package in the list, including the setup wizard, turns the stock launcher
back on and makes it home again. The new launcher stays installed but unused; remove it with
`tools/venv/bin/python -I tools/tv.py 'pm uninstall com.gathin.tvhome'`.

## Re-enable a single app

```bash
tools/venv/bin/python -I tools/tv.py 'pm enable com.google.android.youtube.tvmusic'
```

Swap in any package name from `debloat.txt`. On the TV itself: Settings → Apps → See all apps →
Show system apps → pick the app → Enable. It shows up on the home screen right away.

## Change the dock

Edit `dock_apps` in
[`launcher/app/src/main/res/values/config.xml`](../../launcher/app/src/main/res/values/config.xml).
The order of the lines is the order on screen, left to right:

```xml
<string-array name="dock_apps">
    <item>org.smarttube.stable</item>             <!-- SmartTube -->
    <item>com.netflix.ninja</item>                <!-- Netflix -->
    <item>com.amazon.amazonvideo.livingroom</item> <!-- Prime Video -->
    <item>in.startv.hotstar</item>                <!-- JioHotstar -->
</string-array>
```

Other package names on this TV: YouTube `com.google.android.youtube.tv`, SonyLIV `com.sonyliv`,
Twitch `tv.twitch.android.app`, VLC `org.videolan.vlc`, USB media player `com.tianci.localmedia`.
Run `tools/venv/bin/python -I tools/tv.py 'pm list packages -3'` for the rest. Hide a tile by adding
its package to `hidden_apps` in the same file. Then rebuild and install:

```bash
launcher/build-and-install.sh
```

## Change the wallpaper

The background is pitch black by design. To use a picture instead:

1. Save a 1920×1080 JPEG as `launcher/app/src/main/res/drawable-nodpi/wallpaper.jpg`. Keep it
   dark and under about 300 KB: the TV has 1 GB of RAM and the tiles need contrast.
2. In `launcher/app/src/main/res/layout/activity_main.xml`, change the root `FrameLayout`'s
   `android:background="#FF000000"` to `android:background="@drawable/wallpaper"`.
3. Run `launcher/build-and-install.sh`.

The ambient glow behind the dock still draws on top, tinted by the focused app.

# Grid Clock Screensaver

A macOS screensaver that displays the current time as highlighted words in a 15×16 character grid.

This is a personal Swift rebuild of the original [Grid Clock Screensaver](https://github.com/chrstphrknwtn/grid-clock-screensaver) by [chrstphrknwtn](https://github.com/chrstphrknwtn). The design, grid layout, and word-clock concept are entirely his work — I rebuilt the implementation in Swift using `ScreenSaver.framework` and `QuartzCore` for my own use.

![Grid Clock Screenshot](GridClock.png)

## Install

Download the latest [`Grid Clock.saver`](https://github.com/adamaayala/grid-clock-screensaver/releases/latest) from Releases, then double-click the file to install.

Open **System Settings > Screen Saver** to activate it.

## Configuration

Right-click the screensaver preview and choose **Screen Saver Options** to set which display to use:

- Primary Display
- Last Focused Display
- All Displays

## How It Works

The time is read every second and mapped to highlighted words in the grid. Phrasing follows the classic word-clock convention:

- On the hour: *one o'clock*, *two o'clock*, etc.
- 1–12 min past: *five minutes past two*
- Quarter, half, and quarter-to landmarks
- 40+ min: counts down to the next hour (*twenty to three*)

Cell transitions animate between active (white) and inactive (`#222`) over 0.4s.

## Build from Source

Requires Xcode 15+ and macOS 14+.

```bash
xcodebuild -project "Grid Clock.xcodeproj" -scheme "Grid Clock" -configuration Release

cp -r ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Release/"Grid Clock.saver" \
  ~/Library/Screen\ Savers/
```

## Requirements

- macOS 14 (Sonoma) or later

## Credit

Original design and concept by [chrstphrknwtn](https://github.com/chrstphrknwtn).
Original repo: [github.com/chrstphrknwtn/grid-clock-screensaver](https://github.com/chrstphrknwtn/grid-clock-screensaver)

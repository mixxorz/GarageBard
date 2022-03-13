![GarageBard](./GarageBard/Assets.xcassets/AppIcon.appiconset/icon_256x256.png)

# GarageBard

An app for macOS that let's you play MIDI files as a bard on Final Fantasy XIV.

## Why

I find that hearing other players make music in-game adds to the atmosphere and
sense of community of the game. With GarageBard, I hope you'll be able to make
the game world feel more alive.

Plus [BardMusicPlayer](https://bardmusicplayer.com/) is Windows only, but I play
on a MacBook... so I made this instead.

## How does it work?

You load up some MIDI files, and GarageBard "plays" them by sending keystrokes
to the game.

## Screenshots

![Screenshots](https://user-images.githubusercontent.com/3102758/158063994-fe2b0857-8a58-426b-ab85-68f0c9fa44fb.png)

## Instructions

1. Download the [latest release](https://github.com/mixxorz/GarageBard/releases/latest) from GitHub.
1. Copy GarageBard to your Applications folder
1. Launch GarageBard and grant it Accessibility access
1. Load up some songs by dragging in MIDI files into GarageBard
1. Double click a song to queue it up
1. Click the tracks icon to choose which track to play
1. Go to Performance mode in the game with your choice of instrument
1. Set up your keybindings according to the chart below
1. On GarageBard, open the settings menu and select "Cmd+Tab on play" to
   automatically switch to the game when you hit play
1. Click Play (spacebar)
1. Rock out 🤘

### Performance mode keybindings

![Performance mode keybindings](https://user-images.githubusercontent.com/3102758/158063314-6fcbc177-d41f-4fb5-bd04-8c24ea7040ee.png)

## Usage

### Perform/Listen modes

You can swap between Perform and Listen modes depending on what you want to do:

- **Perform**: Send keystrokes to play the song
- **Listen**: Listen to the song using GarageBard's synthesizer

### Cmd+Tab on play

This tells GarageBard to automatically hit Cmd+Tab as soon as you hit Play,
allowing you to automatically switch focus back to the game.

Note that GarageBard isn't doing anything smart to switch to the game. It is
literally just hitting Cmd+Tab, so make sure that the game was the last focused
app.

## Troubleshooting

**GarageBard needs Accessibility access in order to send keystrokes to Final Fantasy XIV.**

GarageBard works by sending keystrokes to the game process. In order to do this,
the app needs to have Accessibility permissions.

To grant GarageBard permissions, click on the message then click "Open System
Preferences" on the dialog that pops up. In the System Preferences window that
opens, click the lock on the bottom left of the window to unlock the settings.
Tick the checkbox next to GarageBard in the list of apps under Accessibility.
Finally, close System Preferences.

You know you've done this correctly when the message disappears from GarageBard.

**Can't find game instance. Is the game running?**

This message means that GarageBard was unable to find the game process. When
this happens, the app falls back to sending keystrokes to _any_ app that is in
the foreground.

If the game _is_ running but you still this message, you can still make it work
as long as you have the game focused.

If you have time, please [open an issue](https://github.com/mixxorz/GarageBard/issues/new)
so I can make the process detection better.

**Some notes are out of range**

This message means that there are some notes on the selected track of the
current song that fall beyond the range of what can be played in the game. When
GarageBard encounters these notes, it simply ignores them.

The only way to fix this issue is to manually tweak the song using a MIDI editor
so that none of the notes fall below C2 and above C5.

# License

Copyright (c) 2022 Mitchel Cabuloy

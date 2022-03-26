<img width="180" src="./GarageBard/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" alt="GarageBard icon">

# GarageBard

An app for macOS that lets you play MIDI files as a bard on Final Fantasy XIV.

<a href="https://github.com/mixxorz/GarageBard/releases/latest/download/GarageBard-1.1.1.dmg">
   <img width="150" src="https://user-images.githubusercontent.com/3102758/158105072-519b1bbe-2d58-4aa0-a534-f1858add2e9b.png" alt="Download button">
</a>

## Why

I find that hearing other players make music in-game adds to the atmosphere and
sense of community of the game. With GarageBard, I hope you'll be able to make
the game world feel more alive.

Plus [BardMusicPlayer](https://bardmusicplayer.com/) is Windows only, but I play
on a MacBook... so I made this instead.

## How does it work?

You load up MIDI files and GarageBard "plays" them by sending keystrokes to the game.

## Screenshots

![Screenshots](https://user-images.githubusercontent.com/3102758/159173959-b97f8fb1-eb0d-4f30-aa24-fb4e34f6536e.png)

## Instructions

1. Download the [latest release](https://github.com/mixxorz/GarageBard/releases/latest/download/GarageBard-1.1.1.dmg) from GitHub.
1. Copy GarageBard to your Applications folder
1. Launch GarageBard and grant it Accessibility access
1. Load songs by dragging MIDI files into GarageBard
1. Double click a song to queue it up
1. Click the tracks icon to choose which track to play
1. Go to Performance mode in the game with your choice of instrument
1. Set up your keybindings according to the chart below
1. Click Play (spacebar)
1. Rock out 🤘

### Performance mode keybindings

![Performance mode keybindings](https://user-images.githubusercontent.com/3102758/158063314-6fcbc177-d41f-4fb5-bd04-8c24ea7040ee.png)

_(This is needed because the default keybinds do not have keybinds for all the notes.)_

## Usage

GarageBard works like a typical music player. You can queue, play, pause, stop,
seek, add, remove, and reorder songs.

### Player

**Tracks**

Let's you choose which track to play.

MIDI files can contain one or more tracks for different instruments. The track
selector lets you select which track GarageBard should play.

It's possible to see strange behaviour with the track selector as some MIDI
files are better formatted than others. If you're having issues, one thing you
can try is to import the MIDI file into [MuseScore](https://musescore.org/en)
and reexport it as MIDI.

**Overlay mode**

When enabled, GarageBard will stay on top of the game so that it's always
visible. This can be activated by clicking the icon on the top right of the
window.

This is handy as it's useful to see GarageBard while the game is running.

### Settings

**Perform**

Send keystrokes to the game to play the song.

Normally, GarageBard sends these keystrokes directly to the game instance, but
if it's unable to find the game instance, the keystrokes are sent to the
frontmost window.

**Listen**

Listen to the song using GarageBard's synthesizer.

Useful for auditioning songs before performing them in game.

**Loop song**

Repeat the current song after it ends.

Song looping is in time with the beat. That means if you have a 4 beat MIDI
file, those 4 beats will loop with the correct tempo/cadence.

**Loop session**

Play the first song in the session after the last song ends.

This only works if continuous playback is also turned on.

**Continuous playback**

Play the songs in the session one after another.

### Effects

**Transpose**

Shows the range of notes on this track.

Type a number to transpose by semitones (e.g. +7, -5). Type a note name to set
the lowest note (e.g. C2, G#3). Prefix the note name with a "-" to set the
highest note (e.g. -C5, -F#4).

(The game can play notes from C2 to C5.)

**Octave remap**

Adjusts all notes to fit within the game's playable range (C2-C5).

Notes outside the range are transposed N octaves up or down until they're within
the range (e.g. D1->D2, A#7->A#4).

**Arpeggiate**

Ensures that a chord's notes are played in ascending order.

Notes played concurrently are played in ascending order (e.g. If G, C, and E are
played at the same time, C is played first, then E, then G).

This will generally make chords sound better so it's a good option to have on.

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

If the game _is_ running but you still see this message, it can still work
as long as you have the game focused.

If you have time, please [open an issue](https://github.com/mixxorz/GarageBard/issues/new)
so I can make the process detection better.

**Some notes are out of range**

This message means that there are some notes on the current track that fall
beyond the range of what can be played in the game.

GarageBard provides a couple of tools to mitigate this; the transposer and the
octave remapper. You can try to transpose the track so that all the notes fall
within C2-C5. Otherwise, you can turn on the octave remapper (on by default)
which will automatically transpose out of range notes to fit within playable
range.

The best but hardest way to address this issue is to manually edit the song
using a MIDI editor so that all notes fall above C2 and below C5.

# License

Copyright (c) 2022 Mitchel Cabuloy

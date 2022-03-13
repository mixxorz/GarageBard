#!/bin/sh
test -f GarageBard.dmg && rm GarageBard.dmg
create-dmg \
  --volname "GarageBard" \
  --background "installer_background.png" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "GarageBard.app" 212 182 \
  --hide-extension "GarageBard.app" \
  --app-drop-link 588 182 \
  "GarageBard.dmg" \
  "source_folder/"

# Publishing a new release

Bump the version under GarageBard -> Targets -> GarageBard -> Info.

Version should be human readable semver version (e.g. 1.2.0).
Build number should be incremented by 1.

Update `CHANGELOG.md`.

Build a release using XCode. Product -> Archive. Click Distribute -> Developer
ID and continue with code signing and notarization.

Copy the resulting GarageBard.app file into Installer/source_folder.

Then run:

```
cd Installer
poetry install
poetry shell
python build_release.py <human-readable-version> <build-number>
```

The script will:

1. Create the DMG
2. Sign the DMG with Sparkle EdDSA
3. Update the `appcast.xml` file

Check that the `appcast.xml` file is valid.

Commit the changes and tag the commit with the human readable version.

```
git commit -m "Prepare release 1.2.0"
git tag -a 1.2.0 -m "Release 1.2.0 2022-03-20"
git push && git push --tags
```

Make a new release on GitHub with the new tag. Attach the DMG file (e.g.
`GarageBard-1.2.0.dmg`) to the release. Update the README download links to
point to the latest release DMG.

Test the new update by opening an older version of GarageBard and going to
GarageBard -> Check for updates.

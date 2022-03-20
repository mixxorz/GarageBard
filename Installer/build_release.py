import argparse
import os
import subprocess
from datetime import datetime
from zoneinfo import ZoneInfo

import xmltodict

parser = argparse.ArgumentParser(description='Build a release.')
parser.add_argument('version', help='Human readable version number. (e.g. 1.0.0)')
parser.add_argument('build', help='Build number. (e.g. 1)')

args = parser.parse_args()
version = args.version
build_number = args.build

dmg_filename = f"GarageBard-{version}.dmg"

try:
    print("Cleaning up...")
    os.remove(dmg_filename)
except OSError:
    pass

# Create the DMG
print("[1/4] Creating DMG...")
out = subprocess.run([
    "create-dmg",
    "--volname", "GarageBard",
    "--background", "installer_background.png",
    "--window-pos", "200", "120",
    "--window-size","800", "400",
    "--icon-size", "100",
    "--icon", "GarageBard.app", "212", "182",
    "--hide-extension", "GarageBard.app",
    "--app-drop-link", "588", "182",
    dmg_filename,
    "source_folder",
], capture_output=True)

if out.returncode != 0:
    print(out.stdout.decode('utf-8'))
    print(out.stderr.decode('utf-8'))
    exit(1)

# Sign the DMG with Sparkle
print("[3/4] Signing DMG...")
out = subprocess.run(['sparkle_sign_update', dmg_filename], capture_output=True)

if out.returncode != 0:
    print(out.stdout.decode('utf-8'))
    print(out.stderr.decode('utf-8'))
    exit(1)

parts = out.stdout.decode('utf-8').split('"')
signature = parts[1]
length = parts[3]

print("      ---> Signature: " + signature)
print("      ---> Length: " + length)

# Update appcast.xml
print("[4/4] Updating appcast.xml...")

now = datetime.now(ZoneInfo('Asia/Manila'))

with open('appcast.xml', 'r') as f:
    xml = f.read()
    tree = xmltodict.parse(xml)
    new_item = {
        'title': version,
        'pubDate': now.strftime("%a, %d %b %Y %H:%M:%S %z"),
        'ns0:version': build_number,
        'ns0:shortVersionString': version,
        'ns0:minimumSystemVersion': '12.1',
        'enclosure': {
            '@url': f'https://github.com/mixxorz/GarageBard/releases/download/{version}/{dmg_filename}',
            '@type': 'application/octet-stream',
            '@length': length,
            '@ns0:edSignature': signature,
        }
    }

    item = tree['rss']['channel']['item']

    if isinstance(item, list):
        item.insert(0, new_item)
    else:
        tree['rss']['channel']['item'] = [new_item, item]

with open('appcast.xml', 'w') as f:
    f.write(xmltodict.unparse(tree, pretty=True))

print('Done!')

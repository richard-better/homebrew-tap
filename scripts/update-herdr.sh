#!/usr/bin/env bash
# Moves the Herdr cask to the newest release in Herdr's release manifest, and writes the cask the
# first time. Never goes back to an older version.
#
# Usage: scripts/update-herdr.sh
set -euo pipefail

releases=https://releases.herdr.dev
cask=Casks/herdr.rb
current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$cask" 2> /dev/null || true)"

temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT
curl -fsSL "$releases/app/latest.json" -o "$temporary/latest.json"
read -r latest url expected < <(python3 -c '
import json, sys
manifest = json.load(open(sys.argv[1]))
target = manifest["targets"]["macos-aarch64"]
print(manifest["version"], target["url"], target["sha256"])
' "$temporary/latest.json")

newer="$(python3 -c '
import sys
def key(version):
    return [int(part) for part in version.split(".")]
latest, current = sys.argv[1], sys.argv[2]
print("yes" if not current or key(latest) > key(current) else "")
' "$latest" "$current")"
if [[ -z "$newer" ]]; then
  echo "herdr is up to date${current:+ at $current}"
  exit 0
fi

[[ "$url" == "$releases/app/$latest/herdr-app-macos-aarch64.tar.gz" ]] ||
  { echo "Unexpected download URL $url" >&2; exit 1; }
curl -fsSL "$url" -o "$temporary/herdr-app.tar.gz"
checksum="$(shasum -a 256 "$temporary/herdr-app.tar.gz" | cut -d ' ' -f 1)"
[[ "$checksum" == "$expected" ]] ||
  { echo "herdr-app-macos-aarch64.tar.gz does not match the manifest" >&2; exit 1; }

mkdir -p Casks
cat > "$cask" <<EOF
cask "herdr" do
  version "$latest"
  sha256 "$checksum"

  url "$releases/app/#{version}/herdr-app-macos-aarch64.tar.gz"
  name "Herdr"
  desc "Native app for coding agents that keep running when it closes"
  homepage "https://herdr.dev/"

  livecheck do
    url "$releases/app/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on :macos

  app "Herdr.app"
  binary "#{appdir}/Herdr.app/Contents/MacOS/Herdr", target: "herdr-app"
end
EOF
ruby -c "$cask"
echo "herdr is now at $latest"

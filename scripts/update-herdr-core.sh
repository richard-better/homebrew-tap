#!/usr/bin/env bash
# Moves the herdr-core formula to the newest release in herdr-core's release manifest, and writes
# the formula the first time. Never goes back to an older version.
#
# Usage: scripts/update-herdr-core.sh
set -euo pipefail

releases=https://releases.herdr.dev
formula=Formula/herdr-core.rb
current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$formula" 2> /dev/null || true)"

temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT
curl -fsSL "$releases/core/latest.json" -o "$temporary/latest.json"
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
  echo "herdr-core is up to date${current:+ at $current}"
  exit 0
fi

[[ "$url" == "$releases/core/$latest/herdr-core-macos-aarch64.tar.gz" ]] ||
  { echo "Unexpected download URL $url" >&2; exit 1; }
curl -fsSL "$url" -o "$temporary/herdr-core.tar.gz"
checksum="$(shasum -a 256 "$temporary/herdr-core.tar.gz" | cut -d ' ' -f 1)"
[[ "$checksum" == "$expected" ]] ||
  { echo "herdr-core-macos-aarch64.tar.gz does not match the manifest" >&2; exit 1; }

mkdir -p Formula
cat > "$formula" <<EOF
class HerdrCore < Formula
  desc "Terminals for coding agents that keep running"
  homepage "https://github.com/herdrdev/herdr-core"
  url "$releases/core/$latest/herdr-core-macos-aarch64.tar.gz"
  version "$latest"
  sha256 "$checksum"
  license "Apache-2.0"

  livecheck do
    url "$releases/core/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "herdr-core"
    bin.install_symlink "herdr-core" => "hc"
  end

  def caveats
    <<~EOS
      A running core keeps its old version after an upgrade. Restart it with:
        hc server restart
      Your terminals keep running.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/herdr-core --version")
  end
end
EOF
ruby -c "$formula"
echo "herdr-core is now at $latest"

#!/usr/bin/env bash
# Moves the TrainStack Ride cask for a channel to the newest published release, and writes the
# cask the first time. Never goes back to an older version, even if newer releases were deleted.
#
# Usage: scripts/update-trainstack-ride.sh stable|alpha
set -euo pipefail

repository=richard-better/trainstack
case "${1:-}" in
  stable) token=trainstack-ride other=trainstack-ride@alpha name="TrainStack Ride" prerelease=false ;;
  alpha) token=trainstack-ride@alpha other=trainstack-ride name="TrainStack Ride Alpha" prerelease=true ;;
  *) echo "Usage: $0 stable|alpha" >&2; exit 64 ;;
esac
cask="Casks/$token.rb"
current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$cask" 2> /dev/null || true)"

# Named releases are ride-v1.2.3. Alphas are ride-v<marketing>-alpha.<build>, where marketing is
# 1.2 or 1.2.3 and the build is the UTC time it was made, yyMMddHHmm. Prints the newest, if it is
# newer than the cask's current version.
latest="$(gh api --paginate "repos/$repository/releases" \
  --jq ".[] | select((.draft | not) and .prerelease == $prerelease) | .tag_name" |
  python3 -c '
import re, sys
channel, current = sys.argv[1], sys.argv[2]
pattern = r"ride-v(\d+\.\d+\.\d+)" if channel == "stable" else r"ride-v(\d+\.\d+(?:\.\d+)?-alpha\.\d+)"
def key(version):
    marketing, _, build = version.partition("-alpha.")
    parts = [int(part) for part in marketing.split(".")] + [0]
    return (parts[:3], int(build or 0))
versions = [m.group(1) for m in (re.fullmatch(pattern, line.strip()) for line in sys.stdin) if m]
if versions and (not current or key(max(versions, key=key)) > key(current)):
    print(max(versions, key=key))
' "$1" "$current")"
if [[ -z "$latest" ]]; then
  echo "$token is up to date${current:+ at $current}"
  exit 0
fi

temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT
gh release download "ride-v$latest" --repo "$repository" --dir "$temporary" \
  --pattern SHA256SUMS --pattern "Ride-$latest.zip"
checksum="$(shasum -a 256 "$temporary/Ride-$latest.zip" | cut -d ' ' -f 1)"
[[ "$(cat "$temporary/SHA256SUMS")" == "$checksum  Ride-$latest.zip" ]] ||
  { echo "Ride-$latest.zip does not match SHA256SUMS" >&2; exit 1; }

mkdir -p Casks
cat > "$cask" <<EOF
cask "$token" do
  version "$latest"
  sha256 "$checksum"

  url "https://github.com/$repository/releases/download/ride-v#{version}/Ride-#{version}.zip"
  name "$name"
  desc "Indoor cycling workouts for smart trainers"
  homepage "https://trainstackhq.com/"

  conflicts_with cask: "$other"
  depends_on macos: ">= :tahoe"

  app "Ride.app"

  zap trash: "~/Library/Containers/com.trainstackhq.ride"
end
EOF
ruby -c "$cask"
echo "$token is now at $latest"

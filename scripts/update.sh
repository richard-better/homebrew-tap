#!/usr/bin/env bash
set -euo pipefail
release="$(gh release view --repo richard-better/switcheroo --json tagName,isDraft,isPrerelease)"
tag="$(printf '%s' "$release" | python3 -c 'import json,sys; r=json.load(sys.stdin); assert not r["isDraft"] and not r["isPrerelease"]; print(r["tagName"])')"
[[ "$tag" =~ ^switcheroo-v([1-9][0-9]{0,3}\.(0|[1-9][0-9]?)\.(0|[1-9][0-9]?))$ ]] || { echo 'Unexpected Switcheroo release tag' >&2; exit 1; }
version="${BASH_REMATCH[1]}"
temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT
gh release download "$tag" --repo richard-better/switcheroo --dir "$temporary" \
  --pattern switcheroo.rb --pattern SHA256SUMS --pattern "Switcheroo-$version.zip"
checksum="$(shasum -a 256 "$temporary/Switcheroo-$version.zip" | cut -d ' ' -f 1)"
[[ "$(cat "$temporary/SHA256SUMS")" == "$checksum  Switcheroo-$version.zip" ]]
grep -Fx "  version \"$version\"" "$temporary/switcheroo.rb"
grep -Fx "  sha256 \"$checksum\"" "$temporary/switcheroo.rb"
ruby -c "$temporary/switcheroo.rb"
mkdir -p Casks
cp "$temporary/switcheroo.rb" Casks/switcheroo.rb

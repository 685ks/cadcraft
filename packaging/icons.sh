#!/usr/bin/env bash
# Regenerate every app icon file from assets/app-icon/cadcraft.svg.
#
# Needs: resvg (cargo install resvg). On macOS, iconutil also writes the .icns. The outputs are
# committed, so building and packaging never need these tools.
#
#   packaging/icons.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT/assets/app-icon"
SVG="$DIR/cadcraft.svg"
ID="app.freedev.ainz.ks.CADCraft"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v resvg >/dev/null || { echo "error: resvg not found (cargo install resvg)" >&2; exit 1; }

# The SVG is the full-bleed 512 tile (rx=112), used as is on Windows and Linux. macOS icons follow
# Apple's grid: an 824/1024 body with a transparent margin, made by widening the viewBox.
MAC="$TMP/macos.svg"
sed 's/viewBox="0 0 512 512"/viewBox="-62 -62 636 636"/' "$SVG" >"$MAC"
grep -q 'viewBox="-62 -62 636 636"' "$MAC" || { echo "error: unexpected viewBox in $SVG" >&2; exit 1; }

render() { resvg -w "$2" -h "$2" "$1" "$3" </dev/null; }

render "$SVG" 1024 "$DIR/cadcraft-1024.png"
render "$SVG" 64 "$DIR/cadcraft-64.png"
render "$SVG" 256 "$DIR/cadcraft-256.png"
# Runtime window icon on macOS (embedded by apps/cadcraft/src/main.rs).
render "$MAC" 512 "$DIR/cadcraft-macos-512.png"

# Linux hicolor theme.
for s in 16 24 32 48 64 128 256 512; do
  mkdir -p "$DIR/hicolor/${s}x${s}/apps"
  render "$SVG" "$s" "$DIR/hicolor/${s}x${s}/apps/$ID.png"
done
if [ -d "$DIR/hicolor/scalable/apps" ]; then
  cp "$SVG" "$DIR/hicolor/scalable/apps/$ID.svg"
fi

# Windows .ico.
ICO_PNGS=()
for s in 16 20 24 32 40 48 64 128 256; do
  render "$SVG" "$s" "$TMP/ico-$s.png"
  ICO_PNGS+=("$TMP/ico-$s.png")
done
(cd "$ROOT" && cargo run -q -p xtask -- ico "$DIR/cadcraft.ico" "${ICO_PNGS[@]}")

# macOS .icns.
if command -v iconutil >/dev/null; then
  SET="$TMP/cadcraft.iconset"
  mkdir -p "$SET"
  for s in 16 32 128 256 512; do
    render "$MAC" "$s" "$SET/icon_${s}x${s}.png"
    render "$MAC" $((s * 2)) "$SET/icon_${s}x${s}@2x.png"
  done
  iconutil -c icns -o "$DIR/cadcraft.icns" "$SET"
else
  echo "warning: iconutil not found (macOS only); cadcraft.icns not regenerated" >&2
fi
echo "icons written to $DIR"

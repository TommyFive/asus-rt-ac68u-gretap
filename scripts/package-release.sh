#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
VERSION=${1:-386.14_2-gretap1}
DIST=$ROOT/dist
PKG=asus-rt-ac68u-gretap-$VERSION
SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-1731869259}

"$ROOT/scripts/verify-build.sh"
rm -rf "$DIST/$PKG"
mkdir -p "$DIST/$PKG"

cp "$ROOT/release/ip_gre_asus_pptpfix_nodf.ko" "$DIST/$PKG/"
cp "$ROOT/release/SHA256SUMS" "$DIST/$PKG/"
cp "$ROOT/README.md" "$DIST/$PKG/"
cp "$ROOT/BUILD.md" "$DIST/$PKG/"
cp "$ROOT/COMPATIBILITY.md" "$DIST/$PKG/"
cp "$ROOT/LICENSE" "$DIST/$PKG/"

(
    cd "$DIST"
    tar --sort=name \
        --mtime="@$SOURCE_DATE_EPOCH" \
        --owner=0 --group=0 --numeric-owner \
        -czf "$PKG.tar.gz" "$PKG"
    sha256sum "$PKG.tar.gz" > "$PKG.tar.gz.sha256"
)

printf 'Created: %s\n' "$DIST/$PKG.tar.gz"
printf 'Checksum: %s\n' "$DIST/$PKG.tar.gz.sha256"

#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
EXPECTED_SHA256=ffef775266b8faf21d6dbf60fb3ef95ff28bd2ab6a553af14457c24c9d48fc9e
EXPECTED_VERMAGIC='2.6.36.4brcmarm SMP preempt mod_unload modversions ARMv7'
EXPECTED_SRCVERSION='3DB181D5D785DEC4377B55C'

trim_trailing_ws() {
    sed 's/[[:space:]]*$//'
}

check_one() {
    f=$1
    [ -f "$f" ] || return 0

    echo "=== $f ==="
    sha=$(sha256sum "$f" | awk '{print $1}')
    echo "sha256:  $sha"
    [ "$sha" = "$EXPECTED_SHA256" ] || {
        echo "ERROR: unexpected SHA-256 for $f" >&2
        exit 1
    }

    if command -v modinfo >/dev/null 2>&1; then
        vermagic=$(modinfo -F vermagic "$f" 2>/dev/null | trim_trailing_ws || true)
        license=$(modinfo -F license "$f" 2>/dev/null | trim_trailing_ws || true)
        srcversion=$(modinfo -F srcversion "$f" 2>/dev/null | trim_trailing_ws || true)
        aliases=$(modinfo -F alias "$f" 2>/dev/null | trim_trailing_ws || true)
        echo "vermagic:   $vermagic"
        echo "license:    $license"
        echo "srcversion: $srcversion"
        printf 'aliases:\n%s\n' "$aliases"

        [ "$vermagic" = "$EXPECTED_VERMAGIC" ] || {
            echo "ERROR: unexpected vermagic" >&2
            exit 1
        }
        [ "$license" = GPL ] || {
            echo "ERROR: unexpected module license" >&2
            exit 1
        }
        [ "$srcversion" = "$EXPECTED_SRCVERSION" ] || {
            echo "ERROR: unexpected srcversion" >&2
            exit 1
        }
        printf '%s\n' "$aliases" | grep -qx 'rtnl-link-gre'
        printf '%s\n' "$aliases" | grep -qx 'rtnl-link-gretap'
    fi
}

RELEASE=$ROOT/release/ip_gre_asus_pptpfix_nodf.ko
[ -f "$RELEASE" ] || {
    echo "ERROR: release module missing" >&2
    exit 1
}

check_one "$RELEASE"
check_one "$ROOT/build-output/ip_gre_asus_pptpfix_nodf.ko"

echo 'Verification OK.'

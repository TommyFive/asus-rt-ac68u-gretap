# ASUS RT-AC68U GRETAP module for Asuswrt-Merlin 386.14_2

Reproducible build of the Linux `ip_gre` kernel module used to add GRE/GRETAP support to an ASUS RT-AC68U running **Asuswrt-Merlin 386.14_2**.

## Scope

The prebuilt module is validated only for:

- Device: ASUS RT-AC68U
- Firmware: Asuswrt-Merlin 386.14_2
- Kernel: `2.6.36.4brcmarm`
- Architecture: ARMv7
- Compiler: `arm-brcm-linux-uclibcgnueabi-gcc 4.5.3`
- Module vermagic: `2.6.36.4brcmarm SMP preempt mod_unload modversions ARMv7`

Do **not** assume compatibility with another router model, firmware release, kernel build, or vendor image.

## What is changed

The stock Merlin kernel source contains GRE/GRETAP support, but this RT-AC68U firmware does not ship a usable `ip_gre.ko` for this use case. This project:

1. builds `CONFIG_NET_IPGRE=m` with GRETAP netlink support;
2. adds an RT-AC68U / Merlin 386.14_2 coexistence shim for the built-in PPTP GRE protocol handler;
3. adds a GRETAP-specific `nopmtudisc` fix so an inner IPv4 DF bit is not automatically copied to the outer GRE IPv4 header for Ethernet tunnels when PMTU discovery is disabled.

The coexistence shim has exact kernel-layout guards. It verifies the expected symbol addresses before displacing the built-in PPTP GRE handler. If the guard does not match, the module refuses to load.

## Source provenance

Asuswrt-Merlin source:

- upstream: `https://github.com/RMerl/asuswrt-merlin.ng.git`
- tag: `386.14_2`
- pinned commit: `6a5df61aab6f3fa2dffc518994d42e4f2a27fb2b`

Merlin toolchain:

- upstream: `https://github.com/RMerl/am-toolchains.git`
- pinned commit: `d1af80e6b6686a4edc680386c09a8361453dd5c1`
- toolchain: `brcm-arm-sdk/hndtools-arm-linux-2.6.36-uclibc-4.5.3`

No complete Merlin source tree or Broadcom toolchain is vendored in this repository.

## Repository contents

- `patches/0001-rt-ac68u-gretap-pptp-coexistence-nodf.patch` — source change against the pinned Merlin tree
- `config/gretap.config` — relevant GRE config delta
- `build-support/kernel.config` — exact kernel config used for the module build
- `build-support/sdk.config` — RT-AC68U SDK-level config required by the Broadcom kernel Makefile
- `build-support/Module.symvers` — matching symbol-version data for `CONFIG_MODVERSIONS`
- `scripts/build.sh` — pinned reproducible build helper
- `scripts/verify-build.sh` — checksum and module-metadata verification
- `scripts/package-release.sh` — deterministic release archive builder
- `release/ip_gre_asus_pptpfix_nodf.ko` — prebuilt reproducible module
- `release/SHA256SUMS` — release checksum

## Build

See [BUILD.md](BUILD.md). The short version is:

```sh
./scripts/build.sh
./scripts/verify-build.sh
```

The result is written to `build-output/ip_gre_asus_pptpfix_nodf.ko`.

Default build parallelism is intentionally `MAKE_JOBS=1`. Use a dedicated build host; do not run heavy builds on a production VPN/gateway server.

## Reproducible release artifact

The unstripped module contains absolute DWARF source paths, so its raw build-id and SHA-256 vary with the build directory. The release step removes only debug data and `.note.gnu.build-id`, while retaining code, data, relocations, symbols, `.modinfo` and `__versions`.

Expected release SHA-256:

```text
ffef775266b8faf21d6dbf60fb3ef95ff28bd2ab6a553af14457c24c9d48fc9e
```

Validated metadata:

```text
alias:      rtnl-link-gretap
alias:      rtnl-link-gre
license:    GPL
srcversion: 3DB181D5D785DEC4377B55C
vermagic:   2.6.36.4brcmarm SMP preempt mod_unload modversions ARMv7
```

## Runtime caution

Test the module temporarily before configuring persistent autoload. While loaded, it intentionally takes ownership of IP protocol 47 (GRE) and restores the expected built-in PPTP GRE handler when unloaded.

Because the patch is tied to exact kernel symbol addresses, any firmware upgrade must be treated as incompatible until the guards, ABI and module have been revalidated.

## License

The kernel-derived patch and module follow the upstream GPL terms. See [LICENSE](LICENSE).

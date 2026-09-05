# Build instructions

The build is pinned to the exact source and toolchain revisions used for the RT-AC68U / Asuswrt-Merlin 386.14_2 module.

## Requirements

A Linux build host with:

- `git`
- GNU `make`
- GNU `binutils` tools supplied by the pinned Merlin cross-toolchain
- standard shell/coreutils
- enough disk space for the Merlin source and toolchain

Internet access is required only when the pinned dependencies are not already present locally.

Do not run this build on a production VPN/gateway host. The default is deliberately `MAKE_JOBS=1`; use a dedicated build machine if you want to increase parallelism.

## Automated build

From the repository root:

```sh
./scripts/build.sh
```

The script will:

1. obtain the pinned Asuswrt-Merlin source if needed;
2. obtain the pinned Merlin ARM toolchain if needed;
3. verify both git revisions;
4. restore the RT-AC68U SDK-level build configuration required by the Broadcom kernel Makefile;
5. restore the exact kernel configuration used for this build;
6. apply the GRETAP/PPTP/DF patch;
7. run `oldconfig`, `prepare` and `modules_prepare`;
8. clean the `net/ipv4` module subtree to avoid stale build products;
9. restore the matching `Module.symvers` data;
10. build the `net/ipv4` module set with `M=net/ipv4 modules` and one make job by default;
11. copy `ip_gre.ko` to `build-output/ip_gre_asus_pptpfix_nodf.ko`;
12. strip DWARF debug data and the GNU build-id from the copied release artifact so the runtime module is reproducible across different absolute build paths;
13. restore the patched upstream source file on exit so the dependency checkout is reusable.

You can reuse already existing dependency trees:

```sh
SRC_DIR=/path/to/asuswrt-merlin.ng \
TOOLCHAIN_DIR=/path/to/am-toolchains \
./scripts/build.sh
```

The source tree supplied through `SRC_DIR` must be clean at the pinned commit. The build script deliberately refuses a mismatching source or toolchain revision.

To override the conservative single-job default on a dedicated build machine:

```sh
MAKE_JOBS=4 ./scripts/build.sh
```

## Why the build uses `M=net/ipv4 modules`

This is an old 2.6.36 Kbuild tree with `CONFIG_MODVERSIONS`. Building only the literal target `net/ipv4/ip_gre.ko` bypasses the module-wide MODPOST path and leaves the `__versions` section empty. Building the `net/ipv4` module set performs MODPOST correctly and produces the symbol CRC table expected by the running firmware.

The unrelated warnings emitted for some other configured `net/ipv4/netfilter` modules are inherited from the historical Merlin source and were also present in the validated build. The target `ip_gre.ko` completes successfully.

## Reproducibility

The unstripped kernel module contains DWARF paths with the absolute source directory. Therefore a clean build in another directory has a different raw SHA-256 and GNU build-id even when the runtime module is identical.

The release step removes only:

- DWARF/debug sections; and
- `.note.gnu.build-id`.

It preserves the module's code, data, relocations, symbol table, `.modinfo` and `__versions` data. A clean protected rebuild was verified to produce the same stripped runtime artifact as the validated original build.

Expected release SHA-256:

```text
ffef775266b8faf21d6dbf60fb3ef95ff28bd2ab6a553af14457c24c9d48fc9e
```

## Expected module metadata

```text
alias:      rtnl-link-gretap
alias:      rtnl-link-gre
license:    GPL
srcversion: 3DB181D5D785DEC4377B55C
vermagic:   2.6.36.4brcmarm SMP preempt mod_unload modversions ARMv7
```

Run:

```sh
./scripts/verify-build.sh
```

to check the release artifact and, if present, the freshly built artifact.

## Why the build-support files are included

`build-support/kernel.config` and `build-support/Module.symvers` preserve the exact kernel configuration and ABI CRC context. `build-support/sdk.config` preserves the generated RT-AC68U SDK configuration because the Broadcom kernel Makefile includes `../../.config`, but that file is not tracked by the upstream git repository.

These build-support files contain no device-unique NVRAM, credentials, keys or MAC addresses.

## Deterministic release archive

`./scripts/package-release.sh` creates a tarball with sorted entries, fixed owner/group and a fixed timestamp derived from the pinned Merlin commit. Re-running the packaging step with unchanged repository content therefore produces the same archive checksum.

## Full firmware builds

This project does not attempt to build or redistribute a complete Asuswrt-Merlin firmware image. It builds only the GRE/GRETAP kernel module needed for this use case.

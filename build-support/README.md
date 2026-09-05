# Build support files

These files preserve the exact RT-AC68U / Asuswrt-Merlin 386.14_2 build context required to reproduce the module ABI:

- `kernel.config` — kernel configuration used for the module build;
- `sdk.config` — generated RT-AC68U SDK-level configuration included by the Broadcom kernel Makefile as `../../.config`;
- `Module.symvers` — symbol-version CRC data required by `CONFIG_MODVERSIONS`.

They were taken from the validated build environment for the pinned Merlin source revision.

These files are not router dumps and contain no NVRAM, credentials, private keys, MAC addresses, calibration data, or other device-unique configuration.

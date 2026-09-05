# Compatibility

## Supported target

This build is validated only for the following target:

| Component | Required value |
|---|---|
| Router | ASUS RT-AC68U |
| Firmware | Asuswrt-Merlin 386.14_2 |
| Merlin source commit | `6a5df61aab6f3fa2dffc518994d42e4f2a27fb2b` |
| Kernel | `2.6.36.4brcmarm` |
| Architecture | ARMv7 |
| Module vermagic | `2.6.36.4brcmarm SMP preempt mod_unload modversions ARMv7` |

## Kernel-layout guard

The PPTP coexistence shim is intentionally firmware-specific. The module verifies the expected addresses of:

| Symbol / object | Expected address |
|---|---:|
| built-in PPTP `net_protocol` object | `0xc03da258` |
| `pptp_rcv` | `0xc01c100c` |
| `pptp_init_module` | `0xc001e0e0` |
| `inet_add_protocol` | `0xc023d5c8` |
| `inet_del_protocol` | `0xc023d580` |

If these guards do not match, the module refuses to take over GRE protocol 47.

## Unsupported assumptions

Do not treat any of the following as implicitly compatible:

- another RT-AC68U firmware release;
- another Asuswrt-Merlin 386.x build;
- stock ASUS firmware;
- another Broadcom ARM router;
- another kernel with matching version text but different symbol CRCs or layout.

After any firmware upgrade, revalidate the running kernel, module ABI, symbol addresses, and PPTP GRE ownership before rebuilding or loading a new module.

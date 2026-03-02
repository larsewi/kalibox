# Reproducible Builds Investigation (Debian)

## Overview

Investigating whether CFEngine Debian builds are reproducible by comparing a
locally built `.deb` package against the official released `.deb` package.

- **Released:** `cfengine-nova_3.27.0-1.ubuntu22_amd64.deb`
- **Local:** `local-cfengine-nova_3.27.0-1.ubuntu22_amd64.deb`

## Approach

1. Extract both `.deb` packages using `dpkg-deb`:
   ```
   dpkg-deb -x cfengine-nova_3.27.0-1.ubuntu22_amd64.deb released/
   dpkg-deb -x local-cfengine-nova_3.27.0-1.ubuntu22_amd64.deb local/
   ```
2. Run `diff -rq` to identify which files differ between the two extractions.
3. For each differing binary, use `radiff2 -AC` to perform function-level
   comparison and identify the nature of the differences.

## Directory Comparison (`diff -rq`)

```
Files local/var/cfengine/bin/cf-agent and released/var/cfengine/bin/cf-agent differ
Files local/var/cfengine/bin/cf-check and released/var/cfengine/bin/cf-check differ
Files local/var/cfengine/bin/cf-execd and released/var/cfengine/bin/cf-execd differ
Files local/var/cfengine/bin/cf-key and released/var/cfengine/bin/cf-key differ
Files local/var/cfengine/bin/cf-monitord and released/var/cfengine/bin/cf-monitord differ
Files local/var/cfengine/bin/cf-net and released/var/cfengine/bin/cf-net differ
Files local/var/cfengine/bin/cf-promises and released/var/cfengine/bin/cf-promises differ
Files local/var/cfengine/bin/cf-runagent and released/var/cfengine/bin/cf-runagent differ
Files local/var/cfengine/bin/cf-secret and released/var/cfengine/bin/cf-secret differ
Files local/var/cfengine/bin/cf-serverd and released/var/cfengine/bin/cf-serverd differ
Files local/var/cfengine/bin/cf-upgrade and released/var/cfengine/bin/cf-upgrade differ
Files local/var/cfengine/bin/cmp and released/var/cfengine/bin/cmp differ
Files local/var/cfengine/bin/diff and released/var/cfengine/bin/diff differ
Files local/var/cfengine/bin/diff3 and released/var/cfengine/bin/diff3 differ
Files local/var/cfengine/bin/lmdump and released/var/cfengine/bin/lmdump differ
Files local/var/cfengine/bin/lmmgr and released/var/cfengine/bin/lmmgr differ
Files local/var/cfengine/bin/mdb_copy and released/var/cfengine/bin/mdb_copy differ
Files local/var/cfengine/bin/mdb_dump and released/var/cfengine/bin/mdb_dump differ
Files local/var/cfengine/bin/mdb_load and released/var/cfengine/bin/mdb_load differ
Files local/var/cfengine/bin/mdb_stat and released/var/cfengine/bin/mdb_stat differ
Files local/var/cfengine/bin/sdiff and released/var/cfengine/bin/sdiff differ
Files local/var/cfengine/lib/cfengine-enterprise.so and released/var/cfengine/lib/cfengine-enterprise.so differ
Files local/var/cfengine/lib/libacl.so.1 and released/var/cfengine/lib/libacl.so.1 differ
Files local/var/cfengine/lib/libacl.so.1.1.2302 and released/var/cfengine/lib/libacl.so.1.1.2302 differ
Files local/var/cfengine/lib/libattr.so.1 and released/var/cfengine/lib/libattr.so.1 differ
Files local/var/cfengine/lib/libattr.so.1.1.2502 and released/var/cfengine/lib/libattr.so.1.1.2502 differ
Files local/var/cfengine/lib/libcrypto.so.3 and released/var/cfengine/lib/libcrypto.so.3 differ
Files local/var/cfengine/lib/libcurl.so.4 and released/var/cfengine/lib/libcurl.so.4 differ
Files local/var/cfengine/lib/libcurl.so.4.8.0 and released/var/cfengine/lib/libcurl.so.4.8.0 differ
Files local/var/cfengine/lib/liblber.so.2 and released/var/cfengine/lib/liblber.so.2 differ
Files local/var/cfengine/lib/liblber.so.2.0.200 and released/var/cfengine/lib/liblber.so.2.0.200 differ
Files local/var/cfengine/lib/libldap.so.2 and released/var/cfengine/lib/libldap.so.2 differ
Files local/var/cfengine/lib/libldap.so.2.0.200 and released/var/cfengine/lib/libldap.so.2.0.200 differ
Files local/var/cfengine/lib/libleech.so.0 and released/var/cfengine/lib/libleech.so.0 differ
Files local/var/cfengine/lib/libleech.so.0.0.0 and released/var/cfengine/lib/libleech.so.0.0.0 differ
Files local/var/cfengine/lib/liblmdb.so and released/var/cfengine/lib/liblmdb.so differ
Files local/var/cfengine/lib/libpcre2-8.so.0 and released/var/cfengine/lib/libpcre2-8.so.0 differ
Files local/var/cfengine/lib/libpcre2-8.so.0.15.0 and released/var/cfengine/lib/libpcre2-8.so.0.15.0 differ
Files local/var/cfengine/lib/libpromises.so.3 and released/var/cfengine/lib/libpromises.so.3 differ
Files local/var/cfengine/lib/libpromises.so.3.0.6 and released/var/cfengine/lib/libpromises.so.3.0.6 differ
Files local/var/cfengine/lib/librsync.so.0 and released/var/cfengine/lib/librsync.so.0 differ
Files local/var/cfengine/lib/librsync.so.0.0.0 and released/var/cfengine/lib/librsync.so.0.0.0 differ
Files local/var/cfengine/lib/libssl.so.3 and released/var/cfengine/lib/libssl.so.3 differ
Files local/var/cfengine/lib/libxml2.so.16 and released/var/cfengine/lib/libxml2.so.16 differ
Files local/var/cfengine/lib/libxml2.so.16.1.1 and released/var/cfengine/lib/libxml2.so.16.1.1 differ
Files local/var/cfengine/lib/libyaml-0.so.2 and released/var/cfengine/lib/libyaml-0.so.2 differ
Files local/var/cfengine/lib/libyaml-0.so.2.0.9 and released/var/cfengine/lib/libyaml-0.so.2.0.9 differ
Files local/var/cfengine/lib/libz.so.1 and released/var/cfengine/lib/libz.so.1 differ
Files local/var/cfengine/lib/libz.so.1.3.1 and released/var/cfengine/lib/libz.so.1.3.1 differ
```

Both packages contain 497 files each with the same file set — no files are
missing from either side. 49 files differ in total, but 12 of those are symlinks
(e.g., `libacl.so.1 -> libacl.so.1.1.2302`) that `diff` follows to the real
file, so there are **37 unique differing binaries**: 21 executables in
`var/cfengine/bin/` and 16 shared libraries in `var/cfengine/lib/`. The
remaining 448 files (config files, policy files, scripts, etc.) are identical.

## Function-Level Analysis: `cf-agent` (`radiff2 -AC`)

```
$ radiff2 -AC local/.../cf-agent released/.../cf-agent > radiff2-deb-cf-agent.txt
$ awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    radiff2-deb-cf-agent.txt | sort | uniq -c | sort -rn
    895 MATCH
```

Full output: [radiff2-deb-cf-agent.txt](radiff2-deb-cf-agent.txt) (895 functions)

### Summary

| Category | Count | Description                               |
|----------|-------|-------------------------------------------|
| MATCH    |   895 | Functions identical between builds (100%) |
| UNMATCH  |     0 | Functions with differences (0%)           |
| NEW      |     0 | Functions only present in one build (0%)  |

Every function matches with a **perfect 1.000000 similarity score**. There are
zero code differences between the two builds.

### ELF Section-Level Comparison

To understand what _does_ differ, each ELF section was extracted with `objcopy
--dump-section` and compared by SHA-256 hash:

**Identical sections (all loadable code and data):**

| Section         | Verdict   |
|-----------------|-----------|
| `.init`         | IDENTICAL |
| `.plt`          | IDENTICAL |
| `.plt.got`      | IDENTICAL |
| `.plt.sec`      | IDENTICAL |
| `.text`         | IDENTICAL |
| `.fini`         | IDENTICAL |
| `.rodata`       | IDENTICAL |
| `.eh_frame_hdr` | IDENTICAL |
| `.eh_frame`     | IDENTICAL |
| `.init_array`   | IDENTICAL |
| `.fini_array`   | IDENTICAL |
| `.data.rel.ro`  | IDENTICAL |
| `.dynamic`      | IDENTICAL |
| `.got`          | IDENTICAL |
| `.data`         | IDENTICAL |

**Identical debug/metadata sections:**

| Section              | Verdict   |
|----------------------|-----------|
| `.note.gnu.property` | IDENTICAL |
| `.note.ABI-tag`      | IDENTICAL |
| `.debug_aranges`     | IDENTICAL |
| `.debug_abbrev`      | IDENTICAL |
| `.debug_str`         | IDENTICAL |
| `.debug_loclists`    | IDENTICAL |
| `.debug_rnglists`    | IDENTICAL |
| `.symtab`            | IDENTICAL |
| `.strtab`            | IDENTICAL |
| `.shstrtab`          | IDENTICAL |

**Differing sections (metadata only):**

| Section              | Local size | Released size | Cause                        |
|----------------------|------------|---------------|------------------------------|
| `.note.gnu.build-id` | 36 B       | 36 B          | Different build ID hashes    |
| `.comment`           | 45 B       | 45 B          | GCC version string differs   |
| `.debug_line_str`    | 3,145 B    | 3,209 B       | Build directory path differs |
| `.debug_info`        | 696,210 B  | 696,210 B     | References `.debug_line_str` |
| `.debug_line`        | 130,385 B  | 130,385 B     | References `.debug_line_str` |

### Root Cause Analysis

The byte-level differences are caused by two build environment variations:

**1. Build directory path** (`.debug_line_str`):

```
Local:    /home/jenkins/build/core/cf-agent
Released: /home/jenkins/workspace/testing-pr/label/PACKAGES_x86_64_linux_ubuntu_22/cfengine-3.27.0/cf-agent
```

The released build path is 64 bytes longer, which accounts for the entire file
size difference (1,599,896 vs 1,599,960 bytes). This path is embedded in DWARF
debug info and referenced by `.debug_info` and `.debug_line`.

**2. GCC patch version** (`.comment`):

```
Local:    GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0
Released: GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.2) 11.4.0
```

Same GCC 11.4.0 compiler, but a different Ubuntu patch release. Despite this,
the generated machine code is byte-for-byte identical.

**3. Build ID** (`.note.gnu.build-id`):

```
Local:    e712adb50248d7d038a13c8ee5a3d713cfdfcab5
Released: 7e6bde4dfd2577a258495d6373497261cf0a2b42
```

The build ID is a hash computed over the binary content, so it differs as a
consequence of the other differences.

## Function-Level Analysis: `cf-check` (`radiff2 -AC`)

```
$ radiff2 -AC local/.../cf-check released/.../cf-check > radiff2-deb-cf-check.txt
$ awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    radiff2-deb-cf-check.txt | sort | uniq -c | sort -rn
    684 MATCH
```

Full output: [radiff2-deb-cf-check.txt](radiff2-deb-cf-check.txt) (684 functions)

### Summary

| Category | Count | Description                               |
|----------|-------|-------------------------------------------|
| MATCH    |   684 | Functions identical between builds (100%) |
| UNMATCH  |     0 | Functions with differences (0%)           |
| NEW      |     0 | Functions only present in one build (0%)  |

All 684 functions match at 1.000000 similarity. Same pattern as `cf-agent` —
all loadable sections (`.text`, `.rodata`, `.data`, etc.) are byte-for-byte
identical. Only the same 5 metadata/debug sections differ:

| Section              | Local size | Released size | Cause                        |
|----------------------|------------|---------------|------------------------------|
| `.note.gnu.build-id` | 36 B       | 36 B          | Different build ID hashes    |
| `.comment`           | 45 B       | 45 B          | GCC version string differs   |
| `.debug_line_str`    | 1,548 B    | 1,740 B       | Build directory path differs |
| `.debug_info`        | 235,661 B  | 235,661 B     | References `.debug_line_str` |
| `.debug_line`        | 71,153 B   | 71,153 B      | References `.debug_line_str` |

## Bulk Analysis: All Remaining Binaries

The same `radiff2 -AC` and `objcopy --dump-section` analysis was run on all 35
remaining differing binaries (19 executables + 16 shared libraries). Results
fall into three categories:

### Category 1: Perfectly Reproducible Code (33 of 37 binaries)

All loadable sections byte-for-byte identical. All functions match at 1.000000.
Only metadata/debug sections differ (build ID, GCC version, build path).

| Binary                   | Functions | MATCH | UNMATCH | NEW |
|--------------------------|-----------|-------|---------|-----|
| `cf-agent`               |       895 |   895 |       0 |   0 |
| `cf-check`               |       684 |   684 |       0 |   0 |
| `cf-execd`               |       219 |   219 |       0 |   0 |
| `cf-key`                 |        99 |    99 |       0 |   0 |
| `cf-monitord`            |       268 |   268 |       0 |   0 |
| `cf-net`                 |        58 |    58 |       0 |   0 |
| `cf-promises`            |        62 |    62 |       0 |   0 |
| `cf-runagent`            |        88 |    88 |       0 |   0 |
| `cf-secret`              |        75 |    75 |       0 |   0 |
| `cf-serverd`             |       419 |   419 |       0 |   0 |
| `cf-upgrade`             |        82 |    82 |       0 |   0 |
| `cfengine-enterprise.so` |       747 |   747 |       0 |   0 |
| `cmp`                    |        67 |    67 |       0 |   0 |
| `diff`                   |       114 |   114 |       0 |   0 |
| `diff3`                  |        71 |    71 |       0 |   0 |
| `lmdump`                 |        22 |    22 |       0 |   0 |
| `lmmgr`                  |        29 |    29 |       0 |   0 |
| `mdb_copy`               |        17 |    17 |       0 |   0 |
| `mdb_dump`               |        38 |    38 |       0 |   0 |
| `mdb_load`               |        46 |    46 |       0 |   0 |
| `mdb_stat`               |        33 |    33 |       0 |   0 |
| `sdiff`                  |        83 |    83 |       0 |   0 |
| `libacl.so.1.1.2302`     |        93 |    93 |       0 |   0 |
| `libattr.so.1.1.2502`    |        62 |    62 |       0 |   0 |
| `libcurl.so.4.8.0`       |       445 |   445 |       0 |   0 |
| `liblber.so.2.0.200`     |       198 |   198 |       0 |   0 |
| `libldap.so.2.0.200`     |       938 |   938 |       0 |   0 |
| `libleech.so.0.0.0`      |       341 |   341 |       0 |   0 |
| `liblmdb.so`             |       142 |   142 |       0 |   0 |
| `libpcre2-8.so.0.15.0`   |       102 |   102 |       0 |   0 |
| `librsync.so.0.0.0`      |       151 |   151 |       0 |   0 |
| `libssl.so.3`            |     1,081 | 1,081 |       0 |   0 |
| `libxml2.so.16.1.1`      |     1,889 | 1,889 |       0 |   0 |
| `libyaml-0.so.2.0.9`     |        81 |    81 |       0 |   0 |
| `libz.so.1.3.1`          |       134 |   134 |       0 |   0 |

For CFEngine-built binaries (`cf-*`, `cfengine-enterprise.so`), the differing
debug sections are `.comment`, `.note.gnu.build-id`, `.debug_line_str`,
`.debug_info`, and `.debug_line` — the same 5 sections identified in the
`cf-agent` analysis. For third-party libraries (`cmp`, `diff*`, `sdiff`,
`lib*.so`), only `.note.gnu.build-id` differs.

### Category 2: Embedded Timestamp Only — `libcrypto.so.3`

| Binary          | Functions | MATCH | UNMATCH | NEW |
|-----------------|-----------|-------|---------|-----|
| `libcrypto.so.3`|     5,317 | 5,317 |       0 |   0 |

All 5,317 functions match at 1.000000 similarity. The only loadable section
that differs is `.rodata` (same size: 523,419 bytes), with **only 12 bytes**
different — an embedded OpenSSL build timestamp:

```
Local:    built on: Mon Mar  2 09:41:51 2026 UTC
Released: built on: Thu Jan  8 23:14:16 2026 UTC
```

### Category 3: Actual Code Differences — `libpromises.so.3.0.6`

| Binary                 | Functions | MATCH | UNMATCH | NEW |
|------------------------|-----------|-------|---------|-----|
| `libpromises.so.3.0.6` |     3,533 | 2,648 |     885 |   0 |

This is the only binary with actual code differences. The `.text` section
differs in size (local: 646,914 bytes, released: 646,482 bytes — a 432-byte
difference).

**Differing loadable sections:**

| Section        | Local size | Released size |
|----------------|------------|---------------|
| `.text`        | 646,914 B  | 646,482 B     |
| `.rodata`      | 260,480 B  | 260,544 B     |
| `.eh_frame_hdr`| 19,460 B   | 19,460 B      |
| `.eh_frame`    | 122,960 B  | 122,960 B     |
| `.data.rel.ro` | 68,208 B   | 68,208 B      |
| `.dynamic`     | 624 B      | 624 B         |
| `.data`        | 876 B      | 876 B         |

**Only 3 functions have genuinely different code (different sizes):**

| Function                   | Local size | Released size | Similarity |
|----------------------------|------------|---------------|------------|
| `yyparse`                  | 13,195 B   | 12,788 B      | 0.309      |
| `VariableResolve.part.0`   | 105,350 B  | 104,918 B     | 0.900      |
| `yy_get_previous_state`    | 295 B      | 296 B         | 0.678      |

`yyparse` and `yy_get_previous_state` are generated by Bison (the parser
generator). The local build embeds 89 YYSYMBOL debug strings while the released
build embeds none, indicating different Bison versions or build flags were used.
`VariableResolve.part.0` is a large GCC-generated partial-inlining fragment
whose code generation is sensitive to compiler patch level (`22.04.3` vs
`22.04.2`).

**The remaining 882 UNMATCH functions have identical logic.** Their byte-level
differences are solely caused by RIP-relative address offsets shifting due to
the 3 functions above being different sizes. For example, `StringIsBoolean`
(124 bytes in both builds) has identical instructions — only the `lea` offsets
to `.rodata` strings differ because the `.rodata` layout shifted:

```
Local:    60fd5: 48 8d 35 ec ff 08 00  lea  0x8ffec(%rip),%rsi  # f0fc8
Released: 60e25: 48 8d 35 9c 01 09 00  lea  0x9019c(%rip),%rsi  # f0fc8 (same target)
```

## Conclusion

The Debian builds are **very close to fully reproducible**. Of the 497 files in
each package, 448 are byte-for-byte identical. The 37 unique differing binaries
(49 including symlinks) break down as follows:

| Category                          | Binaries | Root cause                          |
|-----------------------------------|----------|-------------------------------------|
| Code identical, debug metadata only | 33     | Build path, build ID, GCC version   |
| Code identical, embedded timestamp  | 1      | OpenSSL `built on:` string          |
| Actual code differences             | 1      | Bison version + GCC patch level     |

**35 of 37 binaries** produce identical machine code. The byte-level
differences in these are confined to non-executable ELF sections (`.comment`,
`.note.gnu.build-id`, `.debug_line_str`, `.debug_info`, `.debug_line`) that do
not affect runtime behavior. These would be eliminated by stripping debug info
or by standardizing the build path and toolchain version.

**`libcrypto.so.3`** is functionally identical — all 5,317 functions match —
with only a 12-byte OpenSSL build timestamp in `.rodata` differing. This is a
known reproducibility issue in OpenSSL, fixable with `SOURCE_DATE_EPOCH`.

**`libpromises.so.3.0.6`** is the only binary with genuine code differences,
and even there the scope is narrow: 3 out of 3,533 functions differ in size,
all caused by toolchain variation (Bison parser generator version and GCC
`11.4.0-1ubuntu1~22.04.3` vs `22.04.2`). The remaining 882 UNMATCH functions
have identical logic — their byte differences are purely address-offset shifts
cascading from the 3 changed functions.

### Comparison with Windows Builds

| Metric                          | Windows (MSI)         | Debian (`.deb`)            |
|---------------------------------|-----------------------|----------------------------|
| Total differing files           | 35/35 (100%)          | 37/497 (7%)                |
| Binaries with identical code    | 0/35 (0%)             | 35/37 (95%)                |
| Typical function match rate     | ~63% MATCH            | 100% MATCH                 |
| Root cause of differences       | Linker address layout | Debug metadata + 1 library |

The Debian builds are substantially more reproducible than the Windows builds.
To achieve full bit-for-bit reproducibility, three things would need to be
addressed:

1. **Standardize the build path** — use a fixed directory (e.g.,
   `/build/cfengine`) to eliminate `.debug_line_str` differences.
2. **Pin toolchain versions** — ensure identical GCC patch level and Bison
   version across build environments.
3. **Set `SOURCE_DATE_EPOCH`** — clamp OpenSSL's embedded build timestamp.

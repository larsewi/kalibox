# Reproducible Builds Investigation

## Overview

Investigating whether CFEngine Windows builds are reproducible by comparing a
locally built MSI package against the official released MSI package.

## Approach

1. Extract both MSI packages using `msiextract`:
   ```
   msiextract local.msi -C local/
   msiextract released.msi -C released/
   ```
2. Run `diff -rq` to identify which files differ between the two extractions.
3. For each differing binary, use `radiff2 -AC` to perform function-level
   comparison and identify the nature of the differences.

## Directory Comparison (`diff -rq`)

```
Files local/ProgramFiles64Folder/Cfengine/bin/cf-agent.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-agent.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-check.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-check.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-execd.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-execd.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-key.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-key.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-monitord.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-monitord.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-net.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-net.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-promises.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-promises.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-runagent.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-runagent.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-secret.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-secret.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-serverd.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-serverd.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cf-upgrade.exe and released/ProgramFiles64Folder/Cfengine/bin/cf-upgrade.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/cmp.exe and released/ProgramFiles64Folder/Cfengine/bin/cmp.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/diff.exe and released/ProgramFiles64Folder/Cfengine/bin/diff.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/diff3.exe and released/ProgramFiles64Folder/Cfengine/bin/diff3.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/libcrypto-3-x64.dll and released/ProgramFiles64Folder/Cfengine/bin/libcrypto-3-x64.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/libcurl-4.dll and released/ProgramFiles64Folder/Cfengine/bin/libcurl-4.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/libgnurx-0.dll and released/ProgramFiles64Folder/Cfengine/bin/libgnurx-0.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/liblber.dll and released/ProgramFiles64Folder/Cfengine/bin/liblber.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/libldap.dll and released/ProgramFiles64Folder/Cfengine/bin/libldap.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/libleech-0.dll and released/ProgramFiles64Folder/Cfengine/bin/libleech-0.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/liblmdb.dll and released/ProgramFiles64Folder/Cfengine/bin/liblmdb.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/libpcre2-8-0.dll and released/ProgramFiles64Folder/Cfengine/bin/libpcre2-8-0.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/librsync-0.dll and released/ProgramFiles64Folder/Cfengine/bin/librsync-0.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/libssl-3-x64.dll and released/ProgramFiles64Folder/Cfengine/bin/libssl-3-x64.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/libxml2-16.dll and released/ProgramFiles64Folder/Cfengine/bin/libxml2-16.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/libyaml-0-2.dll and released/ProgramFiles64Folder/Cfengine/bin/libyaml-0-2.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/lmdump.exe and released/ProgramFiles64Folder/Cfengine/bin/lmdump.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/lmmgr.exe and released/ProgramFiles64Folder/Cfengine/bin/lmmgr.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/mdb_copy.exe and released/ProgramFiles64Folder/Cfengine/bin/mdb_copy.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/mdb_dump.exe and released/ProgramFiles64Folder/Cfengine/bin/mdb_dump.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/mdb_load.exe and released/ProgramFiles64Folder/Cfengine/bin/mdb_load.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/mdb_stat.exe and released/ProgramFiles64Folder/Cfengine/bin/mdb_stat.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/pthreadGC2.dll and released/ProgramFiles64Folder/Cfengine/bin/pthreadGC2.dll differ
Files local/ProgramFiles64Folder/Cfengine/bin/sdiff.exe and released/ProgramFiles64Folder/Cfengine/bin/sdiff.exe differ
Files local/ProgramFiles64Folder/Cfengine/bin/zlib1.dll and released/ProgramFiles64Folder/Cfengine/bin/zlib1.dll differ
```

All 35 binaries differ. The only non-binary file (`ssl/openssl.cnf`) is identical.
No files are missing from either side — both packages contain the same file set.

## Function-Level Analysis: `cf-agent.exe` (`radiff2 -AC`)

```
$ radiff2 -AC local/.../cf-agent.exe released/.../cf-agent.exe > radiff2-cf-agent.txt
$ awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    radiff2-cf-agent.txt | sort | uniq -c | sort -rn
   2018 MATCH
   1161 UNMATCH
```

Full output: [radiff2-cf-agent.txt](radiff2-cf-agent.txt) (3179 lines)

### Summary

| Category | Count | Description                                              |
|----------|-------|----------------------------------------------------------|
| MATCH    |  2018 | Functions identical or very similar between builds (63%) |
| UNMATCH  |  1161 | Functions present in both but with differences (37%)     |
| NEW      |     0 | Functions only present in one build (0%)                 |

Every function was successfully correlated between the two builds — no functions
are missing from either side. 63% of functions match, and the remaining 37% show
differences. Notably, even the UNMATCH functions have very high similarity
scores (typically 0.93+), suggesting the differences are minor.

### Root Cause Analysis

Disassembly comparison of UNMATCH functions (e.g., `FreeFixedStringArray`) shows
that the actual instructions and logic are **identical**. The only byte-level
differences are **relative call/jump offsets** — because library functions
(e.g., `free`) are located at slightly different addresses between the two
builds (~0x130 byte shift).

Disassembled with `objdump`:

```
$ objdump -d local/.../cf-agent.exe | awk '/<FreeFixedStringArray>:/,/^$/'
$ objdump -d released/.../cf-agent.exe | awk '/<FreeFixedStringArray>:/,/^$/'
```

**Local build:**

```asm
0000000000401540 <FreeFixedStringArray>:
  401540:  57                    push   %rdi
  401541:  56                    push   %rsi
  401542:  53                    push   %rbx
  401543:  48 83 ec 20           sub    $0x20,%rsp
  401547:  85 c9                 test   %ecx,%ecx
  401549:  48 89 d7              mov    %rdx,%rdi
  40154c:  7e 23                 jle    401571 <FreeFixedStringArray+0x31>
  40154e:  8d 41 ff              lea    -0x1(%rcx),%eax
  401551:  48 89 d3              mov    %rdx,%rbx
  401554:  48 8d 74 c2 08        lea    0x8(%rdx,%rax,8),%rsi
  401559:  0f 1f 80 00 00 00 00  nopl   0x0(%rax)
  401560:  48 8b 0b              mov    (%rbx),%rcx
  401563:  48 83 c3 08           add    $0x8,%rbx
  401567:  e8 3c d3 0c 00        call   4ce8a8 <free>       ; <-- offset differs
  40156c:  48 39 f3              cmp    %rsi,%rbx
  40156f:  75 ef                 jne    401560 <FreeFixedStringArray+0x20>
  401571:  48 89 f9              mov    %rdi,%rcx
  401574:  48 83 c4 20           add    $0x20,%rsp
  401578:  5b                    pop    %rbx
  401579:  5e                    pop    %rsi
  40157a:  5f                    pop    %rdi
  40157b:  e9 28 d3 0c 00        jmp    4ce8a8 <free>       ; <-- offset differs
```

**Released build:**

```asm
0000000000401540 <FreeFixedStringArray>:
  401540:  57                    push   %rdi
  401541:  56                    push   %rsi
  401542:  53                    push   %rbx
  401543:  48 83 ec 20           sub    $0x20,%rsp
  401547:  85 c9                 test   %ecx,%ecx
  401549:  48 89 d7              mov    %rdx,%rdi
  40154c:  7e 23                 jle    401571 <FreeFixedStringArray+0x31>
  40154e:  8d 41 ff              lea    -0x1(%rcx),%eax
  401551:  48 89 d3              mov    %rdx,%rbx
  401554:  48 8d 74 c2 08        lea    0x8(%rdx,%rax,8),%rsi
  401559:  0f 1f 80 00 00 00 00  nopl   0x0(%rax)
  401560:  48 8b 0b              mov    (%rbx),%rcx
  401563:  48 83 c3 08           add    $0x8,%rbx
  401567:  e8 0c d2 0c 00        call   4ce778 <free>       ; <-- offset differs
  40156c:  48 39 f3              cmp    %rsi,%rbx
  40156f:  75 ef                 jne    401560 <FreeFixedStringArray+0x20>
  401571:  48 89 f9              mov    %rdi,%rcx
  401574:  48 83 c4 20           add    $0x20,%rsp
  401578:  5b                    pop    %rbx
  401579:  5e                    pop    %rsi
  40157a:  5f                    pop    %rdi
  40157b:  e9 f8 d1 0c 00        jmp    4ce778 <free>       ; <-- offset differs
```

The instructions are identical — only the `call`/`jmp` relative offsets to
`free` differ (`0x4ce8a8` vs `0x4ce778`) because the function lands at a
slightly different address in each binary.

### PE Header Differences

Extracted using radare2:

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-agent.exe | grep -iE 'timestamp|checksum|size'
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-agent.exe | grep -iE 'timestamp|checksum|size'
```

| Field           | Local                     | Released                  |
|-----------------|---------------------------|---------------------------|
| TimeDateStamp   | `0x69a1701f` (2026-02-27) | `0x696153ec` (2026-01-09) |
| SizeOfCode      | 849408 bytes              | 848896 bytes              |
| SizeOfImage     | `0x674000`                | `0x677000`                |
| CheckSum        | `0x6c5bd1`                | `0x6d22ce`                |

The identified sources of non-reproducibility are:

1. **PE TimeDateStamp** — embedded build timestamp differs (different build
   dates). This is a classic reproducibility issue; the linker embeds the
   current time into the PE header.
2. **Code size delta** — 512 bytes difference in `SizeOfCode`, which causes
   library functions to land at different addresses, which in turn changes every
   relative `call`/`jmp` offset throughout the binary.
3. **Checksum** — derived from the binary contents, so it differs as a
   consequence of the above.

### Deep Dive: 512-Byte Code Size Difference

PE section sizes were compared using radare2:

```
$ r2 -q -e bin.cache=true -c 'iS' local/.../cf-agent.exe
$ r2 -q -e bin.cache=true -c 'iS' released/.../cf-agent.exe
```

The `.text` section is 512 bytes larger in the local build (`0xcf600` vs
`0xcf400`). To find functions with actual code differences, both binaries were
disassembled, normalized (all addresses replaced), and compared per-function:

```
$ objdump -d $BINARY \
    | awk '/<.*>:/{name=$0; ...} /^[[:space:]]*[0-9a-f]+:/{print name"\t"$3}' \
    | sed 's/0x[0-9a-f]\+/ADDR/g; s/[0-9a-f]\{5,\}/ADDR/g' \
    > normalized.txt
```

This reveals that **only 8 functions have actual instruction differences**, and
they are all **flex/yacc generated parser functions**:

| Function                | Local (instr) | Released (instr) | Delta |
|-------------------------|---------------|------------------|-------|
| `yylex`                 |          1240 |             1191 |   +49 |
| `yy_create_buffer`      |            34 |               32 |    +2 |
| `yy_get_previous_state` |            77 |               76 |    +1 |
| `yy_scan_string`        |            10 |               10 |     0 |
| `yyget_leng`            |             4 |                4 |     0 |
| `yyensure_buffer_stack` |            57 |               58 |    -1 |
| `yy_scan_buffer`        |            46 |               47 |    -1 |
| `yy_scan_bytes`         |            42 |               43 |    -1 |

A full per-function comparison of all 3460 shared functions confirms this.
See [compare-functions.sh](compare-functions.sh) for the script used.

```
$ ./compare-functions.sh local/.../cf-agent.exe released/.../cf-agent.exe

=== Results ===
Total shared functions: 3460
Identical:              3452
Different:              8

Functions with differences:
  yy_create_buffer
  yyensure_buffer_stack
  yyget_leng
  yy_get_previous_state
  yylex
  yy_scan_buffer
  yy_scan_bytes
  yy_scan_string
```

**3452 out of 3460 functions are instruction-identical.** No functions are unique
to either build. The 8 functions that differ are all in the `yy_*` family above.

The differences in the `yy_*` functions are:

- **Register allocation choices** (e.g., `%r9` vs `%rdx` for the same operand)
- **Instruction selection** (e.g., `lea` vs `add`+`movslq` for the same
  computation)
- **NOP padding sizes** between basic blocks

These are characteristic of either:
- Different **flex/bison versions** generating slightly different C source
- Different **compiler versions** making different register allocation decisions
  on the same generated code

#### Assembly Diffs for All 8 Flex Functions

Extracted using normalized disassembly (all addresses replaced with `ADDR`)
and diffed per-function using [compare-functions.sh](compare-functions.sh):

```
$ ./compare-functions.sh local/.../cf-agent.exe released/.../cf-agent.exe
```

- **[`yyget_leng`](diffs/yyget_leng.txt)** (4 instructions — smallest function):
  Uses `%rax` (64-bit) vs `%eax` (32-bit) for the same value, and different NOP
  padding.

- **[`yy_create_buffer`](diffs/yy_create_buffer.txt)** (34 vs 32 instructions):
  Different instruction ordering for the sign-extension / size computation, and
  different NOP padding at function end (3 NOPs vs 2).

- **[`yy_get_previous_state`](diffs/yy_get_previous_state.txt)** (77 vs 76 instructions):
  Local build has a redundant `mov %edx,%edx` (zero-extension that the released
  build avoids by reusing `%rdx` directly). Different NOP padding at end.

- **[`yy_scan_string`](diffs/yy_scan_string.txt)** (10 instructions each):
  64-bit vs 32-bit register for the `strlen` return value, different NOP form.

- **[`yyensure_buffer_stack`](diffs/yyensure_buffer_stack.txt)** (57 vs 58 instructions):
  Local uses a single `lea` for add-and-extend; released uses `add` + `movslq`
  (2 instructions for the same computation).

- **[`yy_scan_buffer`](diffs/yy_scan_buffer.txt)** (46 vs 47 instructions):
  Different register choices (`%rsi`/`%rdi` swapped), different computation
  order for struct field assignments, different NOP padding.

- **[`yy_scan_bytes`](diffs/yy_scan_bytes.txt)** (42 vs 43 instructions):
  Different sign-extension strategy, 64-bit vs 32-bit loop comparison
  (`cmp %r8,%rbx` / `jne` vs `cmp %r8d,%ebx` / `jg`), different NOP form.

- **[`yylex`](diffs/yylex.txt)** (1240 vs 1191 instructions — largest function):
  The `yylex` diff is very large (~500 changed lines) but exhibits the same
  patterns as the smaller functions. The builds use completely different
  register assignments for the same variables (e.g., `yy_hold_char` in `%r12` vs
  `%ebp`, `yy_c_buf_p` in `%rdi` vs `%r10`, `yy_accept` in `%r11` vs `%r13`).
  There are also recurring `mov` vs `movslq` differences (the released build
  uses explicit sign-extension where the local build uses plain moves) and
  different NOP padding throughout.

### Compiler Version Check

GCC embeds its version string into compiled binaries. Extracting with `strings`:

```
$ strings local/.../cf-agent.exe | grep '^GCC:' | sort -u
GCC: (GNU) 5.3.1 20151207
GCC: (GNU) 5.3.1 20160211

$ strings released/.../cf-agent.exe | grep '^GCC:' | sort -u
GCC: (GNU) 5.3.1 20151207
GCC: (GNU) 5.3.1 20160211
```

Both builds contain identical GCC versions. The two snapshots (`20151207` and
`20160211`) are from different object files in the mingw toolchain.

Since the compiler is the same, the `yy_*` function differences are most likely
caused by **different flex versions** generating slightly different C source
code, which the same GCC then compiles into different machine code. Flex does
not embed its version into the generated binary, so this would need to be
confirmed by checking `flex --version` in both build environments.

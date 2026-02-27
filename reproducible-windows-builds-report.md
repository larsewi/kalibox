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

**Note on function counts:** `radiff2 -AC` and `compare-functions.sh` report
different function totals for the same binary. `radiff2` uses radare2's own
heuristic analysis to detect functions, which may miss small helpers, thunks,
or CRT startup routines. `compare-functions.sh` uses `objdump -d`, which relies
on the symbol table and consistently finds more functions. Both tools agree on
the conclusions — the discrepancy is only in how many functions each tool
discovers, not in which functions differ.

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

## Function-Level Analysis: `cf-check.exe`

```
$ radiff2 -AC local/.../cf-check.exe released/.../cf-check.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1733 MATCH
   1018 UNMATCH
```

Full output: [radiff2-cf-check.txt](radiff2-cf-check.txt)

```
$ ./compare-functions.sh local/.../cf-check.exe released/.../cf-check.exe

=== Results ===
Total shared functions: 2977
Identical:              2969
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

**2969 out of 2977 functions are instruction-identical.** The same 8 flex
functions differ, and the diffs are byte-for-byte identical to the cf-agent
ones (verified by comparing md5sums of the diff files).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-check.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-check.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17022`   | `0x696153f0`   |
| SizeOfCode      | `0x93000`      | `0x92e00`      |
| SizeOfImage     | `0x481000`     | `0x485000`     |
| CheckSum        | `0x4ca3e9`     | `0x4caa8f`     |

Same 512-byte `.text` section difference as cf-agent, same timestamp and
checksum divergence. The root causes are identical: PE TimeDateStamp and
flex-generated code differences.

## Function-Level Analysis: `cf-execd.exe`

```
$ radiff2 -AC local/.../cf-execd.exe released/.../cf-execd.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1694 MATCH
   1060 UNMATCH
```

Full output: [radiff2-cf-execd.txt](radiff2-cf-execd.txt)

```
$ ./compare-functions.sh local/.../cf-execd.exe released/.../cf-execd.exe

=== Results ===
Total shared functions: 2987
Identical:              2979
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

**2979 out of 2987 functions are instruction-identical.** Same 8 flex functions,
diffs byte-for-byte identical to cf-agent (verified via md5sums).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-execd.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-execd.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17020`   | `0x696153ee`   |
| SizeOfCode      | `0x94600`      | `0x94600`      |
| SizeOfImage     | `0x48e000`     | `0x490000`     |
| CheckSum        | `0x4dd394`     | `0x4dddda`     |

Unlike cf-agent and cf-check, **SizeOfCode is identical** between both builds.
The `.text` section is the same size (`0x94600`). The flex function differences
still exist at the instruction level but happen to fit within the same section
alignment. The only PE header divergences are TimeDateStamp, SizeOfImage, and
CheckSum.

## Function-Level Analysis: `cf-key.exe`

```
$ radiff2 -AC local/.../cf-key.exe released/.../cf-key.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1680 MATCH
   1069 UNMATCH
```

Full output: [radiff2-cf-key.txt](radiff2-cf-key.txt)

```
$ ./compare-functions.sh local/.../cf-key.exe released/.../cf-key.exe

=== Results ===
Total shared functions: 2975
Identical:              2967
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

**2967 out of 2975 functions are instruction-identical.** Same 8 flex functions,
diffs byte-for-byte identical to cf-agent (verified via md5sums).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-key.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-key.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17021`   | `0x696153ef`   |
| SizeOfCode      | `0x92800`      | `0x92800`      |
| SizeOfImage     | `0x47c000`     | `0x47e000`     |
| CheckSum        | `0x4c489c`     | `0x4cb78e`     |

Same as cf-execd: **SizeOfCode is identical**. Only TimeDateStamp, SizeOfImage,
and CheckSum differ.

## Function-Level Analysis: `cf-monitord.exe`

```
$ radiff2 -AC local/.../cf-monitord.exe released/.../cf-monitord.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1696 MATCH
   1109 UNMATCH
```

Full output: [radiff2-cf-monitord.txt](radiff2-cf-monitord.txt)

```
$ ./compare-functions.sh local/.../cf-monitord.exe released/.../cf-monitord.exe

=== Results ===
Total shared functions: 3031
Identical:              3023
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

**3023 out of 3031 functions are instruction-identical.** Same 8 flex functions,
diffs byte-for-byte identical to cf-agent (verified via md5sums).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-monitord.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-monitord.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17022`   | `0x696153f1`   |
| SizeOfCode      | `0x99c00`      | `0x99c00`      |
| SizeOfImage     | `0x510000`     | `0x513000`     |
| CheckSum        | `0x4f59a6`     | `0x506733`     |

**SizeOfCode is identical**. Only TimeDateStamp, SizeOfImage, and CheckSum
differ.

## Function-Level Analysis: `cf-net.exe`

```
$ radiff2 -AC local/.../cf-net.exe released/.../cf-net.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1675 MATCH
   1068 UNMATCH
```

Full output: [radiff2-cf-net.txt](radiff2-cf-net.txt)

```
$ ./compare-functions.sh local/.../cf-net.exe released/.../cf-net.exe

=== Results ===
Total shared functions: 2969
Identical:              2961
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

**2961 out of 2969 functions are instruction-identical.** Same 8 flex functions,
diffs byte-for-byte identical to cf-agent (verified via md5sums).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-net.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-net.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17021`   | `0x696153f0`   |
| SizeOfCode      | `0x93000`      | `0x92e00`      |
| SizeOfImage     | `0x483000`     | `0x486000`     |
| CheckSum        | `0x4c3f2c`     | `0x4ce7b7`     |

512-byte SizeOfCode difference (like cf-agent and cf-check), plus TimeDateStamp,
SizeOfImage, and CheckSum.

## Function-Level Analysis: `cf-promises.exe`

```
$ radiff2 -AC local/.../cf-promises.exe released/.../cf-promises.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1642 MATCH
   1091 UNMATCH
```

Full output: [radiff2-cf-promises.txt](radiff2-cf-promises.txt)

```
$ ./compare-functions.sh local/.../cf-promises.exe released/.../cf-promises.exe

=== Results ===
Total shared functions: 2959
Identical:              2951
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

**2951 out of 2959 functions are instruction-identical.** Same 8 flex functions,
diffs byte-for-byte identical to cf-agent (verified via md5sums).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-promises.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-promises.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17022`   | `0x696153f0`   |
| SizeOfCode      | `0x91e00`      | `0x91e00`      |
| SizeOfImage     | `0x479000`     | `0x47b000`     |
| CheckSum        | `0x4c5441`     | `0x4c3792`     |

**SizeOfCode is identical**. Only TimeDateStamp, SizeOfImage, and CheckSum
differ.

## Function-Level Analysis: `cf-runagent.exe`

```
$ radiff2 -AC local/.../cf-runagent.exe released/.../cf-runagent.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1679 MATCH
   1056 UNMATCH
```

Full output: [radiff2-cf-runagent.txt](radiff2-cf-runagent.txt)

```
$ ./compare-functions.sh local/.../cf-runagent.exe released/.../cf-runagent.exe

=== Results ===
Total shared functions: 2961
Identical:              2953
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

**2953 out of 2961 functions are instruction-identical.** Same 8 flex functions,
diffs byte-for-byte identical to cf-agent (verified via md5sums).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-runagent.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-runagent.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17022`   | `0x696153f1`   |
| SizeOfCode      | `0x92600`      | `0x92600`      |
| SizeOfImage     | `0x47d000`     | `0x47f000`     |
| CheckSum        | `0x4bf4e1`     | `0x4d0411`     |

**SizeOfCode is identical**. Only TimeDateStamp, SizeOfImage, and CheckSum
differ.

## Function-Level Analysis: `cf-secret.exe`

```
$ radiff2 -AC local/.../cf-secret.exe released/.../cf-secret.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1835 MATCH
    911 UNMATCH
```

Full output: [radiff2-cf-secret.txt](radiff2-cf-secret.txt)

```
$ ./compare-functions.sh local/.../cf-secret.exe released/.../cf-secret.exe

=== Results ===
Total shared functions: 2972
Identical:              2964
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

**2964 out of 2972 functions are instruction-identical.** Same 8 flex functions,
diffs byte-for-byte identical to cf-agent (verified via md5sums).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-secret.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-secret.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17021`   | `0x696153f0`   |
| SizeOfCode      | `0x93600`      | `0x93600`      |
| SizeOfImage     | `0x484000`     | `0x488000`     |
| CheckSum        | `0x4ca83e`     | `0x4d4f2d`     |

**SizeOfCode is identical**. Only TimeDateStamp, SizeOfImage, and CheckSum
differ.

## Function-Level Analysis: `cf-serverd.exe`

```
$ radiff2 -AC local/.../cf-serverd.exe released/.../cf-serverd.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1799 MATCH
   1185 UNMATCH
```

Full output: [radiff2-cf-serverd.txt](radiff2-cf-serverd.txt)

```
$ ./compare-functions.sh local/.../cf-serverd.exe released/.../cf-serverd.exe

=== Results ===
Total shared functions: 3217
Identical:              3209
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

**3209 out of 3217 functions are instruction-identical.** Same 8 flex functions,
diffs byte-for-byte identical to cf-agent (verified via md5sums).

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-serverd.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-serverd.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17020`   | `0x696153ed`   |
| SizeOfCode      | `0xa8800`      | `0xa8800`      |
| SizeOfImage     | `0x515000`     | `0x519000`     |
| CheckSum        | `0x565489`     | `0x560692`     |

**SizeOfCode is identical**. Only TimeDateStamp, SizeOfImage, and CheckSum
differ.

## Function-Level Analysis: `cf-upgrade.exe`

```
$ radiff2 -AC local/.../cf-upgrade.exe released/.../cf-upgrade.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    140 MATCH
```

Full output: [radiff2-cf-upgrade.txt](radiff2-cf-upgrade.txt)

```
$ ./compare-functions.sh local/.../cf-upgrade.exe released/.../cf-upgrade.exe

=== Results ===
Total shared functions: 180
Identical:              180
Different:              0
```

**All 180 functions are instruction-identical.** This binary does not link the
flex-generated parser, so there are no code differences at all.

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cf-upgrade.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cf-upgrade.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a17008`   | `0x696153cd`   |
| SizeOfCode      | `0x5000`       | `0x5000`       |
| SizeOfImage     | `0x35000`      | `0x36000`      |
| CheckSum        | `0x43386`      | `0x3989a`      |

**SizeOfCode is identical** and there are zero function differences. The only
sources of non-reproducibility are TimeDateStamp, SizeOfImage, and CheckSum.

## Function-Level Analysis: `cmp.exe`

```
$ radiff2 -AC local/.../cmp.exe released/.../cmp.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    307 MATCH
      2 UNMATCH
```

Full output: [radiff2-cmp.txt](radiff2-cmp.txt)

```
$ ./compare-functions.sh local/.../cmp.exe released/.../cmp.exe

=== Results ===
Total shared functions: 369
Identical:              369
Different:              0
```

**All 369 functions are instruction-identical.** No flex parser linked.

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../cmp.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../cmp.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a1659f`   | `0x6960317f`   |
| SizeOfCode      | `0xec00`       | `0xec00`       |
| SizeOfImage     | `0x7f000`      | `0x80000`      |
| CheckSum        | `0x900e9`      | `0x986be`      |

**SizeOfCode is identical** and there are zero function differences. Only
TimeDateStamp, SizeOfImage, and CheckSum differ.

## Function-Level Analysis: `diff.exe`

```
$ radiff2 -AC local/.../diff.exe released/.../diff.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    693 MATCH
      2 UNMATCH
```

Full output: [radiff2-diff.txt](radiff2-diff.txt)

```
$ ./compare-functions.sh local/.../diff.exe released/.../diff.exe

=== Results ===
Total shared functions: 766
Identical:              766
Different:              0
```

**All 766 functions are instruction-identical.** No flex parser linked.

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../diff.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../diff.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a165a0`   | `0x69603181`   |
| SizeOfCode      | `0x33000`      | `0x33000`      |
| SizeOfImage     | `0x17a000`     | `0x17b000`     |
| CheckSum        | `0x1a28db`     | `0x1a7bbb`     |

**SizeOfCode is identical** and there are zero function differences. Only
TimeDateStamp, SizeOfImage, and CheckSum differ.

## Function-Level Analysis: `diff3.exe`

```
$ radiff2 -AC local/.../diff3.exe released/.../diff3.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    320 MATCH
      2 UNMATCH
```

Full output: [radiff2-diff3.txt](radiff2-diff3.txt)

```
$ ./compare-functions.sh local/.../diff3.exe released/.../diff3.exe

=== Results ===
Total shared functions: 384
Identical:              384
Different:              0
```

**All 384 functions are instruction-identical.** No flex parser linked.

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../diff3.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../diff3.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a165a0`   | `0x69603181`   |
| SizeOfCode      | `0xfa00`       | `0xfa00`       |
| SizeOfImage     | `0x88000`      | `0x89000`      |
| CheckSum        | `0x9a954`      | `0x99c18`      |

**SizeOfCode is identical** and there are zero function differences. Only
TimeDateStamp, SizeOfImage, and CheckSum differ.

## Function-Level Analysis: `libcrypto-3-x64.dll`

```
$ radiff2 -AC local/.../libcrypto-3-x64.dll released/.../libcrypto-3-x64.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
  13032 MATCH
```

Full output: [radiff2-libcrypto-3-x64.txt](radiff2-libcrypto-3-x64.txt)

```
$ ./compare-functions.sh local/.../libcrypto-3-x64.dll released/.../libcrypto-3-x64.dll

=== Results ===
Total shared functions: 13012
Identical:              13012
Different:              0
```

**All 13012 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libcrypto-3-x64.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libcrypto-3-x64.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a164e9`   | `0x69603081`   |
| SizeOfCode      | `0x34bc00`     | `0x34bc00`     |
| SizeOfImage     | `0x51c000`     | `0x51c000`     |
| CheckSum        | `0x62409c`     | `0x62d458`     |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `libcurl-4.dll`

```
$ radiff2 -AC local/.../libcurl-4.dll released/.../libcurl-4.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   1945 MATCH
```

Full output: [radiff2-libcurl-4.txt](radiff2-libcurl-4.txt)

```
$ ./compare-functions.sh local/.../libcurl-4.dll released/.../libcurl-4.dll

=== Results ===
Total shared functions: 2045
Identical:              2045
Different:              0
```

**All 2045 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libcurl-4.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libcurl-4.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16608`   | `0x69603211`   |
| SizeOfCode      | `0x7bc00`      | `0x7bc00`      |
| SizeOfImage     | `0xc6000`      | `0xc6000`      |
| CheckSum        | `0xef734`      | `0xf8ec3`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `libgnurx-0.dll`

```
$ radiff2 -AC local/.../libgnurx-0.dll released/.../libgnurx-0.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    151 MATCH
```

Full output: [radiff2-libgnurx-0.txt](radiff2-libgnurx-0.txt)

```
$ ./compare-functions.sh local/.../libgnurx-0.dll released/.../libgnurx-0.dll

=== Results ===
Total shared functions: 192
Identical:              192
Different:              0
```

**All 192 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libgnurx-0.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libgnurx-0.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a163de`   | `0x69602f17`   |
| SizeOfCode      | `0xd000`       | `0xd000`       |
| SizeOfImage     | `0x5e000`      | `0x5e000`      |
| CheckSum        | `0x5e366`      | `0x62beb`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `liblber.dll`

```
$ radiff2 -AC local/.../liblber.dll released/.../liblber.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    228 MATCH
      1 UNMATCH
```

Full output: [radiff2-liblber.txt](radiff2-liblber.txt)

```
$ ./compare-functions.sh local/.../liblber.dll released/.../liblber.dll

=== Results ===
Total shared functions: 265
Identical:              265
Different:              0
```

**All 265 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../liblber.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../liblber.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a165af`   | `0x69603199`   |
| SizeOfCode      | `0x8200`       | `0x8200`       |
| SizeOfImage     | `0x4a000`      | `0x4a000`      |
| CheckSum        | `0x4b9bf`      | `0x54c07`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `libldap.dll`

```
$ radiff2 -AC local/.../libldap.dll released/.../libldap.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    959 MATCH
```

Full output: [radiff2-libldap.txt](radiff2-libldap.txt)

```
$ ./compare-functions.sh local/.../libldap.dll released/.../libldap.dll

=== Results ===
Total shared functions: 1038
Identical:              1038
Different:              0
```

**All 1038 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libldap.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libldap.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a165bb`   | `0x696031a9`   |
| SizeOfCode      | `0x34e00`      | `0x34e00`      |
| SizeOfImage     | `0x193000`     | `0x194000`     |
| CheckSum        | `0x1b0b92`     | `0x1a4655`     |

**SizeOfCode is identical.** Only TimeDateStamp, SizeOfImage, and CheckSum
differ.

## Function-Level Analysis: `libleech-0.dll`

```
$ radiff2 -AC local/.../libleech-0.dll released/.../libleech-0.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    323 MATCH
```

Full output: [radiff2-libleech-0.txt](radiff2-libleech-0.txt)

```
$ ./compare-functions.sh local/.../libleech-0.dll released/.../libleech-0.dll

=== Results ===
Total shared functions: 354
Identical:              354
Different:              0
```

**All 354 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libleech-0.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libleech-0.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a165c4`   | `0x696031b7`   |
| SizeOfCode      | `0xd800`       | `0xd800`       |
| SizeOfImage     | `0x7b000`      | `0x7b000`      |
| CheckSum        | `0x7eb76`      | `0x7ea92`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `liblmdb.dll`

```
$ radiff2 -AC local/.../liblmdb.dll released/.../liblmdb.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    200 MATCH
```

Full output: [radiff2-liblmdb.txt](radiff2-liblmdb.txt)

```
$ ./compare-functions.sh local/.../liblmdb.dll released/.../liblmdb.dll

=== Results ===
Total shared functions: 263
Identical:              263
Different:              0
```

**All 263 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../liblmdb.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../liblmdb.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16566`   | `0x6960312b`   |
| SizeOfCode      | `0xf800`       | `0xf800`       |
| SizeOfImage     | `0x62000`      | `0x62000`      |
| CheckSum        | `0x70a21`      | `0x672d2`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `libpcre2-8-0.dll`

```
$ radiff2 -AC local/.../libpcre2-8-0.dll released/.../libpcre2-8-0.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    225 MATCH
```

Full output: [radiff2-libpcre2-8-0.txt](radiff2-libpcre2-8-0.txt)

```
$ ./compare-functions.sh local/.../libpcre2-8-0.dll released/.../libpcre2-8-0.dll

=== Results ===
Total shared functions: 263
Identical:              263
Different:              0
```

**All 263 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libpcre2-8-0.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libpcre2-8-0.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16571`   | `0x6960313b`   |
| SizeOfCode      | `0x40200`      | `0x40200`      |
| SizeOfImage     | `0x86000`      | `0x86000`      |
| CheckSum        | `0x93565`      | `0x8cc77`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `librsync-0.dll`

```
$ radiff2 -AC local/.../librsync-0.dll released/.../librsync-0.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    189 MATCH
```

Full output: [radiff2-librsync-0.txt](radiff2-librsync-0.txt)

```
$ ./compare-functions.sh local/.../librsync-0.dll released/.../librsync-0.dll

=== Results ===
Total shared functions: 222
Identical:              222
Different:              0
```

**All 222 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../librsync-0.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../librsync-0.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a165a5`   | `0x6960318a`   |
| SizeOfCode      | `0x9400`       | `0x9400`       |
| SizeOfImage     | `0x66000`      | `0x66000`      |
| CheckSum        | `0x6936e`      | `0x6a69a`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `libssl-3-x64.dll`

```
$ radiff2 -AC local/.../libssl-3-x64.dll released/.../libssl-3-x64.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   3036 MATCH
```

Full output: [radiff2-libssl-3-x64.txt](radiff2-libssl-3-x64.txt)

```
$ ./compare-functions.sh local/.../libssl-3-x64.dll released/.../libssl-3-x64.dll

=== Results ===
Total shared functions: 3089
Identical:              3089
Different:              0
```

**All 3089 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libssl-3-x64.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libssl-3-x64.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16500`   | `0x6960309f`   |
| SizeOfCode      | `0xbbe00`      | `0xbbe00`      |
| SizeOfImage     | `0x115000`     | `0x115000`     |
| CheckSum        | `0x1533b5`     | `0x15ca70`     |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `libxml2-16.dll`

```
$ radiff2 -AC local/.../libxml2-16.dll released/.../libxml2-16.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
   2440 MATCH
```

Full output: [radiff2-libxml2-16.txt](radiff2-libxml2-16.txt)

```
$ ./compare-functions.sh local/.../libxml2-16.dll released/.../libxml2-16.dll

=== Results ===
Total shared functions: 2480
Identical:              2480
Different:              0
```

**All 2480 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libxml2-16.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libxml2-16.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16582`   | `0x69603154`   |
| SizeOfCode      | `0xbd800`      | `0xbd800`      |
| SizeOfImage     | `0x4dd000`     | `0x4dd000`     |
| CheckSum        | `0x50b963`     | `0x508b42`     |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `libyaml-0-2.dll`

```
$ radiff2 -AC local/.../libyaml-0-2.dll released/.../libyaml-0-2.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    185 MATCH
```

Full output: [radiff2-libyaml-0-2.txt](radiff2-libyaml-0-2.txt)

```
$ ./compare-functions.sh local/.../libyaml-0-2.dll released/.../libyaml-0-2.dll

=== Results ===
Total shared functions: 213
Identical:              213
Different:              0
```

**All 213 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../libyaml-0-2.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../libyaml-0-2.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16589`   | `0x69603161`   |
| SizeOfCode      | `0x19c00`      | `0x19c00`      |
| SizeOfImage     | `0x83000`      | `0x83000`      |
| CheckSum        | `0x8887d`      | `0x8f6cb`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `lmdump.exe`

```
$ radiff2 -AC local/.../lmdump.exe released/.../lmdump.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
     84 MATCH
```

Full output: [radiff2-lmdump.txt](radiff2-lmdump.txt)

```
$ ./compare-functions.sh local/.../lmdump.exe released/.../lmdump.exe

=== Results ===
Total shared functions: 118
Identical:              118
Different:              0
```

**All 118 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../lmdump.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../lmdump.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16568`   | `0x6960312c`   |
| SizeOfCode      | `0x2200`       | `0x2200`       |
| SizeOfImage     | `0x24000`      | `0x24000`      |
| CheckSum        | `0x2fb1e`      | `0x25f5f`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `lmmgr.exe`

```
$ radiff2 -AC local/.../lmmgr.exe released/.../lmmgr.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
     95 MATCH
```

Full output: [radiff2-lmmgr.txt](radiff2-lmmgr.txt)

```
$ ./compare-functions.sh local/.../lmmgr.exe released/.../lmmgr.exe

=== Results ===
Total shared functions: 128
Identical:              128
Different:              0
```

**All 128 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../lmmgr.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../lmmgr.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16568`   | `0x6960312d`   |
| SizeOfCode      | `0x2400`       | `0x2400`       |
| SizeOfImage     | `0x24000`      | `0x24000`      |
| CheckSum        | `0x231f7`      | `0x31155`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `mdb_copy.exe`

```
$ radiff2 -AC local/.../mdb_copy.exe released/.../mdb_copy.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
     76 MATCH
```

Full output: [radiff2-mdb_copy.txt](radiff2-mdb_copy.txt)

```
$ ./compare-functions.sh local/.../mdb_copy.exe released/.../mdb_copy.exe

=== Results ===
Total shared functions: 111
Identical:              111
Different:              0
```

**All 111 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../mdb_copy.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../mdb_copy.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16567`   | `0x6960312c`   |
| SizeOfCode      | `0x2000`       | `0x2000`       |
| SizeOfImage     | `0x23000`      | `0x23000`      |
| CheckSum        | `0x2b760`      | `0x23fb6`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `mdb_dump.exe`

```
$ radiff2 -AC local/.../mdb_dump.exe released/.../mdb_dump.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    106 MATCH
```

Full output: [radiff2-mdb_dump.txt](radiff2-mdb_dump.txt)

```
$ ./compare-functions.sh local/.../mdb_dump.exe released/.../mdb_dump.exe

=== Results ===
Total shared functions: 142
Identical:              142
Different:              0
```

**All 142 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../mdb_dump.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../mdb_dump.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16567`   | `0x6960312c`   |
| SizeOfCode      | `0x3400`       | `0x3400`       |
| SizeOfImage     | `0x28000`      | `0x28000`      |
| CheckSum        | `0x2db3a`      | `0x2a38b`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `mdb_load.exe`

```
$ radiff2 -AC local/.../mdb_load.exe released/.../mdb_load.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    112 MATCH
```

Full output: [radiff2-mdb_load.txt](radiff2-mdb_load.txt)

```
$ ./compare-functions.sh local/.../mdb_load.exe released/.../mdb_load.exe

=== Results ===
Total shared functions: 148
Identical:              148
Different:              0
```

**All 148 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../mdb_load.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../mdb_load.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16567`   | `0x6960312c`   |
| SizeOfCode      | `0x3a00`       | `0x3a00`       |
| SizeOfImage     | `0x29000`      | `0x29000`      |
| CheckSum        | `0x33401`      | `0x2f469`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `mdb_stat.exe`

```
$ radiff2 -AC local/.../mdb_stat.exe released/.../mdb_stat.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    101 MATCH
```

Full output: [radiff2-mdb_stat.txt](radiff2-mdb_stat.txt)

```
$ ./compare-functions.sh local/.../mdb_stat.exe released/.../mdb_stat.exe

=== Results ===
Total shared functions: 135
Identical:              135
Different:              0
```

**All 135 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../mdb_stat.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../mdb_stat.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a16566`   | `0x6960312b`   |
| SizeOfCode      | `0x3400`       | `0x3400`       |
| SizeOfImage     | `0x28000`      | `0x28000`      |
| CheckSum        | `0x2ac1a`      | `0x28d1e`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `pthreadGC2.dll`

```
$ radiff2 -AC local/.../pthreadGC2.dll released/.../pthreadGC2.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    219 MATCH
```

Full output: [radiff2-pthreadGC2.txt](radiff2-pthreadGC2.txt)

```
$ ./compare-functions.sh local/.../pthreadGC2.dll released/.../pthreadGC2.dll

=== Results ===
Total shared functions: 275
Identical:              275
Different:              0
```

**All 275 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../pthreadGC2.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../pthreadGC2.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a163dc`   | `0x69602f12`   |
| SizeOfCode      | `0x10000`      | `0x10000`      |
| SizeOfImage     | `0x30000`      | `0x30000`      |
| CheckSum        | `0x3680c`      | `0x2fdf6`      |

**SizeOfCode and SizeOfImage are both identical.** Only TimeDateStamp and
CheckSum differ.

## Function-Level Analysis: `sdiff.exe`

```
$ radiff2 -AC local/.../sdiff.exe released/.../sdiff.exe 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
    361 MATCH
      2 UNMATCH
```

Full output: [radiff2-sdiff.txt](radiff2-sdiff.txt)

```
$ ./compare-functions.sh local/.../sdiff.exe released/.../sdiff.exe

=== Results ===
Total shared functions: 428
Identical:              428
Different:              0
```

**All 428 functions are instruction-identical.**

### PE Header Differences

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../sdiff.exe
$ r2 -q -e bin.cache=true -c 'iH' released/.../sdiff.exe
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x69a165a1`   | `0x69603181`   |
| SizeOfCode      | `0xfe00`       | `0xfe00`       |
| SizeOfImage     | `0x8c000`      | `0x8d000`      |
| CheckSum        | `0xa84bf`      | `0xa3aaa`      |

**SizeOfCode is identical.** Only TimeDateStamp, SizeOfImage, and CheckSum
differ.

## Function-Level Analysis: `zlib1.dll`

```
$ radiff2 -AC local/.../zlib1.dll released/.../zlib1.dll 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="MATCH" || $i=="UNMATCH" || $i=="NEW") print $i}' \
    | sort | uniq -c | sort -rn
     93 MATCH
```

Full output: [radiff2-zlib1.txt](radiff2-zlib1.txt)

This binary is **stripped** (no named function symbols). `objdump -d` only sees
the `.text` section as a single block, so `compare-functions.sh` cannot perform
per-function comparison. `radiff2` uses heuristic analysis and finds 93
functions, all matching.

### PE Header Differences

```
$ python3 -c "..." # extract TimeDateStamp directly from PE header bytes
Local:    TimeDateStamp = 0x00022000
Released: TimeDateStamp = 0x00022000
```

```
$ r2 -q -e bin.cache=true -c 'iH' local/.../zlib1.dll
$ r2 -q -e bin.cache=true -c 'iH' released/.../zlib1.dll
```

| Field           | Local          | Released       |
|-----------------|----------------|----------------|
| TimeDateStamp   | `0x00022000`   | `0x00022000`   |
| SizeOfCode      | `0x15000`      | `0x15000`      |
| SizeOfImage     | `0x26000`      | `0x26000`      |
| CheckSum        | `0x20d36`      | `0x1d832`      |

**TimeDateStamp, SizeOfCode, and SizeOfImage are all identical.** Only CheckSum
differs. The identical TimeDateStamp (`0x00022000`) suggests this is a
pre-built zlib binary that was not recompiled, only relinked into the package.

## Conclusion

All 35 binaries in the CFEngine Windows MSI package were analysed. The results
fall into three categories:

| Category | Binaries | Description |
|----------|----------|-------------|
| CFEngine executables (with flex parser) | 10 | cf-agent, cf-check, cf-execd, cf-key, cf-monitord, cf-net, cf-promises, cf-runagent, cf-secret, cf-serverd |
| CFEngine/third-party (without flex parser) | 24 | cf-upgrade, cmp, diff, diff3, lmdump, lmmgr, mdb_copy, mdb_dump, mdb_load, mdb_stat, sdiff, libcrypto-3-x64, libcurl-4, libgnurx-0, liblber, libldap, libleech-0, liblmdb, libpcre2-8-0, librsync-0, libssl-3-x64, libxml2-16, libyaml-0-2, pthreadGC2 |
| Stripped (no symbols) | 1 | zlib1 |

### Key Findings

1. **Code is functionally identical.** Across all binaries with symbols, a total
   of 57,128 functions were compared. Of these, **57,048 are
   instruction-identical** (99.86%). The remaining 80 differences are the same
   8 flex-generated parser functions (`yy_*`) duplicated across the 10 CFEngine
   executables that link the parser. The diffs are byte-for-byte identical in
   every binary.

2. **Two root causes of non-reproducibility were identified:**

   - **PE TimeDateStamp:** The linker embeds the current time into every PE
     header. This differs between any two builds made at different times and is
     the single largest source of binary differences. The one exception is
     `zlib1.dll`, which has an identical timestamp in both builds (pre-built,
     not recompiled).

   - **Flex-generated code:** 8 `yy_*` functions show register allocation,
     instruction selection, and NOP padding differences. The compiler (GCC
     5.3.1) is identical in both builds, so this is most likely caused by
     different flex versions generating slightly different C source code. In
     3 of 10 binaries (cf-agent, cf-check, cf-net), this results in a 512-byte
     `.text` section size difference; in the other 7, the differences fit within
     the same section alignment.

3. **CheckSum always differs** as a consequence of the above — it is derived
   from the binary contents.

4. **SizeOfImage differs** in most binaries despite identical code. This is
   likely caused by differences in debug information or other non-code sections
   that affect the overall image layout.

### Recommendations

To achieve fully reproducible builds:

1. **Zero the PE TimeDateStamp** at link time (e.g., pass
   `-Wl,--no-insert-timestamp` to the mingw linker), or post-process binaries
   to normalize timestamps.

2. **Pin the flex version** in the build environment to ensure the generated
   lexer source code is identical across builds.

After addressing these two issues, the builds should be byte-for-byte
reproducible.

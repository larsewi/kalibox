#!/bin/bash
#
# compare-functions.sh - Compare two PE binaries function-by-function.
#
# Disassembles both binaries, normalizes away addresses (which change due to
# different code sizes or link order), and compares the remaining instructions
# per function. This isolates actual code differences from address-only changes.
#
# Usage: ./compare-functions.sh <binary-a> <binary-b>
#

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <binary-a> <binary-b>"
    exit 1
fi

BINARY_A="$1"
BINARY_B="$2"

# Create a temp directory for intermediate files, cleaned up on exit.
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# normalize_disassembly <binary> <output-file>
#
# Disassembles a binary and produces a normalized output where each line is:
#   function_name<TAB>instruction
#
# Normalization replaces all hex addresses with "ADDR" so that differences
# caused only by functions landing at different addresses are ignored.
# This lets us focus on actual instruction/logic changes.
normalize_disassembly() {
    local binary="$1"
    local output="$2"

    # Step 1: Disassemble the binary with objdump.
    # Step 2: Use awk to associate each instruction with its function name.
    #         objdump output looks like:
    #
    #           0000000000401540 <FreeFixedStringArray>:
    #             401540:  57          push   %rdi
    #             401541:  56          push   %rsi
    #             ...
    #                                                        (blank line)
    #
    #         We extract the function name from "<...>:" lines, and for each
    #         instruction line we output: function_name<TAB>instruction
    #
    # Step 3: Use sed to replace all hex addresses with "ADDR".
    #         - 0x4ce8a8 becomes ADDR (explicit hex with 0x prefix)
    #         - 4ce8a8  becomes ADDR (5+ digit hex without prefix, e.g. in
    #           call/jmp targets)
    objdump -d "$binary" \
        | awk '
            # Match function header lines like "<FreeFixedStringArray>:"
            /<.*>:/ {
                name = $0
                sub(/.*</, "", name)    # strip everything before <
                sub(/>:.*/, "", name)   # strip >: and everything after
                next
            }
            # Blank line = end of function
            /^$/ { name = ""; next }
            # Instruction line: extract the third tab-separated field (mnemonic + operands)
            name && /^[[:space:]]*[0-9a-f]+:/ {
                split($0, fields, "\t")
                print name "\t" fields[3]
            }
        ' \
        | sed 's/0x[0-9a-f]\+/ADDR/g; s/[0-9a-f]\{5,\}/ADDR/g' \
        > "$output"
}

echo "Disassembling and normalizing binary A..."
normalize_disassembly "$BINARY_A" "$TMPDIR/a.txt"

echo "Disassembling and normalizing binary B..."
normalize_disassembly "$BINARY_B" "$TMPDIR/b.txt"

# Extract sorted unique function names from each binary.
cut -f1 "$TMPDIR/a.txt" | sort -u > "$TMPDIR/fnames_a.txt"
cut -f1 "$TMPDIR/b.txt" | sort -u > "$TMPDIR/fnames_b.txt"

# Report functions that only exist in one binary.
# comm -23 = lines only in file 1, comm -13 = lines only in file 2.
ONLY_A=$(comm -23 "$TMPDIR/fnames_a.txt" "$TMPDIR/fnames_b.txt" | wc -l)
ONLY_B=$(comm -13 "$TMPDIR/fnames_a.txt" "$TMPDIR/fnames_b.txt" | wc -l)

if [ "$ONLY_A" -gt 0 ]; then
    echo
    echo "Functions only in binary A ($ONLY_A):"
    comm -23 "$TMPDIR/fnames_a.txt" "$TMPDIR/fnames_b.txt"
fi

if [ "$ONLY_B" -gt 0 ]; then
    echo
    echo "Functions only in binary B ($ONLY_B):"
    comm -13 "$TMPDIR/fnames_a.txt" "$TMPDIR/fnames_b.txt"
fi

# For each function present in both binaries, extract its normalized
# instructions and diff them. If they match, the function is identical
# at the instruction level (ignoring address differences).
IDENTICAL=0
DIFFERENT=0
DIFFERENT_LIST=""

# Directory for per-function diff files.
DIFF_DIR="diffs"
mkdir -p "$DIFF_DIR"

echo
echo "Comparing shared functions..."

while IFS= read -r fname; do
    # Extract normalized instructions for this function from each binary.
    grep "^${fname}	" "$TMPDIR/a.txt" | cut -f2 > "$TMPDIR/cmp_a.txt"
    grep "^${fname}	" "$TMPDIR/b.txt" | cut -f2 > "$TMPDIR/cmp_b.txt"

    if diff -q "$TMPDIR/cmp_a.txt" "$TMPDIR/cmp_b.txt" > /dev/null 2>&1; then
        IDENTICAL=$((IDENTICAL + 1))
    else
        DIFFERENT=$((DIFFERENT + 1))
        DIFFERENT_LIST="${DIFFERENT_LIST}  ${fname}\n"

        # Write a unified diff for this function to a separate file.
        diff -u "$TMPDIR/cmp_a.txt" "$TMPDIR/cmp_b.txt" \
            --label "binary-a" --label "binary-b" \
            > "$DIFF_DIR/${fname}.txt" || true
    fi
done < <(comm -12 "$TMPDIR/fnames_a.txt" "$TMPDIR/fnames_b.txt")

# Print summary.
TOTAL=$((IDENTICAL + DIFFERENT))

echo
echo "=== Results ==="
echo "Total shared functions: $TOTAL"
echo "Identical:              $IDENTICAL"
echo "Different:              $DIFFERENT"

if [ "$DIFFERENT" -gt 0 ]; then
    echo
    echo "Functions with differences:"
    echo -e "$DIFFERENT_LIST"
    echo "Diffs written to $DIFF_DIR/"
fi

#!/usr/bin/env bash
# check_rasi_colors.sh
# Checks that every .rasi file in your colors/ folder defines
# all the variable names that omarchy-walker.rasi depends on.
#
# Usage:
#   ./check_rasi_colors.sh [colors_dir]
#
# If colors_dir is omitted it defaults to ./colors

set -euo pipefail

COLORS_DIR="${1:-./colors}"

# These are the exact variable names omarchy-walker.rasi uses
REQUIRED=(
    "base"
    "text"
    "border-color"
    "sel-bg"
    "sel-text"
    "keybind-bg"
    "placeholder-fg"
)

# Counters
total=0
passed=0
failed=0

if [[ ! -d "$COLORS_DIR" ]]; then
    echo "Error: directory not found: $COLORS_DIR"
    exit 1
fi

rasi_files=("$COLORS_DIR"/*.rasi)
if [[ ! -e "${rasi_files[0]}" ]]; then
    echo "No .rasi files found in $COLORS_DIR"
    exit 1
fi

echo "Checking .rasi color files in: $COLORS_DIR"
echo "Required variables: ${REQUIRED[*]}"
echo "──────────────────────────────────────────────"

for file in "$COLORS_DIR"/*.rasi; do
    total=$((total + 1))
    name=$(basename "$file")
    missing=()

    for var in "${REQUIRED[@]}"; do
        # Match "varname:" anywhere in the file (inside the * block)
        if ! grep -qE "^\s+${var}\s*:" "$file"; then
            missing+=("$var")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "  ✓  $name"
        passed=$((passed + 1))
    else
        echo "  ✗  $name"
        for m in "${missing[@]}"; do
            echo "       missing: $m"
        done
        failed=$((failed + 1))
    fi
done

echo "──────────────────────────────────────────────"
echo "  $passed/$total passed   $failed failed"

if [[ $failed -gt 0 ]]; then
    exit 1
fi

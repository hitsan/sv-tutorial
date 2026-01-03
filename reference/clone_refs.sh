#!/bin/bash
set -e

REPOS=(
    "https://github.com/vengineer-systemverilog/All-of-SystemVerilog.git"
    "https://github.com/AbhishekTaur/System-Verilog-Practice.git"
    "https://github.com/karimmahmoud22/SystemVerilog-For-Verification.git"
    "https://github.com/VerificationExcellence/SystemVerilogReference.git"
    "https://github.com/pConst/basic_verilog.git"
    "https://github.com/verilator/example-systemverilog.git"
    "https://github.com/ARC-Lab-UF/sv-tutorial.git"
)

cd "$(dirname "$0")"

for repo in "${REPOS[@]}"; do
    name=$(basename "$repo" .git)
    if [[ -d "$name" ]]; then
        echo "Updating: $name"
        git -C "$name" pull --ff-only
    else
        echo "Cloning: $name"
        git clone "$repo"
    fi
done

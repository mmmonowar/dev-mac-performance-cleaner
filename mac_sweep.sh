#!/usr/bin/env bash
# ==============================================================================
# mac_sweep.sh - macOS Performance & Storage Optimization Sweep
# Usage:
#   ./mac_sweep.sh --dry-run    (Preview files to be removed)
#   sudo ./mac_sweep.sh         (Perform full system & cache sweep)
# ==============================================================================

set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "\033[33m[DRY RUN MODE] No files will be deleted.\033[0m\n"
fi

clean_path() {
    local target="$1"
    local desc="$2"

    if [ -d "$target" ] || [ -f "$target" ]; then
        if [ "$DRY_RUN" = true ]; then
            local size
            size=$(du -sh "$target" 2>/dev/null | awk '{print $1}' || echo "N/A")
            echo "[Would Delete] ($size) $desc -> $target"
        else
            echo "[Cleaning] $desc..."
            rm -rf "${target:?}"/* 2>/dev/null || true
        fi
    fi
}

echo "=================================================="
echo "          macOS Optimization Sweep                "
echo "=================================================="

# 1. User & System Caches
clean_path "$HOME/Library/Caches" "User Caches"
clean_path "/Library/Caches" "System Caches"
clean_path "$HOME/Library/Containers/*/Data/Library/Caches" "App Container Caches"
clean_path "$HOME/Library/Logs" "User Logs"
clean_path "$HOME/Library/DiagnosticReports" "Diagnostic Reports"

# 2. Software Update Leftovers
clean_path "/Library/Updates" "macOS Downloaded Updates"
clean_path "/var/db/SoftwareUpdate" "Staged Software Update Files"

# 3. Developer & CLI Caches (Conditional Execution)
if command -v brew &>/dev/null; then
    echo "[Package Manager] Cleaning Homebrew..."
    if [ "$DRY_RUN" = false ]; then
        brew cleanup --prune=all -s &>/dev/null || true
        brew autoremove &>/dev/null || true
    fi
fi

if command -v npm &>/dev/null; then
    echo "[Developer] Cleaning NPM Cache..."
    [ "$DRY_RUN" = false ] && npm cache clean --force &>/dev/null || true
fi

if command -v pnpm &>/dev/null; then
    echo "[Developer] Pruning PNPM Store..."
    [ "$DRY_RUN" = false ] && pnpm store prune &>/dev/null || true
fi

clean_path "$HOME/Library/Developer/Xcode/DerivedData" "Xcode Derived Data"
clean_path "$HOME/Library/Developer/Xcode/Archives" "Xcode Archives"

# 4. System Memory & Network Flushes
if [ "$DRY_RUN" = false ]; then
    echo "[Network] Flushing DNS Cache..."
    dscacheutil -flushcache
    killall -HUP mDNSResponder || true

    if [ "$(id -u)" -eq 0 ]; then
        echo "[Memory] Purging inactive RAM..."
        purge
    else
        echo "[Info] Run with 'sudo' to purge inactive RAM."
    fi
fi

echo "=================================================="
echo "          Sweep Completed Successfully            "
echo "=================================================="
#!/usr/bin/env bash
# ==============================================================================
# mac_diag.sh - macOS Health & Performance Diagnostic Tool
# Usage: ./mac_diag.sh
# ==============================================================================

set -u

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

heading() {
    echo -e "\n${BOLD}${GREEN}=== $1 ===${RESET}"
}

heading "SYSTEM & ARCHITECTURE"
echo "Host Name:     $(hostname)"
echo "macOS Version: $(sw_vers -productVersion) (Build $(sw_vers -buildVersion))"
echo "Architecture:  $(uname -m)"
echo "Uptime:       $(uptime | sed 's/^.*up //' | sed 's/,.*$//')"

heading "THERMAL & POWER HEALTH"
pmset -g batt | grep -v "Currently"
if command -v pmset &>/dev/null; then
    THERM=$(pmset -g therm 2>/dev/null | grep -i "thermal level" || echo "Thermal data unavailable")
    echo "Thermal Level: ${THERM}"
fi

heading "MEMORY & SWAP PRESSURE"
MEMORY_STATS=$(vm_stat)
PAGE_SIZE=$(sysctl -n hw.pagesize)
FREE_PAGES=$(echo "$MEMORY_STATS" | awk '/page size/ {next} /Pages free/ {print $3}' | tr -d '.')
SPEC_PAGES=$(echo "$MEMORY_STATS" | awk '/Pages speculative/ {print $3}' | tr -d '.')
FREE_MB=$(( (FREE_PAGES + SPEC_PAGES) * PAGE_SIZE / 1024 / 1024 ))

echo "Free/Speculative Memory: ~${FREE_MB} MB"
echo "Swap Usage: $(sysctl -n vm.swapusage)"

heading "TOP 5 MEMORY CONSUMERS"
ps aux | sort -rn -k 6 | head -n 5 | awk '{printf "  %-10s %-8s MB  %s\n", $1, int($6/1024), $11}'

heading "TOP 5 CPU CONSUMERS"
ps aux | sort -rn -k 3 | head -n 5 | awk '{printf "  %-10s %-4s%% CPU  %s\n", $1, $3, $11}'

heading "STORAGE & LOCAL SNAPSHOTS"
df -h / | awk 'NR==1 || NR==2 {print "  " $0}'
echo -e "\nLocal Time Machine Snapshots:"
SNAPSHOTS=$(tmutil listlocalsnapshots / 2>/dev/null)
if [ -n "$SNAPSHOTS" ]; then
    echo "$SNAPSHOTS"
else
    echo "  None found."
fi

heading "LARGE APPLICATION SUPPORT & CONTAINER DIRECTORIES"
echo "User Application Support (>1GB):"
du -sh ~/Library/Application\ Support/* 2>/dev/null | awk '$1 ~ /G/ {print "  " $0}' | sort -rh

echo -e "\nUser Sandboxed Containers (>300MB):"
du -sh ~/Library/Containers/* 2>/dev/null | awk '$1 ~ /[0-9]{3}M|G/ {print "  " $0}' | sort -rh | head -n 10

heading "THIRD-PARTY LAUNCH DAEMONS & AGENTS"
echo "User Launch Agents:"
ls -A ~/Library/LaunchAgents 2>/dev/null | sed 's/^/  /' || echo "  None"
echo "System Launch Agents:"
ls -A /Library/LaunchAgents 2>/dev/null | sed 's/^/  /' || echo "  None"

echo -e "\n${BOLD}${GREEN}Diagnostic complete.${RESET}\n"
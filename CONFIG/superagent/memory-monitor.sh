#!/bin/bash
# memory-monitor.sh — Jazz🔥 Real-time Memory Dashboard
# Shows live memory stats optimized for Infinix Note 50s (6GB RAM)
# Usage: bash SCRIPTS/superagent/memory-monitor.sh [--watch]

WORKSPACE="/root/jazz-workspace"
LOG="$WORKSPACE/MEMORY_LOG.md"

show_dashboard() {
    local TIMESTAMP=$(date '+%H:%M:%S')
    
    # Memory
    local MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    local MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    local MEM_AVAIL=$(free -m | awk '/Mem:/ {print $7}')
    local MEM_PCT=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
    
    # Swap
    local SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
    local SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
    
    # CPU load
    local LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    
    # Color coding
    if [ "$MEM_PCT" -lt 50 ]; then
        MEM_COLOR="\033[0;32m"  # green
    elif [ "$MEM_PCT" -lt 75 ]; then
        MEM_COLOR="\033[1;33m"  # yellow
    else
        MEM_COLOR="\033[0;31m"  # red
    fi
    
    echo ""
    echo -e "\033[0;36m🔥 Jazz Memory Dashboard — $TIMESTAMP\033[0m"
    echo -e "\033[0;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " RAM:  ${MEM_COLOR}${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PCT}%)${NC}  |  Available: ${MEM_AVAIL}MB"
    echo -e " Swap: ${SWAP_USED}MB / ${SWAP_TOTAL}MB"
    echo -e " Load: ${LOAD}"
    echo -e " CPU:  $(nproc) cores"
    echo -e "\033[0;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    
    # Warning if memory is critical
    if [ "$MEM_AVAIL" -lt 500 ]; then
        echo -e "\033[0;31m⚠️ CRITICAL: Less than 500MB available. Run memory-optimize.sh${NC}"
    elif [ "$MEM_AVAIL" -lt 1000 ]; then
        echo -e "\033[1;33m⚠️ Low memory: ${MEM_AVAIL}MB available. Consider optimizing.${NC}"
    else
        echo -e "\033[0;32m✅ Healthy: ${MEM_AVAIL}MB available${NC}"
    fi
    
    # Top memory consumers
    echo ""
    echo -e "\033[1;33mTop consumers:${NC}"
    ps aux --sort=-%mem 2>/dev/null | head -4 | awk '{printf "  %-30s %s%%\n", $11, $4}'
}

# Initial run
show_dashboard

# Watch mode
if [ "$1" = "--watch" ]; then
    echo ""
    echo "Watching... (Ctrl+C to stop)"
    while true; do
        sleep 5
        show_dashboard
    done
fi

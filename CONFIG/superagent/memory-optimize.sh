#!/bin/bash
# memory-optimize.sh — Jazz🔥 Memory Optimization for 6GB RAM
# Run this to free memory and optimize for agent workloads
# Usage: bash SCRIPTS/superagent/memory-optimize.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "${CYAN}🔥 Jazz Memory Optimizer${NC}"
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Device: Infinix Note 50s (6GB RAM)"
echo "Before:"
free -h | awk '/Mem:/ {print "  RAM: " $3 " used / " $2}'
echo ""

# 1. Clear page cache (safe, non-destructive)
echo "${YELLOW}[1/5] Clearing page cache...${NC}"
sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null && echo "${GREEN}  ✅ Page cache cleared${NC}" || echo "${YELLOW}  ⚠️ Not available (non-root)${NC}"

# 2. Reduce swappiness for better responsiveness
echo "${YELLOW}[2/5] Optimizing swappiness...${NC}"
if [ -w /proc/sys/vm/swappiness ]; then
    echo 10 > /proc/sys/vm/swappiness
    echo "${GREEN}  ✅ Swappiness set to 10 (less swapping)${NC}"
else
    echo "${YELLOW}  ⚠️ Cannot modify swappiness (non-root)${NC}"
    echo "  ℹ️  Current: $(cat /proc/sys/vm/swappiness 2>/dev/null || echo 'N/A')"
fi

# 3. Clear dentries and inodes
echo "${YELLOW}[3/5] Clearing dentries and inodes...${NC}"
sync && echo 2 > /proc/sys/vm/drop_caches 2>/dev/null && echo "${GREEN}  ✅ Dentry/inode cache cleared${NC}" || echo "${YELLOW}  ⚠️ Not available${NC}"

# 4. Check for memory-hungry processes
echo "${YELLOW}[4/5] Checking memory hogs...${NC}"
ps aux --sort=-%mem 2>/dev/null | head -6 | awk '{print "  " $11 " — " $4 "% MEM"}'

# 5. Optimize Node.js memory for container
echo "${YELLOW}[5/5] Setting Node.js memory limit...${NC}"
export NODE_OPTIONS="--max-old-space-size=512"
echo "${GREEN}  ✅ Node.js memory limited to 512MB${NC}"

echo ""
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "After:"
free -h | awk '/Mem:/ {print "  RAM: " $3 " used / " $2}'
echo ""
echo "${YELLOW}💡 Tip: Add 'export NODE_OPTIONS=\"--max-old-space-size=512\"' to ~/.bash_aliases${NC}"
echo "${YELLOW}   Add 'export MAGIC_CLIPBOARD_ENABLED=false' if OpenCode has clipboard tools${NC}"
echo ""
echo "${CYAN}Memory optimization complete. Agent performance should improve.${NC}"

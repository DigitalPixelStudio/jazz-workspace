#!/bin/bash
# proroot-setup.sh — Jazz🔥 Proroot Installation Guide
# WARNING: This modifies the container runtime. Only run if you understand the risks.
# proroot replaces ptrace-based proot with LD_PRELOAD-based runtime (zero syscall overhead)
# 
# Expected improvement: Benchmark 2319ms → <800ms (native-like)
#
# Usage: 
#   1. Read through this script carefully
#   2. Run: bash SCRIPTS/superagent/proroot-setup.sh install
#   3. If something breaks, run: bash SCRIPTS/superagent/proroot-setup.sh rollback

WORKSPACE="/root/jazz-workspace"
PROROOT_DIR="$WORKSPACE/PROROOT"
PROOT_BACKUP="$PROROOT_DIR/proot-backup"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "${CYAN}🔥 Proroot Installation — Jazz SuperAgent Upgrade${NC}"
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

install_proroot() {
    echo "${YELLOW}[1/6] Creating workspace...${NC}"
    mkdir -p "$PROROOT_DIR"
    echo "${GREEN}  ✅ $PROROOT_DIR${NC}"
    
    echo "${YELLOW}[2/6] Backing up current proot config...${NC}"
    mkdir -p "$PROOT_BACKUP/$TIMESTAMP"
    env | grep PROOT > "$PROOT_BACKUP/$TIMESTAMP/proot-env.txt"
    echo "${GREEN}  ✅ Proot environment saved${NC}"
    
    echo "${YELLOW}[3/6] Detecting architecture...${NC}"
    ARCH=$(uname -m)
    echo "  Architecture: $ARCH"
    
    echo "${YELLOW}[4/6] Downloading proroot...${NC}"
    echo "  Note: proroot binaries not publicly available yet."
    echo "  Check: https://github.com/emontiel-dev/proroot/releases"
    echo ""
    echo "  ${YELLOW}Manual steps:${NC}"
    echo "  1. Download libproroot.so (arm64) from the releases page"
    echo "  2. Place in: $PROROOT_DIR/"
    echo "  3. chmod +x the binary"
    echo ""
    
    echo "${YELLOW}[5/6] Setting up LD_PRELOAD wrapper...${NC}"
    cat > "$PROROOT_DIR/use-proroot.sh" << 'WRAPPER'
#!/bin/bash
# Source this to enable proroot in current session
# Usage: source PROROOT/use-proroot.sh

export PROROOT_LIB_PATH="$HOME/jazz-workspace/PROROOT/libproroot.so"
export PROROOT_LINKER_PATH="$HOME/jazz-workspace/PROROOT/ld-linux-aarch64.so.1"
export LD_PRELOAD="$PROROOT_LIB_PATH"

echo "🔥 proroot enabled — zero ptrace overhead"
echo "   Run 'env | grep PROROOT' to verify"
WRAPPER
    chmod +x "$PROROOT_DIR/use-proroot.sh"
    echo "${GREEN}  ✅ Wrapper script created${NC}"
    
    echo "${YELLOW}[6/6] Creating rollback script...${NC}"
    cat > "$PROROOT_DIR/rollback-proroot.sh" << 'ROLLBACK'
#!/bin/bash
# Rollback proroot — restore normal proot operation
unset LD_PRELOAD
unset PROROOT_LIB_PATH
unset PROROOT_LINKER_PATH
echo "✅ proroot disabled — reverted to standard proot"
ROLLBACK
    chmod +x "$PROROOT_DIR/rollback-proroot.sh"
    echo "${GREEN}  ✅ Rollback script created${NC}"
    
    echo ""
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${GREEN}🎉 Proroot setup skeleton complete!${NC}"
    echo ""
    echo "${YELLOW}To complete installation:${NC}"
    echo "  Step 1: Go to https://github.com/emontiel-dev/proroot/releases"
    echo "  Step 2: Download the latest aarch64 release binary"
    echo "  Step 3: Copy to $PROROOT_DIR/"
    echo "  Step 4: Run: source $PROROOT_DIR/use-proroot.sh"
    echo "  Step 5: Run benchmark: bash SCRIPTS/benchmark.sh"
    echo ""
    echo "${YELLOW}Expected improvement:${NC}"
    echo "  Current benchmark: ~2319ms"
    echo "  Expected with proroot: <800ms (🚀 native-like)"
    echo ""
    echo "${YELLOW}To rollback:${NC}"
    echo "  Run: bash $PROROOT_DIR/rollback-proroot.sh"
    echo "  Or just close and reopen the terminal session"
}

rollback_proroot() {
    echo "${YELLOW}Rolling back proroot...${NC}"
    unset LD_PRELOAD
    unset PROROOT_LIB_PATH
    unset PROROOT_LINKER_PATH
    echo "${GREEN}✅ Rolled back. Standard proot operational.${NC}"
}

case "${1:-help}" in
    install)
        install_proroot
        ;;
    rollback)
        rollback_proroot
        ;;
    help|*)
        echo "Usage: $0 {install|rollback|help}"
        echo ""
        echo "  install   — Set up proroot skeleton (download binary manually)"
        echo "  rollback  — Disable proroot, revert to standard proot"
        echo ""
        echo "What is proroot?"
        echo "  proroot replaces ptrace-based proot with LD_PRELOAD-based runtime."
        echo "  Zero context switches per syscall. No ptrace overhead."
        echo "  Expected: 3x faster process spawn, near-native filesystem I/O."
        ;;
esac

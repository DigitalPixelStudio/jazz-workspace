#!/bin/bash
# benchmark.sh — Jazz🔥 Performance Benchmark Suite
# Measures container performance across key dimensions
# Usage: ./benchmark.sh [--full]

WORKSPACE="/root/jazz-workspace"
BENCHMARK_FILE="$WORKSPACE/BENCHMARKS.md"
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M UTC')

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "${CYAN}🔥 Jazz Performance Benchmark${NC}"
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

results=""
summary=""

# 1. File I/O benchmark (write 1000 small files)
echo "${YELLOW}[1/5] File I/O (1000 x 1KB files)...${NC}"
TMPDIR=$(mktemp -d)
START=$(date +%s%N)
for i in $(seq 1 1000); do
  echo "data-$i" > "$TMPDIR/file-$i.tmp"
done
END=$(date +%s%N)
FILE_IO_MS=$(( (END - START) / 1000000 ))
rm -rf "$TMPDIR"
results="$results| File I/O (1000 writes) | ${FILE_IO_MS}ms |\n"
echo "  ${GREEN}✓${NC} $FILE_IO_MS ms"

# 2. Process spawn latency (100 shell forks)
echo "${YELLOW}[2/5] Process spawn (100 forks)...${NC}"
START=$(date +%s%N)
for i in $(seq 1 100); do
  /bin/true 2>/dev/null
done
END=$(date +%s%N)
FORK_MS=$(( (END - START) / 1000000 ))
results="$results| Process spawn (100 forks) | ${FORK_MS}ms |\n"
echo "  ${GREEN}✓${NC} $FORK_MS ms"

# 3. Git operation speed
echo "${YELLOW}[3/5] Git operations...${NC}"
cd "$WORKSPACE"
START=$(date +%s%N)
git status --porcelain > /dev/null
END=$(date +%s%N)
GIT_STATUS_MS=$(( (END - START) / 1000000 ))
git log --oneline -1 > /dev/null 2>&1
GIT_LOG_MS=$(( (END - START) / 1000000 ))
results="$results| Git status | ${GIT_STATUS_MS}ms |\n"
echo "  ${GREEN}✓${NC} Status: $GIT_STATUS_MS ms"

# 4. grep/search speed (search across workspace)
echo "${YELLOW}[4/5] Search performance (rg across workspace)...${NC}"
if command -v rg &>/dev/null; then
  SEARCH_CMD="rg"
elif command -v grep &>/dev/null; then
  SEARCH_CMD="grep -r"
fi
cd "$WORKSPACE"
START=$(date +%s%N)
rg -l "Benchmark" --max-filesize 1M . 2>/dev/null | head -5 > /dev/null
END=$(date +%s%N)
SEARCH_MS=$(( (END - START) / 1000000 ))
results="$results| Search (rg workspace) | ${SEARCH_MS}ms |\n"
echo "  ${GREEN}✓${NC} $SEARCH_MS ms"

# 5. Startup time (bash + script overhead)
echo "${YELLOW}[5/5] Shell startup...${NC}"
START=$(date +%s%N)
bash -c 'echo -n' 2>/dev/null
END=$(date +%s%N)
SHELL_MS=$(( (END - START) / 1000000 ))
results="$results| Shell startup (bash) | ${SHELL_MS}ms |\n"
echo "  ${GREEN}✓${NC} $SHELL_MS ms"

# Full benchmark (optional, heavier tests)
if [ "$1" = "--full" ]; then
  echo ""
  echo "${YELLOW}[FULL] Large file I/O (10 x 10MB)...${NC}"
  TMPDIR=$(mktemp -d)
  dd if=/dev/urandom of="$TMPDIR/large1.dat" bs=1M count=10 2>/dev/null
  dd if=/dev/urandom of="$TMPDIR/large2.dat" bs=1M count=10 2>/dev/null
  START=$(date +%s%N)
  cp "$TMPDIR/large1.dat" "$TMPDIR/copy1.dat"
  cp "$TMPDIR/large2.dat" "$TMPDIR/copy2.dat"
  END=$(date +%s%N)
  LARGE_IO_MS=$(( (END - START) / 1000000 ))
  rm -rf "$TMPDIR"
  results="$results| Large file I/O (20MB copy) | ${LARGE_IO_MS}ms |\n"
  echo "  ${GREEN}✓${NC} $LARGE_IO_MS ms"
fi

# Calculate composite score (lower is better)
SCORE=$(( FILE_IO_MS + FORK_MS + SEARCH_MS + SHELL_MS ))
if [ "$1" = "--full" ]; then
  SCORE=$(( SCORE + LARGE_IO_MS ))
fi

echo ""
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${GREEN}Composite Score: $SCORE${NC}"
echo ""
echo "${YELLOW}Interpretation:${NC}"
echo "  < 1000ms:  ${GREEN}Excellent${NC} (native-like performance)"
echo "  1000-3000ms: ${YELLOW}Good${NC} (minor container overhead)"
echo "  3000-8000ms: ${YELLOW}Moderate${NC} (noticeable container overhead)"
echo "  > 8000ms:  ${RED}Slow${NC} (proot overhead significant)"
echo ""

# Save to BENCHMARKS.md
echo "## Benchmark Run: $TIMESTAMP" >> "$BENCHMARK_FILE"
echo "" >> "$BENCHMARK_FILE"
printf "$results" >> "$BENCHMARK_FILE"
echo "| **Composite Score** | **$SCORE** |" >> "$BENCHMARK_FILE"
echo "" >> "$BENCHMARK_FILE"

echo "${CYAN}Results saved to BENCHMARKS.md${NC}"

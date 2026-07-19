# Jazz🔥 Performance Benchmarks

Track container performance over time. Run with:
```bash
bash SCRIPTS/benchmark.sh    # Quick (5 tests)
bash SCRIPTS/benchmark.sh --full  # Full (includes large I/O)
```

## Score Guide
| Score | Rating | Meaning |
|-------|--------|---------|
| < 1000ms | 🚀 Excellent | Native-like performance |
| 1000-3000ms | ✅ Good | Minor container overhead |
| 3000-8000ms | ⚠️ Moderate | Noticeable proot overhead |
| > 8000ms | ❌ Slow | Proot overhead significant |

---

<!-- New benchmarks will be appended here -->
## Benchmark Run: 2026-07-19 17:42 UTC

| File I/O (1000 writes) | 412ms |
| Process spawn (100 forks) | 1604ms |
| Git status | 326ms |
| Search (rg workspace) | 188ms |
| Shell startup (bash) | 115ms |
| **Composite Score** | **2319** |


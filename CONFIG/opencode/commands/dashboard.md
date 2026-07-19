---
name: dashboard
description: Full workspace dashboard — git, system, memory, projects, benchmarks in one view
---

Run `bash /root/jazz-workspace/SCRIPTS/workspace-status.sh` and combine with memory state.

Then generate a compact dashboard showing:
```
🔥 Jazz Workspace Dashboard
━━━━━━━━━━━━━━━━━━━━━━━
📅 Session: {date}
⚡ Mode: {reasoning mode}
📂 Git: {branch} | {status} | {unpushed} unpushed
💻 System: {load} | {mem} used | {disk} used
📚 Memory: {last session} | {open items}
🏆 Benchmarks: {last benchmark date} | {scores}
📁 Projects: {count} active
```

---
name: sys
description: Real-time system info — uptime, memory, disk, load, network
---

Quick system snapshot:

```
Host: `!hostname`
Uptime: `!uptime -p | sed 's/up //'`
Memory: `!free -h | awk '/Mem:/ {print $3 " / " $2}'`
Disk: `!df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}'`
Load: `!uptime | awk -F'load average:' '{print $2}' | xargs`
Processes: `!ps aux | wc -l`
Network: `!ip -4 addr show | grep inet | awk '{print $2}' | head -3`
Container: `!uname -a | awk '{print $2, $3}'`
```

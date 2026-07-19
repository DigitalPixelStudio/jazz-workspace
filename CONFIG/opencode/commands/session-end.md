---
name: session-end
description: End session properly — save context, update memory, checkpoint workspace
---

Execute end-of-session sequence:
1. Update `/root/jazz-workspace/CONTEXT.md` with current active state
2. Append a log entry to `/root/jazz-workspace/MEMORY.md`
3. Check git status and suggest commit if needed
4. Say: "✅ Session saved. Next time I'll pick up right here."

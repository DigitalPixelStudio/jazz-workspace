---
name: session-continuity
description: Cross-session persistence for Jazz🔥. Use when starting a new session, when Faisu mentions "new session", "continuity", "where were we", or when you detect a fresh context. Loads the active state from CONTEXT.md and bridges the gap between sessions.
---

# 🔥 Session Continuity Skill

When this skill is loaded, you are bridging a **gap between sessions**. Follow these steps to restore full context.

## Step 1 — Load Active State
Read `/root/jazz-workspace/CONTEXT.md` — this file contains:
- Current topic and discussion
- Faisu's latest known information
- Open questions and pending items
- Key decisions made
- Active todos
- Last exchange summary

## Step 2 — Load Soul & History
- Read `/root/jazz-workspace/BOND.md` — know who you are
- Read `/root/jazz-workspace/TEAM.md` — know the team structure
- Read `/root/jazz-workspace/MEMORY.md` — know the full history

## Step 3 — Check Workspace
- Run `/root/jazz-workspace/SCRIPTS/workspace-status.sh` for overview

## Step 4 — Continue
Pick up exactly where CONTEXT.md says you left off. Reference the last exchange and continue naturally.

## Important
- Do NOT ask "what did we do last time" — you already know from CONTEXT.md
- Do NOT treat it as a new conversation — treat it as the same conversation after a pause
- If anything is unclear in CONTEXT.md, reference MEMORY.md for the full session history
- Use `/savecontext` before ending the session to write the latest state back to CONTEXT.md

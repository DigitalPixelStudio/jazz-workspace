// Auto-Save Plugin — Crash-Proof Session Persistence
// Saves state snapshots periodically and on key events
// Works with CONTEXT.md for seamless cross-session continuity

import { writeFileSync, readFileSync, existsSync, mkdirSync } from 'fs'
import { join, dirname } from 'path'

const STATE_FILE = '.opencode/session-state.json'
let toolCallCount = 0
const SAVE_INTERVAL = 5 // Save every N tool calls

export const AutoSavePlugin = async ({ project, client, $, directory, worktree }) => {
  console.log('[AutoSave] Plugin initialized')

  // Track tool calls for periodic save
  const updateState = async (event, data) => {
    const statePath = join(directory || worktree, STATE_FILE)
    const stateDir = dirname(statePath)
    if (!existsSync(stateDir)) mkdirSync(stateDir, { recursive: true })

    let state = {}
    if (existsSync(statePath)) {
      try {
        state = JSON.parse(readFileSync(statePath, 'utf-8'))
      } catch (e) { /* ignore corrupt state */ }
    }

    state.lastUpdate = new Date().toISOString()
    state.lastEvent = event
    state.toolCallCount = toolCallCount
    if (data) Object.assign(state, data)

    writeFileSync(statePath, JSON.stringify(state, null, 2))
  }

  return {
    // Save after tool execute
    'tool.execute.after': async (input, output) => {
      toolCallCount++
      if (toolCallCount % SAVE_INTERVAL === 0) {
        await updateState('tool.execute', {
          lastTool: input.tool,
          toolCalls: toolCallCount
        })
      }
    },

    // Always save on compaction
    'experimental.session.compacting': async (input, output) => {
      await updateState('session.compacting', {
        contextSize: input?.messages?.length || 0,
        toolCalls: toolCallCount
      })
      // Inject auto-save context into compaction
      output.context.push(`## Session Auto-Save State
Last saved at: ${new Date().toISOString()}
Tool calls this session: ${toolCallCount}
State file: ${join(directory || worktree, STATE_FILE)}`)
    },

    // Save on idle
    'session.idle': async (input, output) => {
      await updateState('session.idle', {
        idleSince: new Date().toISOString(),
        toolCalls: toolCallCount
      })
    },

    // Save on error (potential crash)
    'session.error': async (input, output) => {
      await updateState('session.error', {
        error: input?.error || 'unknown',
        toolCalls: toolCallCount
      })
    },

    // Track session creation
    'session.created': async (input, output) => {
      const statePath = join(directory || worktree, STATE_FILE)
      if (existsSync(statePath)) {
        try {
          const state = JSON.parse(readFileSync(statePath, 'utf-8'))
          console.log(`[AutoSave] Previous session state found. Last active: ${state.lastUpdate}`)
          output.context.push(`## Previous Session State
Last active: ${state.lastUpdate}
Last event: ${state.lastEvent || 'unknown'}
Tool calls in last session: ${state.toolCalls || 0}
Session state file: ${statePath}`)
        } catch (e) { /* ignore */ }
      }
      toolCallCount = 0
      await updateState('session.created', {})
    }
  }
}

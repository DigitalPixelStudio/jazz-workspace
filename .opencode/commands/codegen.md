---
name: codegen
description: Multi-agent code generation — plan, generate, review, fix pipeline
subtask: true
model: deepseek/deepseek-v4-flash
temperature: 1.0
---

# 💻 Code Generation: Multi-Agent Development Pipeline

Execute a complete code generation pipeline using the multi-agent pattern:

## Phase 1 — Architecture (@orchestrator)
- Analyze requirements
- Design system architecture
- Define module interfaces
- Map dependencies

## Phase 2 — Implementation (@worker × N)
- Generate code for each module in parallel
- Follow existing codebase conventions
- Include necessary imports and types

## Phase 3 — Review (@validator)
- Check code quality and correctness
- Verify against requirements
- Identify edge cases and potential issues

## Phase 4 — Fix & Polish 
- Address review findings
- Ensure consistency across modules
- Verify with build/lint commands if applicable

## Requirements
$ARGUMENTS

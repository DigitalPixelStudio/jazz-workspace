---
name: deepresearch
description: Multi-agent deep research — parallel web research synthesized into comprehensive report
subtask: true
model: deepseek/deepseek-v4-flash
temperature: 1.0
---

# 🔬 Deep Research: Multi-Agent Research Pipeline

Execute a comprehensive multi-source research project using parallel agents:

## Phase 1 — Research Planning
Decompose the topic into 3-5 research dimensions. Each dimension gets its own researcher agent.

## Phase 2 — Parallel Research
Launch multiple @researcher agents in parallel, each covering one dimension.
Each fetches 3-5 sources, cross-references, and returns structured findings.

## Phase 3 — Synthesis
Combine all research dimensions. Identify:
- Key findings (with sources)
- Conflicting information
- Knowledge gaps
- Actionable insights

## Phase 4 — Report
Deliver a comprehensive research report with executive summary, findings, and recommendations.

## Research Topic
$ARGUMENTS

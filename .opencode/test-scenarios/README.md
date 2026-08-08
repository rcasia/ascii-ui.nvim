# Agent Testing Framework

This directory contains test scenarios to validate agent behavior and instruction clarity.

## Purpose

Test scenarios help verify:
1. **Instructions work**: Agents can complete tasks using their instructions
2. **Permissions correct**: Agents can access what they need, blocked from what they shouldn't
3. **Workflows clear**: Agents follow expected processes (commit, review, escalate)
4. **Skills load correctly**: Agents load relevant skills when needed

## Directory Structure

```
test-scenarios/
├── README.md                    # This file
├── ascii-ui-dev/                # Dev agent scenarios
│   ├── 01-simple-bug-fix/
│   ├── 02-new-component/
│   └── 03-refactor-hooks/
├── convention-reviewer/         # Reviewer agent scenarios
│   ├── 01-review-clean-code/
│   └── 02-review-violations/
├── nvim-docs-researcher/        # Researcher agent scenarios
│   ├── 01-find-api/
│   └── 02-explain-pattern/
└── agent-teacher/               # Teacher agent scenarios
    ├── 01-update-instructions/
    └── 02-create-skill/
```

## Scenario Format

Each scenario contains:

### task.md
Describes what the agent should do. Clear, specific, testable.

### expected.md
Describes expected behavior:
- What files should be created/modified
- What commands should be run
- What the final state should be

### validation.md
How to verify success:
- Commands to check
- Files to inspect
- Expected outputs

## Running Tests

### Manual Testing

1. **Select scenario**: Choose a scenario from the appropriate agent directory
2. **Load agent**: Start opencode with the target agent
3. **Provide task**: Give the agent the task from `task.md`
4. **Observe behavior**: Watch what the agent does
5. **Validate**: Check against `validation.md`

### Automated Testing (Future)

```bash
# Run all scenarios for an agent
opencode test-agent ascii-ui-dev

# Run specific scenario
opencode test-agent ascii-ui-dev 01-simple-bug-fix

# Validate results
opencode validate-agent ascii-ui-dev
```

## Creating New Scenarios

1. **Identify gap**: What behavior needs testing?
2. **Create directory**: `test-scenarios/<agent>/<scenario-name>/`
3. **Write task.md**: Clear, specific task description
4. **Write expected.md**: Expected files, commands, state
5. **Write validation.md**: How to verify success
6. **Test manually**: Run the scenario to verify it works
7. **Commit**: Add to version control

## Scenario Categories

### Basic (01-09)
Simple tasks that test core functionality.

### Intermediate (10-19)
Multi-step tasks that test workflows.

### Advanced (20-29)
Complex tasks that test edge cases and error handling.

### Integration (30+)
Tasks that test agent-to-agent communication.

## Validation Criteria

### Pass
- Agent completes task without errors
- Agent follows expected workflow
- Agent uses correct permissions
- Agent loads relevant skills
- Final state matches expected.md

### Fail
- Agent gets stuck or loops
- Agent violates permissions
- Agent misses required steps
- Agent doesn't load skills when needed
- Final state doesn't match expected.md

### Partial Pass
- Agent completes task but with warnings
- Agent takes unexpected but valid path
- Agent needs clarification but eventually succeeds

## Difficulty Reporting

If a scenario reveals instruction gaps:

1. **Document difficulty**: What went wrong?
2. **Analyze root cause**: Why did it fail?
3. **Update instructions**: Fix the agent's instructions
4. **Re-test**: Run scenario again to verify fix
5. **Report**: Add to agent's difficulty log

## Changelog

- 2026-08-08: Initial testing framework created

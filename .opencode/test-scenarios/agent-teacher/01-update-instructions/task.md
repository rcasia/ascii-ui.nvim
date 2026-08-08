# Task: Update Agent Instructions Based on Difficulty Report

## Context

ascii-ui-dev reported a difficulty after completing a task:

```
## Difficulties

- [instructions] Unclear when to use useState vs useReducer | wasted time trying useState first | checked tests for examples
```

The agent spent time trying useState when useReducer would have been better. The instructions don't clearly explain when to use each hook.

## Your Task

1. **Analyze difficulty**: Understand what went wrong
2. **Identify root cause**: Why were the instructions unclear?
3. **Update instructions**: Add clear guidance on useState vs useReducer to ascii-ui-dev's instructions
4. **Document change**: Add changelog entry explaining the update
5. **Commit changes**: Commit the instruction update

## Success Criteria

- Root cause identified
- Instructions updated with clear guidance
- Decision criteria provided (when to use useState vs useReducer)
- Changelog entry added
- Changes committed

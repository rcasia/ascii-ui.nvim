# Expected Behavior

## Agent Actions

1. **Read source file**: Agent reads `lua/ascii-ui/buffer/segment.lua`
2. **Identify bug**: Agent finds the `count()` method and understands the issue
3. **Read test file**: Agent reads `tests/unit/segment_spec.lua` to understand test structure
4. **Write test**: Agent adds test case for empty string handling
5. **Fix bug**: Agent updates `count()` method to handle empty strings
6. **Run tests**: Agent runs `make test` to verify fix
7. **Run linting**: Agent runs `make check` to ensure code quality
8. **Consult reviewer**: Agent asks convention-reviewer to review changes
9. **Commit**: Agent commits with proper format after approval
10. **Push**: Agent pushes to remote

## Expected Files Modified

- `lua/ascii-ui/buffer/segment.lua` - Bug fix in `count()` method
- `tests/unit/segment_spec.lua` - New test case added

## Expected Commands Run

```bash
make test                    # Verify all tests pass
make check                   # Verify linting passes
git add .                    # Stage changes
git commit -m "fix(buffer): handle empty strings in Segment:count()"
git push origin main         # Push to remote
```

## Expected Git State

- Clean working directory after commit
- New commit on main branch
- Commit message follows conventional format
- Remote repository updated

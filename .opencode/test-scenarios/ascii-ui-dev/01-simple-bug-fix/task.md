# Task: Fix Simple Bug

## Context

The `Segment:count()` method in `lua/ascii-ui/buffer/segment.lua` has a bug where it doesn't handle empty strings correctly. When an empty string is passed, it should return 0, but currently it throws an error.

## Your Task

1. **Identify the bug**: Read `lua/ascii-ui/buffer/segment.lua` and find the `count()` method
2. **Write a failing test**: Create a test in `tests/unit/segment_spec.lua` that verifies empty string handling
3. **Fix the bug**: Update the `count()` method to handle empty strings
4. **Verify fix**: Run the test to ensure it passes
5. **Run full suite**: Run `make test` to ensure no regressions
6. **Commit**: Commit the fix with proper conventional commit format

## Success Criteria

- Test for empty string handling exists and passes
- Bug is fixed in `segment.lua`
- All tests pass (`make test`)
- Code passes linting (`make check`)
- Changes committed with format: `fix(buffer): handle empty strings in Segment:count()`
- Changes pushed to remote

# Validation Steps

## 1. Check Test Exists

```bash
grep -n "empty string" tests/unit/segment_spec.lua
```

**Expected**: Should find test case for empty string handling

## 2. Check Bug Fix

```bash
grep -A 5 "function Segment:count" lua/ascii-ui/buffer/segment.lua
```

**Expected**: Should see logic that handles empty strings (e.g., `if self.content == "" then return 0 end`)

## 3. Run Tests

```bash
make test
```

**Expected**: All tests pass, including new empty string test

## 4. Run Linting

```bash
make check
```

**Expected**: No warnings or errors

## 5. Check Git Log

```bash
git log --oneline -1
```

**Expected**: Latest commit message matches format:
```
fix(buffer): handle empty strings in Segment:count()
```

## 6. Check Git Status

```bash
git status
```

**Expected**: Clean working directory (nothing to commit)

## 7. Check Remote

```bash
git log origin/main --oneline -1
```

**Expected**: Remote main branch has the same commit

## Validation Checklist

- [ ] Test for empty string exists in `tests/unit/segment_spec.lua`
- [ ] Bug fix present in `lua/ascii-ui/buffer/segment.lua`
- [ ] All tests pass (`make test`)
- [ ] No linting errors (`make check`)
- [ ] Commit message follows conventional format
- [ ] Working directory clean
- [ ] Changes pushed to remote

## Common Failures

### Agent didn't write test
- **Symptom**: No test case for empty string
- **Cause**: Agent skipped TDD workflow
- **Fix**: Update agent instructions to emphasize test-first approach

### Agent didn't run make check
- **Symptom**: Code passes tests but fails linting
- **Cause**: Agent forgot to run quality checks
- **Fix**: Add reminder to agent instructions

### Agent didn't consult convention-reviewer
- **Symptom**: Commit made without review
- **Cause**: Agent skipped mandatory consultation
- **Fix**: Reinforce mandatory consultation rule

### Agent didn't push
- **Symptom**: Commit exists locally but not on remote
- **Cause**: Agent forgot to push
- **Fix**: Add "push after commit" to agent workflow

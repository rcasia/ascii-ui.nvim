# Validation Steps

## 1. Check Agent Ran Required Commands

Look for evidence agent ran:
- `git status` or `git diff`
- `make check`
- `make test`

**Expected**: Agent output shows these commands were executed

## 2. Check Review Report Format

Agent should produce structured output with:
- Summary section (pass/fail counts)
- Violations section (if any)
- Recommendations section (if any)
- Clear verdict (APPROVED/REJECTED)

**Expected**: Output follows expected format

## 3. Check Checklist Coverage

Agent should have checked:
- Code style (StyLua, luacheck)
- Naming conventions
- Module pattern
- Test requirements
- Type annotations
- File organization

**Expected**: Review mentions these areas

## 4. Check Verdict Clarity

Agent must give explicit verdict:
- ✅ APPROVED (if all checks pass)
- ❌ REJECTED (if violations found)

**Expected**: Verdict is unambiguous

## 5. Check Violation Specificity

If violations found, agent should provide:
- File path
- Line number
- What's wrong
- What's expected

**Expected**: Violations are specific and actionable

## Validation Checklist

- [ ] Agent ran `git status` or `git diff`
- [ ] Agent ran `make check`
- [ ] Agent ran `make test`
- [ ] Review report follows expected format
- [ ] All checklist items covered
- [ ] Verdict is explicit (APPROVED/REJECTED)
- [ ] Violations (if any) include file:line references

## Common Failures

### Agent didn't run make check
- **Symptom**: No evidence of linting check
- **Cause**: Agent skipped quality verification
- **Fix**: Update agent instructions to emphasize running checks

### Agent gave vague verdict
- **Symptom**: "Looks good" without explicit approval
- **Cause**: Agent didn't follow output format
- **Fix**: Reinforce structured output requirement

### Agent didn't check all items
- **Symptom**: Review misses key conventions
- **Cause**: Agent didn't use full checklist
- **Fix**: Add checklist reminder to agent instructions

### Agent approved bad code
- **Symptom**: Approved code with violations
- **Cause**: Agent didn't apply checklist properly
- **Fix**: Add examples of common violations to review

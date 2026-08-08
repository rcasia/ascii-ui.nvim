# Validation Steps

## 1. Check API Coverage

Agent should identify these key APIs:
- `nvim_open_win()`
- `nvim_win_set_config()`
- `nvim_win_close()`
- At least 2-3 related functions

**Expected**: Output mentions these functions

## 2. Check Signature Format

Each API should have:
- Function name
- Parameter list with types
- Return value
- Example: `nvim_open_win({buffer}, {enter}, {config})`

**Expected**: Signatures are complete and accurate

## 3. Check Descriptions

Each API should have:
- Clear description of purpose
- Parameter explanations
- Return value explanation

**Expected**: Descriptions are factual and cite documentation

## 4. Check Source Citations

Agent should reference:
- Help tags (e.g., `:help nvim_open_win()`)
- Or file paths in project
- Or Neovim documentation sections

**Expected**: Sources are cited for each API

## 5. Check Output Format

Agent should follow expected format:
- Clear sections for each API
- Consistent structure
- Usage pattern section
- Related APIs section

**Expected**: Output is well-organized and readable

## Validation Checklist

- [ ] At least 4 floating window APIs identified
- [ ] Function signatures provided for each
- [ ] Clear descriptions for each API
- [ ] Sources cited (help tags or paths)
- [ ] Output follows expected format
- [ ] Usage pattern or example provided
- [ ] Related APIs mentioned

## Common Failures

### Agent didn't cite sources
- **Symptom**: No help tags or documentation references
- **Cause**: Agent didn't follow citation requirement
- **Fix**: Reinforce "always cite sources" rule

### Agent provided incomplete signatures
- **Symptom**: Missing parameters or return values
- **Cause**: Agent didn't extract full signature
- **Fix**: Add signature template to agent instructions

### Agent speculated about APIs
- **Symptom**: Descriptions not backed by documentation
- **Cause**: Agent guessed instead of researching
- **Fix**: Reinforce "never speculate" constraint

### Agent didn't follow format
- **Symptom**: Unstructured output
- **Cause**: Agent didn't use expected format
- **Fix**: Add format template to agent instructions

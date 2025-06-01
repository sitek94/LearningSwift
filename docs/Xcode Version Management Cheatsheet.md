# Xcode Version Management Cheatsheet

## What is What?

| Location | What it Does | When it Wins |
|----------|--------------|--------------|
| **Target → General → Version/Build** | Sets default values for `$(MARKETING_VERSION)` and `$(CURRENT_PROJECT_VERSION)` | Used when no override provided |
| **Target → Build Settings → MARKETING_VERSION** | Same as General tab, just different UI | Same values, different view |
| **Target → Info tab** | Overrides Info.plist file entirely | **ALWAYS WINS** - avoid using this! |
| **Info.plist file** | Template with variables like `$(MARKETING_VERSION)` | Used unless Info tab has values |
| **xcodebuild command line** | Runtime override of build settings | **WINS in CI** - overrides everything |

## Priority Order (Highest to Lowest)

1. 🥇 **xcodebuild command line** (our CI script)
2. 🥈 **Target → Info tab entries** (avoid these!)  
3. 🥉 **Target → General/Build Settings** (set these for local dev)
4. 🏅 **Info.plist file** (should use variables like `$(MARKETING_VERSION)`)

## What You Should Do

### ✅ Correct Setup:
- **Info.plist**: Use `$(MARKETING_VERSION)` and `$(CURRENT_PROJECT_VERSION)`
- **Target → General**: Set Version=1.0.1, Build=1 (for local dev)
- **Target → Info tab**: Should be empty/minimal
- **CI**: Override via xcodebuild parameters

### ❌ Avoid:
- **Target → Info tab**: Don't add version entries here
- **Hardcoded values in Info.plist**: Don't use "1.0.1" directly

## Quick Check:

1. **Target → Info tab**: Should NOT have version entries
2. **Target → General**: Should have your local dev version (1.0.1)  
3. **Info.plist**: Should have `$(MARKETING_VERSION)` variables
4. **Build Settings**: Should show same values as General tab

## The Flow:

```
Local Dev: General Tab Values → Info.plist Variables → App
CI Build:  xcodebuild Override → Info.plist Variables → App
```
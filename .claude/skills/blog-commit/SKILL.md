---
name: verify-before-commit
description: Use when about to commit code to the repository - ensures Eleventy build is passing before allowing commit
---

# Verify Build Before Commit

## Overview

Validation step to ensure Eleventy builds successfully before committing changes. Prevents broken builds from entering the repository.

## When to Use

**Before any `git commit`:**
- You've edited Eleventy config (`.eleventy.js`, `collections.js`)
- You've created or modified blog posts
- You've changed layouts or templates
- You've updated `.mcp.json` or other configuration

**Not needed if:**
- You only changed documentation or non-build files
- You're amending commits (but still verify first)

## Quick Verification

Run before committing:
```bash
npm run verify-build
```

**Success output:**
```
✅ Build successful!

Ready to commit. Staged files:
  src/posts/2026/2026-03-06-example.md
```

**Failure output:**
```
❌ Build failed!

Last 20 lines of build output:
[error details...]

Fix the errors above and try again.
```

## If Build Fails

### Step 1: Read Error Message
The error will tell you exactly what's wrong. Common issues:

**YAML Frontmatter Error**
```
Error: Invalid YAML in 2026-03-06-example.md
  date: should be YYYY-MM-DD
  tags: should be lowercase array
```

**Fix:** Edit the file and correct frontmatter

**Duplicate Export Error**
```
Error: duplicate export const in collections.js line 45
```

**Fix:** Check `.eleventy.js` or `src/_config/*.js` for typos

### Step 2: Clean and Rebuild
```bash
npm run clean
npm run build
```

### Step 3: Verify Homepage
```bash
npm start
# Visit http://localhost:8080 and check:
# - New post appears in "Latest Posts"?
# - No console errors?
```

### Step 4: Commit
```bash
git add .
git commit -m "post: [title]"
npm run verify-build  # Final check
git push
```

## Frontmatter Checklist

Before committing any new post:

- [ ] `title` - not empty
- [ ] `description` - short, one sentence
- [ ] `date` - format YYYY-MM-DD (not future date)
- [ ] `tags` - array format, **all lowercase**
  - ✅ `['claude-code', 'mcp']`
  - ❌ `['Claude Code', 'MCP']`

## Commit Command Sequence

```bash
# 1. Create/edit files
# 2. Stage changes
git add src/posts/2026/2026-03-06-example.md

# 3. Verify build
npm run verify-build

# 4. If successful, commit
git commit -m "post: Example Article"

# 5. Push
git push origin main
```

## Red Flags - Don't Commit If:

- ❌ Build returns non-zero exit code
- ❌ Homepage doesn't show new post after build
- ❌ YAML frontmatter has syntax errors
- ❌ Tags have mixed case (not all lowercase)
- ❌ Date is in future (posts won't publish)

## Troubleshooting

**"Build successful" but post not on homepage:**
1. Restart dev server: `npm start`
2. Force refresh: Ctrl+Shift+R
3. Check frontmatter date is not in future
4. Verify tags are all lowercase

**"Build failed" but you can't find the error:**
1. Run: `npm run clean && npm run build`
2. Read ENTIRE output, not just the end
3. Check line numbers mentioned in error
4. Check syntax in that specific file

**Want to bypass verification (not recommended):**
```bash
git commit --no-verify
```

**But why?** Bypassing prevents catching errors early. Better to fix now than debug in production.

---

**Always verify before committing.** It takes 10 seconds and prevents broken deployments.

---
name: publish-blog-post
description: Use when creating and publishing new blog posts to ideep.cc, after content is written, before verifying homepage visibility
---

# Publish Blog Post

## Overview

End-to-end blog publishing workflow for ideep.cc. Automates file creation, cache clearing, build verification, and homepage visibility check.

## When to Use

**Triggering conditions:**
- You have written blog content (title, description, date, tags)
- Article needs to appear on homepage "Latest Posts"
- Want to verify successful publication before pushing

**Not for:**
- Editing existing posts (use individual edits)
- Drafts (don't publish until ready)

## Preconditions (Before You Start)

- [ ] Eleventy build must be passing (no pre-existing errors)
- [ ] All existing article tags must be lowercase (check against existing posts)
- [ ] Date is not in the future (future-dated posts are hidden)

If build is broken, fix existing issues first before adding new posts.

## Core Workflow

Follow these steps **in strict order**:

### Step 1: Create Markdown File
Create `src/posts/2026/YYYY-MM-DD-[slug].md` with YAML frontmatter:
```markdown
---
title: Article Title
description: One-sentence summary for card preview
date: 2026-MM-DD
tags:
  - tag1
  - tag2
---

# Article Title

Article content here...
```

**Critical frontmatter fields:**
- `title` - exact article title
- `description` - short preview (shown on listing pages)
- `date` - in YYYY-MM-DD format (YYYY-MM-DD, not any other format)
- `tags` - array format, **MUST BE LOWERCASE** (e.g., `claude-code` not `Claude Code`)
  - Tag slug conflicts happen when tags differ only in case
  - Always use lowercase to avoid Eleventy slug collision errors

### Step 2: Clear Cache (REQUIRED)
```bash
npm run clean
```

**Why:** Eleventy caches collections. Without cleaning, new posts won't appear in `collections.allPosts`.

### Step 3: Verify Build
```bash
npm run build
```

**Success criteria:**
- Return code is 0
- No errors in output
- Build completes with "Wrote X files"

**If build fails:** Read error messages carefully. Common issues:
- Duplicate export in config files
- Malformed YAML frontmatter
- Invalid date format

### Step 4: Verify Homepage Visibility

Start development server:
```bash
npm start
```

Visit these URLs to confirm article appears:
- `http://localhost:8080/` → Check "Latest Posts" section (should show new article)
- `http://localhost:8080/blog/` → Check article appears in list
- `http://localhost:8080/blog/[slug]/` → Direct access should work

**Acceptance criteria:**
- ✅ Homepage shows article in "Latest Posts" with title + description
- ✅ `/blog/` listing page shows article
- ✅ Direct article URL loads without errors

### Step 5: Commit and Push
```bash
git add src/posts/2026/[filename].md
git commit -m "post: [Article Title]"
git push origin main
```

## Quick Reference

| Step | Command | Verify |
|------|---------|--------|
| 1 | Create file | File exists at correct path |
| 2 | `npm run clean` | No errors |
| 3 | `npm run build` | Return code 0, files written |
| 4 | `npm start` | Homepage shows new post |
| 5 | Git push | Commit appears in log |

## Common Mistakes

**❌ Skipping `npm run clean`**
- New posts won't appear on homepage
- Collection cache is stale
- **Fix:** Always run clean before build

**❌ Only checking `/blog/[slug]/ page directly**
- Post might exist but not be in collections
- Homepage visibility won't work
- **Fix:** Verify homepage AND listing page

**❌ Publishing with bad frontmatter**
- Missing `date` field = article not published
- `date` not in YYYY-MM-DD format = build error
- Tags with mixed case = slug collision error (e.g., `["Claude Code", "claude-code"]` creates conflict)
- **Fix:** Validate frontmatter before creating file, use lowercase for all tags

**❌ Forgetting to verify homepage**
- Post created but not visible to users
- Cache issue goes undetected until production
- **Fix:** Always check homepage in step 4

## Red Flags - STOP and Fix First

- Build command returns non-zero code → Fix errors before pushing
- Homepage doesn't show article after 5 sec reload → Run clean + build again
- New post doesn't appear in `/blog/` listing → Collection issue, don't push
- YAML frontmatter has syntax errors → Fix before proceeding

## Troubleshooting

**Article created but not on homepage:**
1. Check that date is not in future format
2. Run `npm run clean` again
3. Run `npm run build` again
4. Restart `npm start`
5. Force refresh browser (Ctrl+Shift+R)
6. Check frontmatter syntax (YAML indentation, date format)

**Build fails with "duplicate export" error or slug collision:**
1. Check new article tags - are they lowercase?
2. Check existing articles - do any have the same tag with different casing?
3. Unify all tags to lowercase format
4. For other errors: Check `src/_config/*.js` for typos, double semicolons, missing imports
5. Read full error message for line number and file

**Homepage shows old articles only:**
1. Verify new file was created in correct directory
2. Verify frontmatter `date` is in YYYY-MM-DD format
3. Check that `date` is not in future (posts with future dates are hidden)

---

**Always complete all 5 steps.** Partial publication = broken workflow.


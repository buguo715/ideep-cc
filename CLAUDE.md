# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **ideep.cc**, a personal website built with Eleventy (11ty) following the workflow from [buildexcellentwebsit.es](https://buildexcellentwebsit.es). It uses CUBE CSS methodology, design tokens, Tailwind CSS for utilities, and esbuild for JavaScript bundling.

## Tech Stack

- **Static Site Generator**: Eleventy v3.1.2 (Nunjucks templates)
- **CSS**: Tailwind CSS v3.4.17 with CUBE CSS architecture
- **JavaScript**: Minimal, modular with esbuild bundling
- **PostCSS**: Import, Autoprefixer, CSSNano for optimization

## Development Commands

| Command | Description |
|---------|-------------|
| `npm start` | Run dev server with live reload |
| `npm run dev:11ty` | Run Eleventy in development mode |
| `npm run build` | Build production assets (CSS, JS) and render pages |
| `npm run clean` | Remove generated files (dist, CSS, JS includes) |
| `npm run pa11y:test` | Run accessibility tests |

## Project Structure

```
src/
├── _config/          # Eleventy config (collections, filters, plugins, shortcodes)
├── _data/            # Dynamic data (meta.js, designTokens/, navigation.js)
├── _includes/        # Reusable partials (CSS, scripts, webc components)
├── _layouts/         # Base, page, post, tags layouts
├── assets/           # Source assets
│   ├── css/          # CUBE CSS structure (base/blocks/compositions/utilities)
│   ├── scripts/      # JavaScript (bundle/, components/)
│   ├── svg/          # SVG sprites
│   └── images/       # Static images
├── common/           # Shared pages (404, sitemap.xml, feed.xml, robots.txt)
└── posts/            # Blog posts (year-structured markdown files)

dist/                 # Generated output
```

## CUBE CSS Architecture

The project follows [CUBE CSS](https://web-cube.dev/) methodology:

- **Base**: CSS resets, fonts, design tokens, global styles
- **Blocks**: Standalone components (button, code, nav, prose)
- **Compositions**: Layout patterns (flow, grid, wrapper, sidebar)
- **Utilities**: Small single-purpose classes

## Build Process

1. **CSS**: Tailwind processes `src/assets/css/global/global.css` → `src/_includes/css/global.css`
2. **JS**: esbuild bundles scripts → `src/_includes/scripts/` (inline) or `dist/assets/scripts/` (components)
3. **Images**: eleventy-image-transformPlugin generates responsive images
4. **Render**: Eleventy renders templates with data/filters/shortcodes

## Key Configuration

- **URL**: Set via `URL` environment variable (default: `https://ideep.cc`)
- **Design Tokens**: JSON files in `src/_data/designTokens/` drive Tailwind config
- **Markdown**: Custom markdown-it setup with Prism syntax highlighting, emoji, footnotes

## Environment Variables

Copy `.env-sample` to `.env` and set `URL` for local development.

## Layout System

- Inheritance chain: `base.njk` → `page.njk` / `post.njk` / `tags.njk`
- WebC components: `src/_includes/webc/` (custom-card, custom-masonry, custom-youtube, custom-svg, etc.)

## Collections

- `allPosts` — all blog posts, reversed chronologically
- `showInSitemap` — all .md/.njk pages for sitemap
- `tagList` — all unique tags (excluding 'posts', 'docs', 'all')

## Gotchas

- After adding new posts/pages, run `npm run clean` then `npm start` to avoid Eleventy collection cache issues
- Design tokens in `src/_data/designTokens/*.json` → auto-converted to Tailwind config via `src/_config/utils/tokens-to-tailwind.js`

## Deployment

The site deploys via GitHub Actions (`.github/workflows/deploy.yml`) to an SSH-accessible server at `/var/www/ideep.cc`.

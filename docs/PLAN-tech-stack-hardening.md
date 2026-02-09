# Plan: Harden Technology References for Multi-Session Development

## Context

The project was planned in December 2025 targeting Next.js 14+, React 18, Tailwind v3, and `@supabase/auth-helpers-nextjs`. As of February 2026, all of these are outdated or deprecated. Since no code exists yet (only `.gitkeep` placeholders), this is the ideal moment to update all "source of truth" files before implementation begins.

The goal is to ensure that **any future Claude Code session** immediately has correct technology context from the first moment, with no risk of implementing against deprecated packages.

---

## Changes

### Step 1: Create `docs/TECH_STACK.md` (NEW FILE)

The canonical, single source of truth for all technology decisions. Contains:

- **Quick reference table** with exact packages and versions (Next.js 16, React 19, Tailwind v4, `@supabase/ssr`, shadcn/ui, tw-animate-css, zod, react-hook-form)
- **DEPRECATED -- DO NOT USE table** listing old packages/patterns and their replacements (`@supabase/auth-helpers-nextjs`, `tailwind.config.ts`, `tailwindcss-animate`, `middleware.ts` for routing, `next.config.js`)
- **Next.js 16 key changes** section: `proxy.ts` replaces `middleware.ts`, Turbopack default, async request APIs mandatory, `use cache` directive, `next.config.ts`
- **Tailwind v4 key changes** section: CSS-first config via `@theme` directive, `@import "tailwindcss"`, automatic content detection, example `globals.css`
- **Supabase SSR integration** section: import patterns for all four client files (`createBrowserClient` / `createServerClient` from `@supabase/ssr`, `createClient` from `@supabase/supabase-js` for admin)
- **shadcn/ui with Tailwind v4** section: init command, tw-animate-css, CSS variable theming
- **Fallback note**: If `proxy.ts` is unavailable in the installed Next.js version, fall back to `middleware.ts` with the same logic

### Step 2: Update `CLAUDE.md`

Surgical changes to the file that loads into every session's system prompt:

1. **Line 18 (Project Overview)**: `Next.js 14+` -> `Next.js 16`, add `React 19`, add `Tailwind CSS v4`
2. **New section after Project Overview**: "Technology Stack (CRITICAL)" with a compact "Use This / NOT This" table referencing `docs/TECH_STACK.md` as mandatory reading
3. **Line ~69 (Directory Structure)**: `middleware.ts` -> `proxy.ts` in supabase clients listing
4. **Line ~99 (Middleware Protection)**: Rename to "Proxy-Based Protection", reference `proxy.ts`
5. **Line ~108 (Supabase Client Usage table)**: `lib/supabase/middleware.ts` -> `lib/supabase/proxy.ts`
6. **After Admin API Pattern section**: Add "Supabase Client Pattern" showing correct `@supabase/ssr` imports

### Step 3: Update `.taskmaster/tasks/tasks.json`

Update task `title` and `details` fields for tasks 1, 2, 3, 4, and 9:

- **Task 1**: Title `Next.js 14+` -> `Next.js 16`. Details: replace `@supabase/auth-helpers-nextjs` with `@supabase/ssr`, `next.config.js` with `next.config.ts`, `tailwind.config.ts` with CSS `@theme` directive, add shadcn/ui + tw-animate-css, add "Refer to docs/TECH_STACK.md"
- **Task 2**: Details: `middleware` client -> `proxy` client, specify `@supabase/ssr` for client/server/proxy and `@supabase/supabase-js` for admin, add TECH_STACK.md reference
- **Task 3**: Details: `middleware.ts` -> `proxy.ts`, add `@supabase/ssr` pattern note
- **Task 4**: Details: `middleware.ts` -> `proxy.ts`
- **Task 9**: Details: add note about Next.js 16 mandatory async request APIs

### Step 4: Update `docs/PRD.md` (minimal)

Add deprecation notices rather than rewriting the document:

1. Before the "Recommended Technology Stack" box (~line 110): Add a callout noting the stack has been updated, pointing to `docs/TECH_STACK.md`
2. In Session Management (~line 183): "Supabase Auth Helpers" -> "`@supabase/ssr`"
3. Before Appendix A Next.js rationale (~line 1626): Add note that project now targets Next.js 16
4. Before "Project Structure" section (~line 895): Add note pointing to TECH_STACK.md for current file naming

### Step 5: Sync `.taskmaster/docs/prd.txt`

Copy `docs/PRD.md` to `.taskmaster/docs/prd.txt` after PRD edits are applied.

### Step 6: Commit

Single commit with all changes.

---

## Files Modified

| File | Action |
|------|--------|
| `docs/TECH_STACK.md` | CREATE -- canonical technology reference |
| `CLAUDE.md` | EDIT -- version updates, new tech stack section, proxy.ts refs |
| `.taskmaster/tasks/tasks.json` | EDIT -- tasks 1, 2, 3, 4, 9 details/title |
| `docs/PRD.md` | EDIT -- 4 deprecation notices pointing to TECH_STACK.md |
| `.taskmaster/docs/prd.txt` | OVERWRITE -- re-sync with updated PRD.md |

---

## Verification

After all changes, grep the repo to confirm:
- Zero occurrences of `Next.js 14` in CLAUDE.md and tasks.json
- Zero occurrences of `auth-helpers-nextjs` in CLAUDE.md and tasks.json (only in TECH_STACK.md "DO NOT USE" section and PRD.md deprecation note)
- Zero occurrences of `tailwind.config.ts` in CLAUDE.md and tasks.json (only in "DO NOT USE" sections)
- Zero occurrences of `middleware.ts` as a route protection reference in CLAUDE.md and tasks.json
- `docs/TECH_STACK.md` is referenced from both CLAUDE.md and PRD.md
- `.taskmaster/docs/prd.txt` content matches `docs/PRD.md`

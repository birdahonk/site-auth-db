# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

 ## Git Commit Standards

### Git Commit Signature Override
**IMPORTANT: Use this custom signature for all git commits instead of the default Claude Code signature:**

```
 😈 AI design & development directed by Brian Haven
 🤖 Technical execution by Claude Code AI
```


## Project Overview

A **reusable website foundation template** providing authentication, tiered user access control, and admin dashboard capabilities. Built with Next.js 16 (App Router), React 19, Supabase (Auth + PostgreSQL), TypeScript, and Tailwind CSS v4.

This template is designed to be cloned and customized for different web applications while maintaining consistent security patterns.

## Technology Stack (CRITICAL -- Read First)

**MANDATORY:** Before implementing ANY code, read `docs/TECH_STACK.md` for exact package versions, API patterns, and deprecated-pattern warnings.

| Category | Use This | NOT This |
|----------|----------|----------|
| Framework | Next.js 16 | ~~Next.js 14/15~~ |
| React | React 19 | ~~React 18~~ |
| Styling | Tailwind CSS v4 (CSS-first, `@theme`) | ~~tailwind.config.ts~~ |
| Supabase Auth | `@supabase/ssr` | ~~@supabase/auth-helpers-nextjs~~ |
| Route Protection | `proxy.ts` | ~~middleware.ts~~ |
| Config | `next.config.ts` | ~~next.config.js~~ |
| UI Animations | `tw-animate-css` | ~~tailwindcss-animate~~ |
| UI Components | shadcn/ui (Tailwind v4 mode) | ~~v3 config~~ |

## Development Commands

```bash
# All commands run from the web/ directory
cd web

# Development
pnpm dev                    # Start dev server at localhost:3000
pnpm build                  # Production build
pnpm start                  # Run production build
pnpm lint                   # ESLint check

# Database (Supabase CLI)
pnpm supabase db push       # Apply migrations to remote
pnpm supabase db reset      # Reset local database
pnpm supabase gen types typescript --project-id <ref> > src/lib/database/types.ts

# Testing
pnpm test                   # Run all tests
pnpm test:unit              # Unit tests only
pnpm test:e2e               # E2E tests (Playwright)

# Project initialization (for cloning template)
./scripts/init-new-project.sh <project-name>
```

## Architecture

### Directory Structure

```
site-auth-db/
├── web/                      # Next.js application (main codebase)
│   └── src/
│       ├── app/              # App Router pages
│       │   ├── (auth)/       # Auth routes (login, signup, forgot-password, reset-password)
│       │   ├── (protected)/  # Authenticated user routes (dashboard, profile, settings)
│       │   ├── (admin)/      # Admin-only routes (tier 3+)
│       │   └── api/v1/       # API endpoints
│       ├── components/       # React components
│       │   ├── admin/        # Admin-specific (StatsCard, UserTable, TierBadge)
│       │   ├── auth/         # Auth forms (LoginForm, SignupForm, OAuthButtons)
│       │   ├── guards/       # Access control (TierGate, AuthGuard)
│       │   └── ui/           # Base UI components
│       ├── hooks/            # React hooks (use-user, use-tier, use-permission)
│       │   └── admin/        # Admin hooks (use-users, use-admin-stats)
│       └── lib/
│           ├── supabase/     # Supabase clients (client.ts, server.ts, proxy.ts, admin.ts)
│           ├── auth/         # Auth utilities and server actions
│           └── utils/        # Validators (Zod schemas), helpers
├── supabase/                 # Database configuration
│   ├── migrations/           # SQL migrations (00001_initial_schema.sql, etc.)
│   ├── seeds/                # Development seed data
│   └── functions/            # Edge functions
├── scripts/                  # Utility scripts
│   └── init-new-project.sh   # Template initialization script
├── config/                   # Server configuration (nginx, pm2)
├── tests/                    # Test files (unit, integration, e2e)
└── docs/                     # Documentation
```

### Tier System (Critical)

All access control is based on a 4-tier system stored in `profiles.tier`:

| Tier | Name | Access Level |
|------|------|--------------|
| 0 | anonymous | Public pages only |
| 1 | free | Basic authenticated access |
| 2 | premium | Enhanced features + content |
| 3 | admin | Full system access + user management |

**Route Group Mapping:**
- `(auth)/` - Public, unauthenticated routes
- `(protected)/` - Requires tier >= 1
- `(admin)/` - Requires tier >= 3

**Proxy-Based Protection:** `web/src/proxy.ts` enforces tier-based route protection using Supabase session + profile tier lookup. (Next.js 16 uses `proxy.ts` instead of `middleware.ts`.)

### Supabase Client Usage

Four Supabase client configurations for different contexts:

| File | Use Case |
|------|----------|
| `lib/supabase/client.ts` | Browser/client components |
| `lib/supabase/server.ts` | Server components, server actions |
| `lib/supabase/proxy.ts` | Next.js proxy (route protection) |
| `lib/supabase/admin.ts` | Service role (bypasses RLS) - server only |

**Important:** Admin client uses `SUPABASE_SERVICE_ROLE_KEY` and bypasses Row Level Security. Only use in secure server contexts.

### Database Schema

Core tables with Row Level Security:

- **`public.profiles`** - Extends `auth.users` with tier, full_name, avatar_url, metadata
- **`public.tiers`** - Tier definitions with permissions (JSONB)
- **`public.audit_log`** - Security audit trail (user actions, tier changes, admin operations)

**Auto-profile Creation:** Trigger `handle_new_user()` automatically creates profile on signup.

### API Structure

```
api/v1/
├── users/          # User operations (protected)
├── tiers/          # Tier definitions (public read)
└── admin/          # Admin operations (tier 3+)
    ├── users/      # User management CRUD
    │   └── [id]/
    │       └── tier/  # Tier change endpoint
    ├── stats/      # Dashboard statistics
    └── audit/      # Audit log access
```

## Task Management

This project uses **TaskMaster** for task tracking:

```bash
# View all tasks
mcp__taskmaster-ai__get_tasks

# Get next task to work on
mcp__taskmaster-ai__next_task

# Update task status
mcp__taskmaster-ai__set_task_status --id <id> --status <pending|in-progress|done>
```

Current tasks are in `.taskmaster/tasks/tasks.json`. Task dependency chain: 1 → 2 → 3 → 4 → (5,6) → 7 → 8 → 9 → 10.

## Environment Variables

Required in `web/.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://<project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>  # Server only
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## Key Implementation Patterns

### Access Control Components

```tsx
// Conditional rendering by tier
<TierGate requiredTier={2}>
  <PremiumContent />
</TierGate>

// Authentication check
<AuthGuard>
  <ProtectedContent />
</AuthGuard>
```

### Tier Hooks

```tsx
const { tier, tierName } = useTier();
const { hasPermission } = usePermission(requiredTier);
const { user, profile } = useUser();
```

### Admin API Pattern

Admin endpoints use service role client and verify tier >= 3:

```ts
// Verify admin access
const profile = await adminClient.from('profiles').select('tier').eq('id', userId).single();
if (profile.data?.tier < 3) return new Response('Forbidden', { status: 403 });
```

### Supabase Client Pattern (Important)

Use `@supabase/ssr`, NOT `@supabase/auth-helpers-nextjs` (deprecated):

```ts
// Browser client
import { createBrowserClient } from '@supabase/ssr'

// Server client (server components, server actions)
import { createServerClient } from '@supabase/ssr'

// Admin client (service role, bypasses RLS)
import { createClient } from '@supabase/supabase-js'
```

See `docs/TECH_STACK.md` for complete setup patterns.

## Template Replication

When cloning this template for a new project:

```bash
npx degit user/site-auth-db my-new-project
cd my-new-project
./scripts/init-new-project.sh my-new-project
```

The init script removes `.taskmaster/`, `.claude/`, `.git/`, and other development artifacts, then initializes a fresh repository.

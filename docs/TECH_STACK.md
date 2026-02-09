# Technology Stack Reference

**Last Updated:** 2026-02-08
**Status:** Authoritative -- all implementation MUST follow this document

---

## Quick Reference Table

| Category | Package / Tool | Version | Notes |
|----------|---------------|---------|-------|
| Framework | Next.js | 16 | App Router, Turbopack default |
| React | React | 19 | |
| Styling | Tailwind CSS | 4 | CSS-first config, no tailwind.config.ts |
| UI Components | shadcn/ui | latest | Tailwind v4 compatible |
| Animation | tw-animate-css | latest | Replaces tailwindcss-animate |
| Supabase Client | @supabase/ssr | latest | Replaces deprecated @supabase/auth-helpers-nextjs |
| Supabase JS | @supabase/supabase-js | 2.x | Core Supabase client |
| Validation | zod | latest | |
| Forms | react-hook-form | latest | With @hookform/resolvers |
| Node.js | Node.js | 22 LTS | Required for Next.js 16 |
| Package Manager | pnpm | latest | |

---

## DEPRECATED -- DO NOT USE

| Old Package / Pattern | Replacement | Why |
|----------------------|-------------|-----|
| `@supabase/auth-helpers-nextjs` | `@supabase/ssr` | Deprecated upstream, consolidated into SSR package |
| `tailwind.config.ts` / `tailwind.config.js` | CSS `@theme` directive in globals.css | Tailwind v4 uses CSS-first configuration |
| `tailwindcss-animate` | `tw-animate-css` | Updated for Tailwind v4 compatibility |
| `middleware.ts` (route interception) | `proxy.ts` | Next.js 16 replaces middleware with proxy.ts |
| `next.config.js` | `next.config.ts` | Next.js 16 uses TypeScript config by default |
| `createMiddlewareClient` | `createServerClient` from `@supabase/ssr` | Old auth-helpers API removed |
| React 18 patterns | React 19 (`use`, async server components) | |

---

## Next.js 16 Key Changes

### proxy.ts replaces middleware.ts

- `proxy.ts` at the project root is the primary request interception layer
- Runs on the Node.js runtime (not Edge), making the network boundary explicit
- Turbopack is the default bundler for both dev and production (no opt-in needed)
- Async request APIs are **mandatory**: `cookies()`, `headers()`, `params`, `searchParams` must all be `await`ed
- The `use cache` directive replaces `unstable_cache` and many `revalidate` patterns
- Config file is `next.config.ts` (TypeScript), not `next.config.js`

### Route Protection Pattern

```
proxy.ts (root)
  └── Reads Supabase session via @supabase/ssr createServerClient
  └── Checks profile tier from session
  └── Redirects or allows based on route group:
        (auth)/*       → public, redirect to dashboard if already logged in
        (protected)/*  → requires tier >= 1
        (admin)/*      → requires tier >= 3
```

### Async Request API Example

```ts
// Next.js 16 -- ALL request APIs must be awaited
export default async function Page({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>
  searchParams: Promise<{ query: string }>
}) {
  const { id } = await params
  const { query } = await searchParams
  const cookieStore = await cookies()
  const headersList = await headers()
}
```

**Fallback:** If `proxy.ts` is unavailable or unstable in the installed Next.js version, fall back to `middleware.ts` with the same logic. Check the Next.js 16 release notes.

---

## Tailwind CSS v4 Key Changes

### CSS-First Configuration

- **No `tailwind.config.ts` or `tailwind.config.js` file**
- All theme customization via `@theme` directive in CSS
- Automatic content detection (no `content` array needed)
- Import Tailwind via `@import "tailwindcss"` in globals.css

### Example globals.css

```css
@import "tailwindcss";
@import "tw-animate-css";

@theme {
  --color-background: oklch(1 0 0);
  --color-foreground: oklch(0.141 0.005 285.823);
  --color-primary: oklch(0.21 0.006 285.885);
  --color-primary-foreground: oklch(0.985 0.002 247.839);
  --font-sans: "Inter", ui-sans-serif, system-ui, sans-serif;
  --radius-lg: 0.5rem;
  --radius-md: calc(var(--radius-lg) - 2px);
  --radius-sm: calc(var(--radius-lg) - 4px);
}
```

---

## Supabase SSR Integration (`@supabase/ssr`)

### Client Configuration Pattern

Four client files, updated imports:

| File | Function | Package |
|------|----------|---------|
| `lib/supabase/client.ts` | `createBrowserClient` | `@supabase/ssr` |
| `lib/supabase/server.ts` | `createServerClient` | `@supabase/ssr` (with cookie handlers) |
| `lib/supabase/proxy.ts` | `createServerClient` | `@supabase/ssr` (with request/response) |
| `lib/supabase/admin.ts` | `createClient` | `@supabase/supabase-js` (service role) |

### Browser Client Example

```ts
// lib/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Server Client Example

```ts
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // Called from Server Component -- ignore
          }
        },
      },
    }
  )
}
```

### Admin Client Example

```ts
// lib/supabase/admin.ts
import { createClient } from '@supabase/supabase-js'

export const adminClient = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)
```

### Session Refresh in proxy.ts

```ts
// proxy.ts (project root)
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => {
            request.cookies.set(name, value)
            response.cookies.set(name, value, options)
          })
        },
      },
    }
  )

  // Refresh session -- IMPORTANT: must be called
  const { data: { user } } = await supabase.auth.getUser()

  // Tier-based route protection logic here...

  return response
}
```

---

## shadcn/ui with Tailwind v4

- Initialize: `npx shadcn@latest init` (select Tailwind v4 mode)
- Uses `tw-animate-css` instead of `tailwindcss-animate`
- CSS variables for theming via `@theme` directive
- Add components: `npx shadcn@latest add button card input`
- All components have `data-slot` attributes for styling
- Colors use OKLCH color space

---

## Version History

| Date | Change |
|------|--------|
| 2026-02-08 | Initial version. Updated from Dec 2025 PRD stack (Next.js 14, React 18, Tailwind v3, auth-helpers) to current stack. |

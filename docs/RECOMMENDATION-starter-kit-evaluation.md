# Starter Kit Evaluation: Build vs Buy

**Date:** February 8, 2026
**Context:** Evaluating whether to continue building site-auth-db from scratch,
or adopt an existing Next.js + Supabase boilerplate.
Deployment target changed from self-hosted VPS to Vercel.

---

## The Goal

When building a new app with Claude Code that needs a web frontend, initialize a
working scaffold — with auth, tiered access, admin dashboard, and production
deployment — in minimal time.

---

## Two Finalists

After surveying the landscape (Open SaaS, ShipFast, Supastarter, create-t3-app,
Clerk starters, Better Auth templates, and others), two options stand out for the
Next.js + Supabase + Tailwind stack:

**Nextbase** — [usenextbase.com](https://www.usenextbase.com/)
- Free version: Yes, MIT licensed — [GitHub](https://github.com/imbhargav5/nextbase-nextjs-supabase-starter)
- Paid tiers: $99 / $299 / $399 (one-time)
- License: Pay once, own forever

**Makerkit** — [makerkit.dev](https://makerkit.dev/)
- Free version: Yes, Lite — [GitHub](https://github.com/makerkit/nextjs-saas-starter-kit-lite)
- Paid tiers: $299 / $599 (one-time, lifetime updates)
- License: Pay once, unlimited projects, lifetime updates

---

## Tech Stack Comparison

Both target the same modern stack. Here's how they line up against the
site-auth-db PRD:

| Requirement                        | Nextbase | Makerkit                    | site-auth-db (planned) |
| ---------------------------------- | -------- | --------------------------- | ---------------------- |
| Next.js 16                         | Yes      | Yes                         | Yes                    |
| React 19                           | Yes      | Yes                         | Yes                    |
| Tailwind CSS v4 (`@theme`)         | Yes      | Yes                         | Yes                    |
| `@supabase/ssr` (not auth-helpers) | Yes      | Yes                         | Yes                    |
| TypeScript strict                  | Yes      | Yes                         | Yes                    |
| shadcn/ui                          | Yes      | Yes (heroicons, not lucide) | Yes                    |
| App Router                         | Yes      | Yes                         | Yes                    |
| `proxy.ts` (not middleware.ts)     | Unclear  | Yes                         | Yes                    |

**Verdict:** All three share the same core stack. No technology advantage to
building custom.

---

## Feature Comparison

### Authentication

| Feature            | Nextbase Free | Nextbase Paid | Makerkit Lite | Makerkit Paid | site-auth-db |
| ------------------ | ------------- | ------------- | ------------- | ------------- | ------------ |
| Email/password     | Yes           | Yes           | Yes           | Yes           | Planned      |
| OAuth (Google, GH) | Yes           | Yes           | Yes           | Yes           | Planned      |
| Magic links        | No            | Yes           | No            | Yes           | Not planned  |
| MFA/TOTP           | No            | Yes           | No            | Yes           | Not planned  |
| Password reset     | Yes           | Yes           | Yes           | Yes           | Planned      |
| Email verification | Yes           | Yes           | Yes           | Yes           | Planned      |
| Identity linking   | No            | Unknown       | No            | Yes           | Not planned  |

### Access Control

| Feature              | Nextbase Free | Nextbase Paid | Makerkit Lite | Makerkit Paid | site-auth-db     |
| -------------------- | ------------- | ------------- | ------------- | ------------- | ---------------- |
| Role-based (RBAC)    | Basic         | Yes           | Basic         | Yes           | Planned (4-tier) |
| Multi-tenancy / orgs | No            | Yes           | No            | Yes           | Not planned      |
| Per-seat billing     | No            | No            | No            | Yes           | Not planned      |
| TierGate component   | No            | Unknown       | No            | Unknown       | Planned          |

### Admin Dashboard

| Feature              | Nextbase Free | Nextbase Paid | Makerkit Lite | Makerkit Paid    | site-auth-db |
| -------------------- | ------------- | ------------- | ------------- | ---------------- | ------------ |
| Admin panel          | No            | Yes           | No            | Yes (Super Admin)| Planned      |
| User management CRUD | No            | Yes           | No            | Yes              | Planned      |
| User impersonation   | No            | Yes           | No            | Yes              | Not planned  |
| Stats/analytics      | No            | Yes           | No            | Yes              | Planned      |
| Audit logging        | No            | Unknown       | No            | Yes              | Planned      |

### Payments & Business

| Feature                 | Nextbase Free | Nextbase Paid | Makerkit Lite | Makerkit Paid | site-auth-db |
| ----------------------- | ------------- | ------------- | ------------- | ------------- | ------------ |
| Stripe integration      | No            | Yes           | No            | Yes           | Not planned  |
| Lemon Squeezy           | No            | Yes           | No            | Yes           | Not planned  |
| Subscription management | No            | Yes           | No            | Yes           | Not planned  |
| Pricing page            | No            | Yes           | No            | Yes           | Not planned  |

### Infrastructure

| Feature              | Nextbase Free      | Nextbase Paid | Makerkit Lite | Makerkit Paid     | site-auth-db     |
| -------------------- | ------------------ | ------------- | ------------- | ----------------- | ---------------- |
| Vercel-optimized     | Yes                | Yes           | Yes           | Yes               | No (VPS-focused) |
| RLS policies         | Basic              | Yes           | Basic         | Yes               | Planned          |
| Database migrations  | Yes                | Yes           | Yes           | Yes (declarative) | Planned          |
| Email system         | No                 | Yes           | No            | Yes               | Not planned      |
| Blog/CMS             | No                 | Unknown       | No            | Yes (Keystatic)   | Not planned      |
| Testing setup        | Vitest + Playwright| Same          | Playwright    | Same              | Planned          |
| Monorepo (Turborepo) | No                 | Unknown       | Yes           | Yes               | No               |

---

## What You Get for Free vs What Costs Money

### Nextbase Free (MIT, open source)

- Next.js 16 + Supabase + Tailwind v4 + shadcn/ui scaffold
- Basic auth (email/password, OAuth)
- TypeScript with Supabase type generation
- Testing setup (Vitest, Playwright)
- SEO tools (sitemap, JSON-LD, Open Graph)
- **No admin dashboard, no RBAC, no payments, no email system**

### Makerkit Lite (free, open source)

- Next.js (15, not yet 16) + Supabase + Tailwind v4 + shadcn/ui
- Monorepo structure (Turborepo)
- Basic auth (email/password, OAuth)
- Profile management, protected routes
- i18n, Zod validation, React Query
- **No admin dashboard, no billing, no orgs, no docs access**

### Nextbase Paid ($99-$399)

- Everything free, plus:
- Admin dashboard with user management
- RBAC + multi-tenancy
- Stripe + Lemon Squeezy payments
- Email templates (React Email)
- At $399 (Ultimate): notifications, blog, feedback system, AI features

### Makerkit Paid ($299)

- Everything lite, plus:
- Super Admin dashboard (user management, impersonation, stats)
- Multi-tenancy with organizations and roles
- Stripe + Lemon Squeezy + Paddle payments
- Transactional emails (Resend/Nodemailer)
- Blog CMS (Keystatic)
- Audit logging
- 400+ pages of documentation
- Lifetime updates (daily improvements)
- Discord community support

---

## Community & Maintenance

|                      | Nextbase                       | Makerkit                                |
| -------------------- | ------------------------------ | --------------------------------------- |
| GitHub stars (free)  | 768                            | 375                                     |
| Last release         | v2.2.0 (Nov 2025)             | Daily updates (Feb 2026)                |
| Discord community    | 176 members (small)            | Active, private threads for Teams       |
| Documentation        | Good, multi-version            | 400+ pages, video courses               |
| Update frequency     | Periodic releases              | Daily pushes                            |
| Known issues         | Small community, newer product | Doc inaccuracies, monorepo learning curve |
| AI tooling support   | Not mentioned                  | MCP server for Claude Code/Cursor       |

**Notable:** Makerkit has an
[MCP server](https://makerkit.dev/blog/tutorials/claude-code-best-practices)
that gives Claude Code access to its component library and patterns. This means
Claude Code can work with Makerkit more effectively than with arbitrary
codebases.

---

## Vercel Deployment (Both Options)

Deploying to Vercel is straightforward with either option:

### Workflow

```
Develop on VPS  →  push to GitHub  →  Vercel auto-deploys
```

1. Connect GitHub repo to Vercel (one-time setup)
2. Every push to `master` triggers a production deploy
3. Every PR gets a preview deployment with a unique URL
4. Supabase env vars auto-populate via Vercel Marketplace integration

### Custom Domain (Pair Networks to Vercel)

At Pair Networks DNS settings, add two records:

| Type  | Host       | Value                  |
| ----- | ---------- | ---------------------- |
| A     | `@` (root) | `76.76.21.21`          |
| CNAME | `www`      | `cname.vercel-dns.com.`|

Vercel provides free automatic SSL via Let's Encrypt. No manual cert management.

### Vercel Free Tier Limits

| Resource                | Free Limit     |
| ----------------------- | -------------- |
| Bandwidth               | 100 GB/month   |
| Serverless invocations  | 150K/month     |
| Build minutes           | 6,000/month    |
| Function timeout        | 60 seconds     |

**Important:** The free Hobby plan is for **personal, non-commercial use only**.
Commercial projects require Pro ($20/month per user).

### Supabase + Vercel Integration

Install "Supabase" from the Vercel Marketplace. It automatically syncs
`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, and
`SUPABASE_SERVICE_ROLE_KEY` to your Vercel project. No manual env var copying.

---

## Honest Assessment: Is site-auth-db Worth Continuing?

### What site-auth-db would give you that these don't

1. **Exact 4-tier system** (anonymous/free/premium/admin) with `TierGate`
   components — both alternatives use generic RBAC, not numbered tiers
2. **VPS deployment configs** (nginx, PM2) — no longer relevant if deploying
   to Vercel
3. **Full ownership with no purchase** — though the free tiers of both
   alternatives are also fully owned

### What these give you that site-auth-db doesn't plan for

1. Payments (Stripe, Lemon Squeezy)
2. Email system (transactional emails, templates)
3. Multi-tenancy / organizations
4. Blog/CMS
5. MFA
6. User impersonation
7. i18n
8. Battle-tested code with real users finding bugs
9. Ongoing maintenance by someone else

### The maintenance problem

The site-auth-db project was planned in Dec 2025 with Next.js 14 and
Tailwind v3. By Feb 2026, the entire tech stack was outdated and required a
full hardening session before any code was even written. This will keep
happening every few months. Makerkit pushes updates daily. Nextbase releases
periodically.

### Time investment

| Approach                          | Estimated time to working scaffold           |
| --------------------------------- | -------------------------------------------- |
| site-auth-db (build from scratch) | 2-4 weeks (10 tasks)                         |
| Nextbase Free + customize         | 2-3 days                                     |
| Nextbase Paid ($99-399)           | 1-2 days                                     |
| Makerkit Lite + customize         | 2-3 days                                     |
| Makerkit Paid ($299)              | 1 day (includes admin, auth, payments)       |

---

## Recommendation

### Best option: Makerkit Paid ($299)

**Why Makerkit over Nextbase:**

1. **Closer stack match** — confirmed Next.js 16, `proxy.ts`, Tailwind v4,
   `@supabase/ssr` with code examples in their docs
2. **More active maintenance** — daily updates vs periodic releases
3. **Better documentation** — 400+ pages, video courses, and a Claude Code
   MCP server
4. **More features included** — admin dashboard, audit logging, payments,
   email, blog all in the $299 tier
5. **Unlimited projects** — use it for every future "I need a web frontend"
   situation
6. **Monorepo structure** — cleaner separation for projects that grow beyond
   a simple frontend

**Why pay $299 vs use a free option:**

The free versions (Nextbase Free, Makerkit Lite) give you auth + basic
scaffold, but you'd still need to build the admin dashboard, RBAC, email
system, and audit logging yourself — which is essentially what site-auth-db
was going to do. For $299, Makerkit's paid tier includes all of that plus
payments, organizations, and daily maintenance. The time savings (weeks of
work vs hours of customization) far exceeds the cost.

**Why not continue site-auth-db:**

The project's entire feature set is a subset of what Makerkit already ships.
The only unique aspect (VPS deployment) is no longer relevant with the switch
to Vercel. Continuing to build it means spending weeks recreating existing,
tested, maintained code.

### Second best: Nextbase Free, upgrade if needed

If you don't want to spend money, start with Nextbase Free. It's MIT-licensed,
same modern stack, and gives you a working auth scaffold. Build the admin
dashboard and tier system on top of it. Upgrade to paid ($99 Essential) if you
later need payments or advanced features.

### What to do with site-auth-db

- Keep the repo as an architecture reference (the PRD, tier system design,
  and RLS policies are well-thought-out)
- The `supabase/migrations/` SQL schemas could be reused in any starter
- The `init-new-project.sh` pattern could be adapted for your Makerkit fork
- Archive the repo rather than delete it

---

## Next Steps If Going with Makerkit

1. **Try the free Lite version first** —
   [github.com/makerkit/nextjs-saas-starter-kit-lite](https://github.com/makerkit/nextjs-saas-starter-kit-lite)
2. Review the architecture, run it locally, see if the patterns feel right
3. If satisfied, purchase Pro ($299) at [makerkit.dev](https://makerkit.dev/)
4. Clone the private repo, set up Supabase + Vercel integration
5. Customize: strip features you don't need, add your 4-tier system if the
   built-in RBAC doesn't cover it
6. Point your Pair Networks domain to Vercel
7. You now have a reusable template you can clone for every future project,
   maintained by someone else

---

## Sources

### Nextbase

- [Nextbase Website](https://www.usenextbase.com/)
- [Nextbase GitHub (Free)](https://github.com/imbhargav5/nextbase-nextjs-supabase-starter)
- [Nextbase Pricing](https://www.usenextbase.com/pricing)
- [Nextbase Documentation](https://www.usenextbase.com/docs)
- [Nextbase Discord](https://discord.com/invite/RxNDVewS74)

### Makerkit

- [Makerkit Website](https://makerkit.dev/)
- [Makerkit Lite (Free)](https://github.com/makerkit/nextjs-saas-starter-kit-lite)
- [Makerkit Next.js Supabase Docs](https://makerkit.dev/docs/next-supabase-turbo)
- [Makerkit Changelog](https://makerkit.dev/changelog)
- [Makerkit Vercel Deploy Guide](https://makerkit.dev/docs/next-supabase-turbo/going-to-production/vercel)
- [Makerkit RLS Documentation](https://makerkit.dev/docs/next-supabase-turbo/security/row-level-security)
- [Makerkit Super Admin](https://makerkit.dev/blog/changelog/super-admin)
- [Makerkit Claude Code Best Practices](https://makerkit.dev/blog/tutorials/claude-code-best-practices)
- [Makerkit CLI](https://github.com/makerkit/cli)

### Vercel Deployment

- [Vercel Git Integration](https://vercel.com/docs/git)
- [Vercel Custom Domains](https://vercel.com/docs/domains/working-with-domains/add-a-domain)
- [Vercel DNS Records](https://vercel.com/kb/guide/a-record-and-caa-with-vercel)
- [Vercel Pricing](https://vercel.com/pricing)
- [Vercel Environment Variables](https://vercel.com/docs/environment-variables)
- [Vercel SSL Certificates](https://vercel.com/docs/domains/working-with-ssl)

### Supabase + Vercel

- [Supabase Vercel Marketplace Integration](https://vercel.com/marketplace/supabase)
- [Supabase Vercel Integration Docs](https://supabase.com/docs/guides/integrations/vercel-marketplace)

### Pair Networks

- [Pair Networks DNS Overview](https://www.pair.com/support/kb/dns-records-overview/)
- [Pair Networks DNS Settings Location](https://www.pair.com/support/kb/where-do-i-change-dns-settings/)

### Comparisons

- [Nextbase vs Makerkit](https://www.saashub.com/compare-nextbase-vs-makerkit-dev)
- [SaaS Boilerplate Comparison](https://rafael-padovani.medium.com/i-compared-the-top-saas-boilerplates-heres-what-i-discovered-ee52a88b45c4)
- [Best SaaS Stack 2026](https://supastarter.dev/blog/best-saas-stack)

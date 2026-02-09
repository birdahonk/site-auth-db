# Makerkit Setup Checklist

Step-by-step guide to go from zero to a deployed web app using Makerkit,
Supabase, Vercel, and a custom domain from Pair Networks.

Prefers CLI and MCP tools over browser dashboards so that Claude Code can
assist with most steps directly from the terminal.

---

## Phase 1: Accounts & Prerequisites

### Accounts to Create (browser required)

- [ ] **GitHub** account — [github.com](https://github.com/)
- [ ] **Supabase** account — [supabase.com](https://supabase.com/) (free tier)
- [ ] **Vercel** account — [vercel.com](https://vercel.com/) (free Hobby tier)
  - Sign up with your GitHub account for seamless integration
- [ ] **Makerkit** purchase — [makerkit.dev](https://makerkit.dev/) ($299 Pro)
  - After purchase, you get access to a private GitHub repository

### CLI Tools to Install

```bash
# Node.js 22+ (via nvm — install nvm first if not present)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
node --version  # verify 22.x+

# pnpm (package manager)
npm install -g pnpm
pnpm --version  # verify installed

# GitHub CLI (for repo creation, PRs, issues from terminal)
# Debian/Ubuntu:
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh -y
gh auth login  # follow prompts to authenticate

# Supabase CLI
pnpm install -g supabase
supabase --version  # verify installed
supabase login      # authenticate with access token from supabase.com/dashboard/account/tokens

# Vercel CLI
pnpm install -g vercel
vercel --version  # verify installed
vercel login      # authenticate via browser or token

# Makerkit CLI
# No global install needed — runs via npx:
#   npx @makerkit/cli@latest new
# Requires SSH keys configured for GitHub (see below)
```

### SSH Keys for GitHub (required by Makerkit CLI)

```bash
# Check for existing SSH key
ls -la ~/.ssh/id_ed25519.pub 2>/dev/null

# If none exists, generate one:
ssh-keygen -t ed25519 -C "your-email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy the public key:
cat ~/.ssh/id_ed25519.pub
# Then add it at: github.com > Settings > SSH and GPG keys > New SSH key

# Verify connection:
ssh -T git@github.com
```

### Claude Code MCP Servers

These MCP servers allow Claude Code to interact with services directly:

- [ ] **Supabase MCP** — manage projects, run SQL, apply migrations, deploy
      edge functions without leaving the terminal. Should already be configured
      if listed in your Claude Code MCP settings.
- [ ] **Playwright MCP** — for automated browser testing of the deployed app.
      Useful in Phase 8 verification.

Check available MCPs with Claude Code: just ask "list my MCP servers" or check
`~/.claude/` configuration files.

---

## Phase 2: Evaluate with the Free Lite Version (Optional)

Do this before spending $299 to make sure Makerkit's architecture feels right.

```bash
git clone https://github.com/makerkit/nextjs-saas-starter-kit-lite.git
cd nextjs-saas-starter-kit-lite
pnpm install
pnpm dev
```

- [ ] Review the monorepo structure (`apps/web/`, `packages/`)
- [ ] Open `http://localhost:3000` and explore
- [ ] Check that you're comfortable with the Turborepo monorepo pattern
- [ ] Decision: proceed with purchase, or reconsider

---

## Phase 3: Supabase Project Setup

### Create Project via CLI

```bash
# List your organizations
supabase orgs list

# Create a new project (interactive — prompts for name, password, region)
supabase projects create --org-id <org-id>

# Or via Supabase MCP in Claude Code:
#   mcp__supabase__create_project
```

- [ ] Note the project ref ID from the output
- [ ] Set a strong database password — **save this somewhere secure**

### Get API Keys via CLI

```bash
# Get project URL and anon key
supabase projects api-keys --project-ref <project-ref>

# Or via Supabase MCP:
#   mcp__supabase__get_project_url
#   mcp__supabase__get_anon_key
```

- [ ] Save these values (you'll need them in Phase 4):
  - [ ] `Project URL` (e.g., `https://abcdefg.supabase.co`)
  - [ ] `anon` public key
  - [ ] `service_role` secret key — **never expose client-side**

### Configure Auth Providers

Auth provider configuration requires the Supabase dashboard (no CLI support):

- [ ] Go to **Authentication > Providers** at
      `https://supabase.com/dashboard/project/<ref>/auth/providers`
- [ ] **Email**: Enabled by default
  - [ ] Set "Confirm email" to ON
  - [ ] Set Site URL to `http://localhost:3000`
- [ ] **Google OAuth** (optional):
  - [ ] Create OAuth credentials at
        [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
  - [ ] Add client ID and secret to Supabase
  - [ ] Add redirect URL:
        `https://<project-ref>.supabase.co/auth/v1/callback`
- [ ] **GitHub OAuth** (optional):
  - [ ] Create OAuth app at GitHub > Settings > Developer Settings
  - [ ] Add client ID and secret to Supabase

### Configure Redirect URLs

- [ ] Go to **Authentication > URL Configuration**
- [ ] Add redirect URLs:
  - [ ] `http://localhost:3000/auth/callback` (local dev)
  - [ ] `https://yourdomain.com/auth/callback` (production — add later)
  - [ ] `https://*-yourproject.vercel.app/auth/callback` (Vercel previews)

---

## Phase 4: Makerkit Project Setup

### Clone and Install

```bash
# Option A: Makerkit CLI (recommended)
npx @makerkit/cli@latest new
# Prompts: select Next.js Supabase kit, enter project name
# Requires SSH access to GitHub

# Option B: manual clone of the private repo
git clone git@github.com:makerkit/<your-private-repo>.git my-project
cd my-project
pnpm install
```

### Configure Environment Variables

```bash
cd my-project
cp apps/web/.env.example apps/web/.env.local

# Edit with your Supabase credentials:
# NEXT_PUBLIC_SUPABASE_URL=https://abcdefg.supabase.co
# NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
# SUPABASE_SERVICE_ROLE_KEY=eyJ...
# NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

- [ ] Fill in all required env vars per Makerkit docs

### Link Supabase Project

```bash
# Link your remote Supabase project to this codebase
supabase link --project-ref <project-ref>
```

### Run Local Supabase (for development)

```bash
# Start local Supabase (requires Docker)
pnpm supabase start

# Apply database migrations to remote
pnpm supabase db push

# Or apply via Supabase MCP:
#   mcp__supabase__apply_migration
```

- [ ] Verify tables created: `supabase status` shows local URLs including
      Studio at `localhost:54323`

### Verify Local Dev

```bash
pnpm dev
```

- [ ] Open `http://localhost:3000`
- [ ] Test signup with email/password
- [ ] Test login
- [ ] Verify protected routes redirect unauthenticated users
- [ ] Check admin panel works (if applicable)

---

## Phase 5: Push to GitHub

```bash
# Create a private repo via GitHub CLI
gh repo create your-project --private --source=. --push

# Or if you already have a remote:
git remote add origin git@github.com:your-user/your-project.git
git branch -M main
git push -u origin main
```

- [ ] Verify: `gh repo view --web` opens the repo in browser

---

## Phase 6: Deploy to Vercel

### Connect and Deploy via CLI

```bash
# Link project to Vercel (interactive — creates project if needed)
cd my-project
vercel link

# IMPORTANT: when prompted for root directory, set to: apps/web

# Set environment variables on Vercel
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add SUPABASE_SERVICE_ROLE_KEY production
vercel env add NEXT_PUBLIC_SITE_URL production
# Each command prompts for the value interactively

# Or auto-sync Supabase vars by installing the integration:
# Visit: https://vercel.com/marketplace/supabase (browser required, one-time)

# Deploy to production
vercel --prod
```

- [ ] Watch build output for errors
  - Common issue: missing env vars (Makerkit validates with Zod at build time)

### Enable GitHub Auto-Deploy

```bash
# If you used `vercel link` + `gh repo create`, Vercel should auto-detect
# the GitHub connection. If not, connect via:
vercel git connect
```

- [ ] Verify: push a commit to `main` and confirm Vercel auto-deploys
- [ ] Verify: the Vercel preview URL works (e.g., `your-project.vercel.app`)
- [ ] Test signup/login on the deployed version

---

## Phase 7: Custom Domain (Pair Networks)

### Add Domain to Vercel via CLI

```bash
# Add your domain
vercel domains add yourdomain.com

# Vercel will output the DNS records you need to configure
```

### Configure DNS at Pair Networks (browser required)

- [ ] Log in to [Pair Networks Account Control Center](https://my.pair.com/)
- [ ] Navigate to DNS management for your domain
- [ ] Add an **A record**:
  - Host: `@` (root)
  - Value: `76.76.21.21`
- [ ] Add a **CNAME record**:
  - Host: `www`
  - Value: `cname.vercel-dns.com.` (include the trailing dot)
- [ ] Save changes

### Verify

```bash
# Check DNS propagation (may take up to 24-48 hours)
dig yourdomain.com A +short          # should return 76.76.21.21
dig www.yourdomain.com CNAME +short  # should return cname.vercel-dns.com.

# Check domain status on Vercel
vercel domains inspect yourdomain.com
```

- [ ] Vercel automatically provisions SSL (free, Let's Encrypt)
- [ ] Visit `https://yourdomain.com` — should load your app with HTTPS

### Update Auth Redirect URLs

```bash
# Update NEXT_PUBLIC_SITE_URL on Vercel to production domain
vercel env rm NEXT_PUBLIC_SITE_URL production
vercel env add NEXT_PUBLIC_SITE_URL production
# Enter: https://yourdomain.com

# Redeploy with updated env
vercel --prod
```

- [ ] Go to Supabase dashboard > Authentication > URL Configuration
- [ ] Update Site URL to `https://yourdomain.com`
- [ ] Confirm `https://yourdomain.com/auth/callback` is in redirect URLs

---

## Phase 8: Post-Deploy Verification

Manual checks:

- [ ] Sign up with a new account on the production URL
- [ ] Verify email confirmation works
- [ ] Log in and out
- [ ] Test OAuth login (Google/GitHub) if configured
- [ ] Verify protected routes work correctly
- [ ] Check admin panel (create an admin user by updating tier in Supabase)
- [ ] Test on mobile device
- [ ] Check SSL certificate is valid (padlock icon in browser)

Automated checks via Playwright MCP (if configured):

```
# In Claude Code, you can ask:
# "Navigate to https://yourdomain.com and take a screenshot"
# "Fill in the signup form and verify it works"
# Uses: mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, etc.
```

Quick DB check via Supabase MCP or CLI:

```bash
# Verify the profiles table exists and your test user was created
supabase db execute --project-ref <ref> \
  "SELECT id, email, tier FROM public.profiles LIMIT 5;"

# Or via Supabase MCP:
#   mcp__supabase__execute_sql
```

---

## Phase 9: Customization (as needed)

- [ ] Strip out features you don't need (payments, blog, etc.)
- [ ] Customize branding (logo, colors, app name)
- [ ] Modify the tier/role system if the built-in RBAC doesn't match your needs
- [ ] Add your app-specific database tables and migrations
- [ ] Configure email provider (Resend or Nodemailer) if sending transactional
      emails
- [ ] Set up Stripe if accepting payments

---

## Quick Reference: CLIs and MCPs

| Task                     | CLI Command                          | MCP Alternative                        |
| ------------------------ | ------------------------------------ | -------------------------------------- |
| Create Supabase project  | `supabase projects create`           | `mcp__supabase__create_project`        |
| Get project URL/keys     | `supabase projects api-keys`         | `mcp__supabase__get_project_url`       |
| Run SQL                  | `supabase db execute`                | `mcp__supabase__execute_sql`           |
| Apply migrations         | `supabase db push`                   | `mcp__supabase__apply_migration`       |
| List tables              | `supabase db dump --schema public`   | `mcp__supabase__list_tables`           |
| Create GitHub repo       | `gh repo create`                     | —                                      |
| Create PR                | `gh pr create`                       | —                                      |
| Deploy to Vercel         | `vercel --prod`                      | —                                      |
| Add Vercel domain        | `vercel domains add`                 | —                                      |
| Set Vercel env var       | `vercel env add`                     | —                                      |
| Check Vercel deploy logs | `vercel logs`                        | —                                      |
| Browser testing          | —                                    | `mcp__playwright__browser_navigate`    |

---

## Quick Reference: Key URLs

| Service       | URL                                                                            |
| ------------- | ------------------------------------------------------------------------------ |
| Supabase Dash | `https://supabase.com/dashboard`                                               |
| Vercel Dash   | `https://vercel.com/dashboard`                                                 |
| Makerkit Docs | `https://makerkit.dev/docs/next-supabase-turbo`                                |
| Makerkit CLI  | `https://github.com/makerkit/cli`                                              |
| Vercel Deploy | `https://makerkit.dev/docs/next-supabase-turbo/going-to-production/vercel`     |
| Pair DNS      | `https://my.pair.com/`                                                         |

---

## Estimated Timeline

| Phase                      | Time                              |
| -------------------------- | --------------------------------- |
| Accounts & tool install    | 30 minutes                        |
| Supabase project setup     | 15 minutes                        |
| Makerkit clone & local dev | 30 minutes                        |
| Push to GitHub             | 5 minutes                         |
| Vercel deploy              | 15 minutes                        |
| Custom domain + DNS        | 15 minutes + 24-48h propagation   |
| Post-deploy verification   | 15 minutes                        |
| **Total (hands-on)**       | **~2 hours**                      |

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

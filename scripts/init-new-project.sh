#!/bin/bash
#
# init-new-project.sh
#
# Initializes a new project from the site-auth-db template.
# Removes development-specific files and prepares for a fresh start.
#
# Usage: ./scripts/init-new-project.sh [project-name]
#
# Example: ./scripts/init-new-project.sh my-ecommerce-app
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# WHITELIST CONFIGURATION
# ============================================
# Only these directories/files are considered part of the template.
# Everything else at the root level will be flagged for review/removal.
#
# Add new template directories here as the project evolves.
# ============================================

WHITELISTED_DIRS=(
    "web"
    "supabase"
    "scripts"
    "config"
    "docs"
    "tests"
)

WHITELISTED_FILES=(
    ".env.example"
    ".gitignore"
    "README.md"
    "LICENSE"
    "package.json"
    "pnpm-workspace.yaml"
    "turbo.json"
    ".nvmrc"
    ".node-version"
)

# ============================================
# DEVELOPMENT-SPECIFIC DIRECTORIES TO REMOVE
# ============================================
# These are always removed as they contain development-specific data.
# ============================================

DEV_DIRS_TO_REMOVE=(
    ".taskmaster"      # TaskMaster AI tasks (template development)
    ".claude"          # Claude Code context/settings
    ".cursor"          # Cursor IDE settings
    ".aider"           # Aider AI settings
    ".codeium"         # Codeium AI settings
    ".continue"        # Continue AI settings
    ".git"             # Git history (will reinitialize)
    "node_modules"     # Dependencies (will reinstall)
    ".next"            # Next.js build output
    ".turbo"           # Turbo cache
    "dist"             # Build output
    "build"            # Build output
    ".vercel"          # Vercel deployment cache
    ".netlify"         # Netlify deployment cache
)

DEV_FILES_TO_REMOVE=(
    ".env.local"       # Local environment (contains real credentials)
    ".env.development.local"
    ".env.production.local"
    ".DS_Store"
)

# ============================================
# FUNCTIONS
# ============================================

print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  Site Auth DB - New Project Initializer${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

confirm_action() {
    local prompt="$1"
    local response
    echo -e -n "${YELLOW}${prompt} (y/N): ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Check for unwhitelisted directories
check_for_unknown_dirs() {
    local unknown_dirs=()

    for dir in */; do
        dir="${dir%/}"  # Remove trailing slash
        local is_whitelisted=false

        for whitelist_dir in "${WHITELISTED_DIRS[@]}"; do
            if [[ "$dir" == "$whitelist_dir" ]]; then
                is_whitelisted=true
                break
            fi
        done

        # Check if it's a dev dir to remove
        for dev_dir in "${DEV_DIRS_TO_REMOVE[@]}"; do
            if [[ "$dir" == "$dev_dir" ]]; then
                is_whitelisted=true  # Will be handled by removal
                break
            fi
        done

        if [[ "$is_whitelisted" == false ]]; then
            unknown_dirs+=("$dir")
        fi
    done

    # Check hidden directories
    for dir in .*/; do
        dir="${dir%/}"
        [[ "$dir" == "." || "$dir" == ".." ]] && continue

        local is_whitelisted=false

        for dev_dir in "${DEV_DIRS_TO_REMOVE[@]}"; do
            if [[ "$dir" == "$dev_dir" ]]; then
                is_whitelisted=true
                break
            fi
        done

        if [[ "$is_whitelisted" == false && ! " ${WHITELISTED_FILES[*]} " =~ " ${dir} " ]]; then
            # Check if it's a whitelisted hidden file
            local is_file=false
            for whitelist_file in "${WHITELISTED_FILES[@]}"; do
                if [[ "$dir" == "$whitelist_file" ]]; then
                    is_file=true
                    break
                fi
            done

            if [[ "$is_file" == false && -d "$dir" ]]; then
                unknown_dirs+=("$dir")
            fi
        fi
    done

    if [[ ${#unknown_dirs[@]} -gt 0 ]]; then
        print_warning "Found directories not in whitelist:"
        for dir in "${unknown_dirs[@]}"; do
            echo "  - $dir"
        done
        echo ""
        if confirm_action "Remove these unknown directories?"; then
            for dir in "${unknown_dirs[@]}"; do
                rm -rf "$dir"
                echo "  Removed: $dir"
            done
        else
            print_warning "Keeping unknown directories. Review manually if needed."
        fi
    fi
}

# ============================================
# MAIN SCRIPT
# ============================================

print_header

# Get project name from argument or prompt
PROJECT_NAME="$1"
if [[ -z "$PROJECT_NAME" ]]; then
    echo -e -n "${BLUE}Enter new project name: ${NC}"
    read -r PROJECT_NAME
fi

if [[ -z "$PROJECT_NAME" ]]; then
    print_error "Project name is required."
    exit 1
fi

# Validate project name (alphanumeric, hyphens, underscores)
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
    print_error "Invalid project name. Use alphanumeric characters, hyphens, and underscores. Must start with a letter."
    exit 1
fi

echo ""
echo -e "Project name: ${GREEN}${PROJECT_NAME}${NC}"
echo ""

# Confirm before proceeding
if ! confirm_action "This will remove development files and initialize a fresh project. Continue?"; then
    echo "Aborted."
    exit 0
fi

echo ""

# Step 1: Remove development-specific directories
print_step "Removing development-specific directories..."
for dir in "${DEV_DIRS_TO_REMOVE[@]}"; do
    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
        echo "  Removed: $dir"
    fi
done

# Step 2: Remove development-specific files
print_step "Removing development-specific files..."
for file in "${DEV_FILES_TO_REMOVE[@]}"; do
    if [[ -f "$file" ]]; then
        rm -f "$file"
        echo "  Removed: $file"
    fi
    # Also check in web/ directory
    if [[ -f "web/$file" ]]; then
        rm -f "web/$file"
        echo "  Removed: web/$file"
    fi
done

# Step 3: Check for unknown directories
print_step "Checking for unknown directories..."
check_for_unknown_dirs

# Step 4: Update package.json if it exists
print_step "Updating project configuration..."
if [[ -f "package.json" ]]; then
    # Use sed to update the name field
    sed -i.bak "s/\"name\": \"[^\"]*\"/\"name\": \"${PROJECT_NAME}\"/" package.json
    rm -f package.json.bak
    echo "  Updated: package.json (name: ${PROJECT_NAME})"
fi

if [[ -f "web/package.json" ]]; then
    sed -i.bak "s/\"name\": \"[^\"]*\"/\"name\": \"${PROJECT_NAME}\"/" web/package.json
    rm -f web/package.json.bak
    echo "  Updated: web/package.json (name: ${PROJECT_NAME})"
fi

# Step 5: Create .env.local from .env.example
print_step "Setting up environment files..."
if [[ -f ".env.example" ]]; then
    cp .env.example .env.local
    echo "  Created: .env.local from .env.example"
fi

if [[ -f "web/.env.example" ]]; then
    cp web/.env.example web/.env.local
    echo "  Created: web/.env.local from web/.env.example"
fi

# Step 6: Initialize fresh git repository
print_step "Initializing fresh git repository..."
git init
echo "  Initialized empty git repository"

# Step 7: Optionally install dependencies
echo ""
if confirm_action "Install dependencies now? (pnpm install)"; then
    print_step "Installing dependencies..."
    if command -v pnpm &> /dev/null; then
        pnpm install
    elif command -v npm &> /dev/null; then
        npm install
    else
        print_warning "No package manager found. Run 'pnpm install' or 'npm install' manually."
    fi
fi

# Step 8: Summary
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Project initialized successfully!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Update .env.local with your Supabase credentials"
echo "  2. Create a new Supabase project at https://supabase.com"
echo "  3. Run database migrations: pnpm supabase db push"
echo "  4. Start development: cd web && pnpm dev"
echo ""
echo -e "Project: ${GREEN}${PROJECT_NAME}${NC}"
echo ""

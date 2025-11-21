#!/bin/bash

# Ghost Theme Testing Script
# Runs validation and provides testing checklist

set -e

THEME_DIR="${1:-.}"
COLOR_RESET='\033[0m'
COLOR_GREEN='\033[0m'
COLOR_RED='\033[31m'
COLOR_YELLOW='\033[33m'
COLOR_BLUE='\033[34m'

echo -e "${COLOR_BLUE}Ghost Theme Testing Script${COLOR_RESET}"
echo "================================"
echo ""

# Check if Node.js is available
if command -v node &> /dev/null; then
    echo -e "${COLOR_GREEN}✓ Node.js found${COLOR_RESET}"
    
    # Run custom validator
    if [ -f "validate-theme.js" ]; then
        echo ""
        echo "Running custom validator..."
        node validate-theme.js "$THEME_DIR" || true
    fi
    
    # Check for GScan
    if command -v gscan &> /dev/null; then
        echo ""
        echo "Running GScan..."
        gscan "$THEME_DIR" || true
    else
        echo -e "${COLOR_YELLOW}⚠ GScan not installed. Install with: npm install -g gscan${COLOR_RESET}"
    fi
else
    echo -e "${COLOR_YELLOW}⚠ Node.js not found. Skipping validation.${COLOR_RESET}"
fi

echo ""
echo "================================"
echo "Theme Structure Check"
echo "================================"

# Check required files
REQUIRED_FILES=("package.json" "default.hbs")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$THEME_DIR/$file" ]; then
        echo -e "${COLOR_GREEN}✓ $file${COLOR_RESET}"
    else
        echo -e "${COLOR_RED}✗ $file (MISSING)${COLOR_RESET}"
    fi
done

# Check optional files
OPTIONAL_FILES=("index.hbs" "home.hbs" "post.hbs" "page.hbs" "tag.hbs" "author.hbs" "error.hbs")
echo ""
echo "Optional files:"
for file in "${OPTIONAL_FILES[@]}"; do
    if [ -f "$THEME_DIR/$file" ]; then
        echo -e "${COLOR_GREEN}✓ $file${COLOR_RESET}"
    else
        echo -e "  - $file"
    fi
done

# Check directories
echo ""
echo "Directories:"
for dir in "partials" "assets" "assets/css" "assets/js"; do
    if [ -d "$THEME_DIR/$dir" ]; then
        echo -e "${COLOR_GREEN}✓ $dir/${COLOR_RESET}"
    else
        echo -e "  - $dir/"
    fi
done

echo ""
echo "================================"
echo "Testing Checklist"
echo "================================"
echo ""
echo "Content Types:"
echo "  [ ] Regular blog posts"
echo "  [ ] Posts with featured images"
echo "  [ ] Posts with mood tags (calm, manic, reflective, defiant)"
echo "  [ ] Workshop posts (tag: workshop)"
echo "  [ ] Gallery posts (tag: gallery)"
echo "  [ ] Static pages"
echo "  [ ] Tag archive pages"
echo "  [ ] Author archive pages"
echo ""
echo "Features:"
echo "  [ ] Navigation menu"
echo "  [ ] Mobile menu"
echo "  [ ] Mood filtering"
echo "  [ ] Lightbox gallery"
echo "  [ ] Pagination"
echo "  [ ] Related posts"
echo ""
echo "Responsive:"
echo "  [ ] Mobile (< 768px)"
echo "  [ ] Tablet (768px - 1024px)"
echo "  [ ] Desktop (> 1024px)"
echo ""
echo "Accessibility:"
echo "  [ ] Keyboard navigation"
echo "  [ ] Reduced motion support"
echo "  [ ] Color contrast"
echo "  [ ] Focus states"
echo ""


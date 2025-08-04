#!/bin/bash

# SmartAgriNet GitHub Push Script
# This script helps you push the project to GitHub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if git is initialized
check_git_status() {
    if [ ! -d ".git" ]; then
        print_error "Git repository not initialized. Please run 'git init' first."
        exit 1
    fi
}

# Function to check if remote exists
check_remote() {
    if ! git remote get-url origin >/dev/null 2>&1; then
        print_warning "No remote origin found. You'll need to add it manually."
        return 1
    fi
    return 0
}

# Function to setup git repository
setup_git() {
    print_status "Setting up Git repository..."
    
    # Initialize git if not already done
    if [ ! -d ".git" ]; then
        git init
        print_success "Git repository initialized."
    fi
    
    # Add all files
    print_status "Adding files to git..."
    git add .
    
    # Check if there are changes to commit
    if git diff --cached --quiet; then
        print_warning "No changes to commit. All files are already tracked."
        return 0
    fi
    
    # Create initial commit
    print_status "Creating initial commit..."
    git commit -m "feat: initial SmartAgriNet platform commit

- Complete full-stack smart agriculture platform
- Backend: Node.js + Express + Firebase
- Frontend: Flutter mobile app
- AI/ML integration for crop recommendations and pest detection
- Marketplace for agricultural products
- Multi-language support for African farmers
- Comprehensive documentation and setup scripts"
    
    print_success "Initial commit created successfully!"
}

# Function to add remote and push
push_to_github() {
    print_status "Pushing to GitHub..."
    
    # Check if remote exists
    if ! check_remote; then
        print_status "Please add your GitHub remote:"
        echo "git remote add origin https://github.com/YOUR_USERNAME/smartagrinet.git"
        echo ""
        print_status "Then run this script again."
        return 1
    fi
    
    # Get current branch
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Push to GitHub
    print_status "Pushing to origin/$CURRENT_BRANCH..."
    git push -u origin "$CURRENT_BRANCH"
    
    print_success "Successfully pushed to GitHub!"
    
    # Get repository URL
    REPO_URL=$(git remote get-url origin)
    if [[ $REPO_URL == *"github.com"* ]]; then
        # Convert SSH to HTTPS if needed
        REPO_URL=$(echo "$REPO_URL" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
        print_success "Your repository is available at: $REPO_URL"
    fi
}

# Function to create GitHub repository (if needed)
create_github_repo() {
    print_status "To create a new GitHub repository:"
    echo ""
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: smartagrinet"
    echo "3. Description: Smart Agriculture Platform for African Farmers"
    echo "4. Make it Public or Private (your choice)"
    echo "5. Don't initialize with README (we already have one)"
    echo "6. Click 'Create repository'"
    echo ""
    echo "Then run:"
    echo "git remote add origin https://github.com/YOUR_USERNAME/smartagrinet.git"
    echo ""
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo "=========================================="
    print_success "SmartAgriNet is ready for GitHub!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Create GitHub repository (if not done):"
    echo "   - Go to https://github.com/new"
    echo "   - Name: smartagrinet"
    echo "   - Description: Smart Agriculture Platform for African Farmers"
    echo ""
    echo "2. Add remote (if not done):"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/smartagrinet.git"
    echo ""
    echo "3. Push to GitHub:"
    echo "   git push -u origin main"
    echo ""
    echo "4. Set up GitHub Pages (optional):"
    echo "   - Go to repository Settings > Pages"
    echo "   - Source: Deploy from a branch"
    echo "   - Branch: main, folder: /docs"
    echo ""
    echo "5. Configure GitHub Actions:"
    echo "   - The CI/CD pipeline will run automatically"
    echo "   - Check Actions tab for build status"
    echo ""
    echo "6. Add collaborators:"
    echo "   - Go to repository Settings > Collaborators"
    echo "   - Add team members and contributors"
    echo ""
    echo "7. Set up branch protection:"
    echo "   - Go to repository Settings > Branches"
    echo "   - Add rule for main branch"
    echo "   - Require pull request reviews"
    echo ""
    echo "Documentation:"
    echo "- README.md: Project overview and setup"
    echo "- docs/ARCHITECTURE.md: Technical architecture"
    echo "- CONTRIBUTING.md: How to contribute"
    echo "- scripts/setup.sh: Development setup"
    echo ""
}

# Main function
main() {
    echo "=========================================="
    echo "    SmartAgriNet GitHub Push Script"
    echo "=========================================="
    echo ""
    
    # Check if running in the correct directory
    if [ ! -f "README.md" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
        print_error "Please run this script from the project root directory."
        exit 1
    fi
    
    # Check git status
    check_git_status
    
    # Setup git repository
    setup_git
    
    # Check if remote exists
    if ! check_remote; then
        create_github_repo
        show_next_steps
        exit 0
    fi
    
    # Push to GitHub
    if push_to_github; then
        show_next_steps
    fi
}

# Run main function
main "$@" 
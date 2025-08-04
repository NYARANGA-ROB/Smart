#!/bin/bash

# SmartAgriNet Setup Script
# This script sets up the complete SmartAgriNet platform

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check Node.js
    if ! command_exists node; then
        missing_deps+=("Node.js")
    else
        NODE_VERSION=$(node --version)
        print_success "Node.js found: $NODE_VERSION"
    fi
    
    # Check npm
    if ! command_exists npm; then
        missing_deps+=("npm")
    else
        NPM_VERSION=$(npm --version)
        print_success "npm found: $NPM_VERSION"
    fi
    
    # Check Flutter
    if ! command_exists flutter; then
        missing_deps+=("Flutter")
    else
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_success "Flutter found: $FLUTTER_VERSION"
    fi
    
    # Check Firebase CLI
    if ! command_exists firebase; then
        missing_deps+=("Firebase CLI")
    else
        FIREBASE_VERSION=$(firebase --version)
        print_success "Firebase CLI found: $FIREBASE_VERSION"
    fi
    
    # Check Git
    if ! command_exists git; then
        missing_deps+=("Git")
    else
        GIT_VERSION=$(git --version)
        print_success "Git found: $GIT_VERSION"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Please install the missing dependencies and run this script again."
        exit 1
    fi
    
    print_success "All prerequisites are satisfied!"
}

# Function to setup backend
setup_backend() {
    print_status "Setting up backend..."
    
    cd backend
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install
    
    # Create environment file
    if [ ! -f .env ]; then
        print_status "Creating environment file..."
        cp env.example .env
        print_warning "Please update the .env file with your configuration values."
    else
        print_success "Environment file already exists."
    fi
    
    # Create logs directory
    mkdir -p logs
    
    # Run database migrations
    print_status "Running database migrations..."
    npm run migrate
    
    # Seed initial data
    print_status "Seeding initial data..."
    npm run seed
    
    cd ..
    print_success "Backend setup completed!"
}

# Function to setup frontend
setup_frontend() {
    print_status "Setting up frontend..."
    
    cd frontend
    
    # Get Flutter dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Create assets directories
    mkdir -p assets/images
    mkdir -p assets/icons
    mkdir -p assets/animations
    mkdir -p assets/translations
    mkdir -p assets/ml_models
    mkdir -p assets/fonts
    
    # Generate code
    print_status "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    cd ..
    print_success "Frontend setup completed!"
}

# Function to setup Firebase
setup_firebase() {
    print_status "Setting up Firebase..."
    
    # Check if user is logged in
    if ! firebase projects:list >/dev/null 2>&1; then
        print_warning "Please login to Firebase first:"
        print_status "Run: firebase login"
        return 1
    fi
    
    # Initialize Firebase
    print_status "Initializing Firebase project..."
    firebase init
    
    print_success "Firebase setup completed!"
}

# Function to setup AI models
setup_ai_models() {
    print_status "Setting up AI models..."
    
    cd ai-models
    
    # Create model directories
    mkdir -p crop_recommendation
    mkdir -p pest_detection
    mkdir -p soil_analysis
    mkdir -p weather_prediction
    
    # Download pre-trained models (if available)
    print_status "Downloading pre-trained models..."
    
    # Crop recommendation model
    if [ ! -f crop_recommendation/model.json ]; then
        print_warning "Crop recommendation model not found. Please add your trained model."
    fi
    
    # Pest detection model
    if [ ! -f pest_detection/model.tflite ]; then
        print_warning "Pest detection model not found. Please add your trained model."
    fi
    
    # Soil analysis model
    if [ ! -f soil_analysis/model.json ]; then
        print_warning "Soil analysis model not found. Please add your trained model."
    fi
    
    cd ..
    print_success "AI models setup completed!"
}

# Function to setup development environment
setup_dev_environment() {
    print_status "Setting up development environment..."
    
    # Create .gitignore if it doesn't exist
    if [ ! -f .gitignore ]; then
        cat > .gitignore << EOF
# Dependencies
node_modules/
.packages
.pub-cache/
.pub/

# Environment files
.env
.env.local
.env.production

# Build outputs
build/
dist/
*.dart.js

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Firebase
.firebase/
firebase-debug.log

# Flutter
.flutter-plugins
.flutter-plugins-dependencies

# Generated files
*.g.dart
*.freezed.dart

# Coverage
coverage/

# Temporary files
tmp/
temp/
EOF
        print_success "Created .gitignore file."
    fi
    
    # Create README for development
    if [ ! -f docs/DEVELOPMENT.md ]; then
        mkdir -p docs
        cat > docs/DEVELOPMENT.md << EOF
# Development Guide

## Getting Started

1. Clone the repository
2. Run \`./scripts/setup.sh\` to setup the development environment
3. Update the environment variables in \`backend/.env\`
4. Start the backend: \`cd backend && npm run dev\`
5. Start the frontend: \`cd frontend && flutter run\`

## Development Workflow

1. Create a feature branch from \`main\`
2. Make your changes
3. Write tests
4. Run tests: \`npm test\` (backend) and \`flutter test\` (frontend)
5. Submit a pull request

## Code Style

- Backend: ESLint + Prettier
- Frontend: Flutter Lints
- Commit messages: Conventional Commits

## Testing

- Backend: Jest
- Frontend: Flutter Test
- E2E: Flutter Integration Test

## Deployment

- Backend: Google Cloud Run
- Frontend: Firebase Hosting
- Database: Firebase Firestore
EOF
        print_success "Created development documentation."
    fi
    
    print_success "Development environment setup completed!"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    
    # Backend tests
    cd backend
    print_status "Running backend tests..."
    npm test
    cd ..
    
    # Frontend tests
    cd frontend
    print_status "Running frontend tests..."
    flutter test
    cd ..
    
    print_success "All tests passed!"
}

# Function to start development servers
start_dev_servers() {
    print_status "Starting development servers..."
    
    # Start backend in background
    cd backend
    print_status "Starting backend server..."
    npm run dev &
    BACKEND_PID=$!
    cd ..
    
    # Start frontend
    cd frontend
    print_status "Starting Flutter app..."
    flutter run
    
    # Kill backend when frontend exits
    kill $BACKEND_PID 2>/dev/null || true
}

# Main function
main() {
    echo "=========================================="
    echo "    SmartAgriNet Platform Setup"
    echo "=========================================="
    echo ""
    
    # Check if running in the correct directory
    if [ ! -f "README.md" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
        print_error "Please run this script from the project root directory."
        exit 1
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Setup components
    setup_backend
    setup_frontend
    setup_ai_models
    setup_dev_environment
    
    # Optional Firebase setup
    read -p "Do you want to setup Firebase now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_firebase
    fi
    
    # Run tests
    read -p "Do you want to run tests? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_tests
    fi
    
    # Start development servers
    read -p "Do you want to start development servers? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        start_dev_servers
    fi
    
    echo ""
    echo "=========================================="
    print_success "SmartAgriNet setup completed successfully!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Update backend/.env with your configuration"
    echo "2. Add your AI models to ai-models/ directory"
    echo "3. Configure Firebase project settings"
    echo "4. Start development: cd backend && npm run dev"
    echo "5. Run Flutter app: cd frontend && flutter run"
    echo ""
    echo "Documentation:"
    echo "- Architecture: docs/ARCHITECTURE.md"
    echo "- Development: docs/DEVELOPMENT.md"
    echo "- API Documentation: docs/API.md"
    echo ""
}

# Run main function
main "$@" 
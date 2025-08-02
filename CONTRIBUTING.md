# Contributing to SmartAgriNet

Thank you for your interest in contributing to SmartAgriNet! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Code Style](#code-style)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)
- [Feature Requests](#feature-requests)

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details.

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Flutter 3.0+
- Firebase CLI
- Git

### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/your-username/smartagrinet.git
   cd smartagrinet
   ```

2. **Run the setup script**
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

3. **Configure environment variables**
   ```bash
   cp backend/env.example backend/.env
   # Edit backend/.env with your configuration
   ```

4. **Start development servers**
   ```bash
   # Backend
   cd backend && npm run dev
   
   # Frontend (in another terminal)
   cd frontend && flutter run
   ```

## Contributing Guidelines

### Types of Contributions

We welcome various types of contributions:

- **Bug fixes**: Fix issues and improve stability
- **New features**: Add new functionality
- **Documentation**: Improve docs and guides
- **Testing**: Add tests and improve coverage
- **UI/UX**: Improve user interface and experience
- **Performance**: Optimize code and performance
- **Localization**: Add support for new languages

### Branch Naming Convention

Use the following branch naming convention:

```
<type>/<description>
```

Types:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `style/` - Code style changes
- `refactor/` - Code refactoring
- `test/` - Adding or updating tests
- `chore/` - Maintenance tasks

Examples:
- `feature/crop-recommendation`
- `fix/pest-detection-bug`
- `docs/api-documentation`

### Commit Message Convention

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(auth): add biometric authentication
fix(marketplace): resolve payment processing issue
docs(api): update authentication endpoints
```

## Code Style

### Backend (Node.js)

- Use ESLint and Prettier for code formatting
- Follow Airbnb JavaScript Style Guide
- Use TypeScript for new files (optional but recommended)
- Write meaningful variable and function names
- Add JSDoc comments for public APIs

```javascript
/**
 * Get crop recommendations based on soil analysis
 * @param {Object} soilData - Soil analysis data
 * @param {string} location - Geographic location
 * @returns {Promise<Array>} Array of crop recommendations
 */
async function getCropRecommendations(soilData, location) {
  // Implementation
}
```

### Frontend (Flutter)

- Follow Flutter style guide
- Use meaningful widget and variable names
- Organize code into features/modules
- Use proper state management (Provider/Riverpod)
- Add documentation for complex widgets

```dart
/// A widget that displays crop recommendations
/// with soil analysis integration
class CropRecommendationWidget extends StatelessWidget {
  final SoilAnalysis soilAnalysis;
  final VoidCallback onRecommendationSelected;

  const CropRecommendationWidget({
    Key? key,
    required this.soilAnalysis,
    required this.onRecommendationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## Testing

### Backend Testing

- Write unit tests for all business logic
- Use Jest for testing framework
- Aim for >80% code coverage
- Test API endpoints with supertest

```javascript
describe('Crop Recommendation Service', () => {
  it('should return crop recommendations for valid soil data', async () => {
    const soilData = { ph: 6.5, nitrogen: 25, phosphorus: 15 };
    const recommendations = await getCropRecommendations(soilData);
    expect(recommendations).toBeDefined();
    expect(recommendations.length).toBeGreaterThan(0);
  });
});
```

### Frontend Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Use Flutter's built-in testing framework
- Test user interactions and edge cases

```dart
testWidgets('CropRecommendationWidget displays recommendations', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CropRecommendationWidget(
        soilAnalysis: mockSoilAnalysis,
        onRecommendationSelected: () {},
      ),
    ),
  );

  expect(find.text('Recommended Crops'), findsOneWidget);
  expect(find.byType(CropCard), findsWidgets);
});
```

## Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, well-documented code
   - Add tests for new functionality
   - Update documentation if needed

3. **Run tests**
   ```bash
   # Backend tests
   cd backend && npm test
   
   # Frontend tests
   cd frontend && flutter test
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat(module): add new feature description"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Use the PR template
   - Provide clear description of changes
   - Link related issues
   - Request reviews from maintainers

### Pull Request Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement
- [ ] Test addition/update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Tests added/updated

## Screenshots (if applicable)
Add screenshots for UI changes.

## Related Issues
Closes #123
```

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

1. **Clear description** of the issue
2. **Steps to reproduce** the problem
3. **Expected behavior** vs actual behavior
4. **Environment details**:
   - OS and version
   - Node.js version
   - Flutter version
   - Browser (if applicable)
5. **Screenshots or videos** (if applicable)
6. **Console logs** or error messages

### Issue Template

```markdown
## Bug Description
Clear description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Environment
- OS: [e.g. Windows 10, macOS 12.0]
- Node.js: [e.g. 18.15.0]
- Flutter: [e.g. 3.10.0]
- Browser: [e.g. Chrome 115]

## Additional Information
Any additional context, logs, or screenshots.
```

## Feature Requests

When requesting features, please include:

1. **Clear description** of the feature
2. **Use case** and benefits
3. **Proposed implementation** (if you have ideas)
4. **Priority level** (low, medium, high)
5. **Mockups or wireframes** (if applicable)

## Getting Help

- **Documentation**: Check [docs/](docs/) directory
- **Issues**: Search existing issues on GitHub
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact maintainers for private matters

## Recognition

Contributors will be recognized in:

- Project README
- Release notes
- Contributor hall of fame
- GitHub contributors page

## License

By contributing to SmartAgriNet, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to SmartAgriNet! 🌱 
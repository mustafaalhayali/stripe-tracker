# Contributing to StripeTracker

Thank you for your interest in contributing to StripeTracker! We welcome contributions from the community.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/StripeTracker.git
   cd StripeTracker
   ```
3. **Open the project** in Xcode
4. **Create a new branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- A Stripe account (for testing)

### Building and Running

1. Open `StripeTracker.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Build and run the project (⌘+R)

## Types of Contributions

### Bug Reports

If you find a bug, please create an issue with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected vs actual behavior
- macOS version and Xcode version
- Screenshots if applicable

### Feature Requests

For new features:
- Check existing issues to avoid duplicates
- Clearly describe the feature and its benefits
- Consider backward compatibility

### Code Contributions

We welcome:
- Bug fixes
- New features
- Performance improvements
- UI/UX improvements
- Documentation improvements

## Coding Standards

### Swift Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Prefer `let` over `var` when possible
- Use SwiftUI best practices

### Code Organization

- Keep functions focused and small
- Use MARK comments to organize code sections
- Follow the existing project structure

### Security

- Never commit API keys or sensitive data
- Use keychain for secure storage
- Follow secure coding practices

## Pull Request Process

1. **Update your branch** with the latest main:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Test your changes** thoroughly:
   - Test with both test and live Stripe keys
   - Test different revenue scenarios
   - Verify UI responsiveness

3. **Submit your pull request**:
   - Use a clear, descriptive title
   - Explain what changes you made and why
   - Reference any related issues
   - Include screenshots for UI changes

4. **Respond to feedback**:
   - Address reviewer comments promptly
   - Push additional commits as needed

## Code Review

All contributions go through code review. Reviewers will check for:
- Code quality and style
- Security considerations
- Performance implications
- Compatibility
- Test coverage

## Testing

While we don't have automated tests yet, please manually test:
- App launch and menu bar integration
- Settings panel functionality
- API key storage and retrieval
- Revenue data fetching and display
- Error handling scenarios

## Security Considerations

- API keys must be stored in Keychain only
- Network requests must use HTTPS
- Follow macOS sandboxing requirements
- Don't log sensitive information

## License

By contributing, you agree that your contributions will be licensed under the same MIT License that covers the project.

## Questions?

Feel free to open an issue for any questions about contributing!
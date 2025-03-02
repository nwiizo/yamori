# Contributing to Yamori

Thank you for considering contributing to Yamori! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

Please be respectful and considerate of others when contributing to this project. We aim to foster an inclusive and welcoming community.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue on GitHub with the following information:

- A clear, descriptive title
- Steps to reproduce the bug
- Expected behavior
- Actual behavior
- Any relevant logs or screenshots
- Your environment (OS, Rust version, etc.)

### Suggesting Features

If you have an idea for a new feature, please create an issue on GitHub with the following information:

- A clear, descriptive title
- A detailed description of the feature
- Why this feature would be useful
- Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a new branch for your changes
3. Make your changes
4. Run tests to ensure your changes don't break existing functionality
5. Submit a pull request

Please include a clear description of the changes and update any relevant documentation.

## Development Setup

1. Clone the repository:
   ```
   git clone https://github.com/nwiizo/yamori.git
   cd yamori
   ```

2. Build the project:
   ```
   cargo build
   ```

3. Run tests:
   ```
   cargo test
   ```

4. Run the application:
   ```
   cargo run -- --yamori-config tests/configs/tests.toml
   ```

## Coding Style

- Follow the Rust style guide
- Use meaningful variable and function names
- Write comments for complex logic
- Include documentation for public functions and types

## Testing

- Write tests for new functionality
- Ensure all tests pass before submitting a pull request
- Consider edge cases in your tests

## Documentation

- Update documentation for any changes to functionality
- Use clear, concise language
- Include examples where appropriate

## License

By contributing to this project, you agree that your contributions will be licensed under the project's [MIT License](LICENSE). 
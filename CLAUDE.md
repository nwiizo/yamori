# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Yamori is a test runner and visualizer for command-line applications written in Rust. It supports both TUI (Terminal User Interface) and CLI modes, allowing users to define tests in TOML or YAML format and visualize results in a terminal interface.

## Development Commands

### Building
```bash
# Debug build
cargo build
make build

# Release build  
cargo build --release
make build-release

# Build example programs
make build-examples
make build-examples-release
```

### Testing
```bash
# Run tests with TUI (default mode)
yamori --yamori-config tests/configs/tests.toml
cargo run -- --yamori-config tests/configs/tests.toml
make test-tui CONFIG=tests/configs/tests.toml

# Run tests in CLI mode (no TUI)
yamori --cli --yamori-config tests/configs/tests.toml
cargo run -- --cli --yamori-config tests/configs/tests.toml
make test-cli CONFIG=tests/configs/tests.toml

# Run tests in release mode
make test-release CONFIG=tests/configs/tests.toml

# Run a specific test
make run-test TEST="Echo Test" CONFIG=tests/configs/tests.toml

# Run unit tests
cargo test

# Run with debug logging
yamori --debug --yamori-config tests/configs/tests.toml
```

### Environment Variables
Use `YAMORI_CONFIG` environment variable to specify config file (takes precedence over CLI args):
```bash
YAMORI_CONFIG=tests/configs/tests.toml yamori

# Enable debug logging via environment
RUST_LOG=yamori=debug yamori --yamori-config tests/configs/tests.toml
```

## Architecture

### Core Modules
- `main.rs` - Entry point, CLI argument parsing, TUI event loop
- `app.rs` - Application state management, test history tracking, popup handling
- `test.rs` - Test configuration parsing, test execution, result comparison
- `ui.rs` - TUI rendering using ratatui framework
- `cli.rs` - CLI mode implementation for headless execution

### Key Data Structures
- `TestConfig` - Parsed configuration from TOML/YAML files
- `TestCase` - Individual test definition with command, args, expected output
- `TestResult` - Test execution results with diff highlighting
- `App` - Main application state containing test results, UI state, and history
- `BuildConfig` - Build configuration for release/debug mode and pre-build commands

### Configuration System
- Supports both TOML (`.toml`) and YAML (`.yaml`, `.yml`) formats
- Global build configuration with per-test overrides
- Pre-build commands for test preparation
- Timeout configuration per test
- Release/debug mode switching

### UI Architecture
- Tab-based interface: Results, Diff, Details, Config, History
- Real-time test execution with progress feedback
- Popup system for confirmations and notifications
- History tracking of test runs with timestamps
- Keyboard navigation (vim-style: j/k for up/down, h/l for tab switching)

### Test Execution Flow
1. Parse configuration file (TOML/YAML auto-detection)
2. Execute pre-build commands if specified
3. Run each test command with async timeout handling (improved in Phase 1)
4. Compare actual vs expected output using text diffing
5. Generate detailed diff highlighting for failures
6. Store results in bounded history for later review (memory-safe)

## Phase 1 Improvements (Latest)

### Memory Management
- **Bounded history storage**: Limited to 100 entries with automatic cleanup
- **Efficient navigation**: History browsing without unnecessary cloning
- **Memory leak prevention**: Automatic cleanup of old history entries

### Process Management
- **Async timeout handling**: Replaced polling-based timeouts with proper async/await
- **Better process cleanup**: Improved handling of timed-out processes
- **Robust execution**: Enhanced command execution with proper error handling

### Error Handling & Logging
- **Structured logging**: Added tracing support with configurable levels
- **Debug mode**: New `--debug` flag for detailed logging
- **Better error messages**: More informative error context throughout

### Code Quality
- **Comprehensive tests**: Unit tests for core functionality
- **Lint compliance**: All clippy warnings resolved
- **Type safety**: Improved type handling and reduced unnecessary complexity

## File Structure
- `src/` - Main source code
- `tests/configs/` - Test configuration examples
- `examples/` - Sample applications for testing
- `scripts/` - Build and test helper scripts
- `docs/` - Documentation and configuration format specs
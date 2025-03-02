# Yamori

[![Crates.io](https://img.shields.io/crates/v/yamori.svg)](https://crates.io/crates/yamori)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Rust](https://github.com/nwiizo/yamori/workflows/Rust/badge.svg)](https://github.com/nwiizo/yamori/actions)

Yamori is a test runner and visualizer for command-line applications. It allows you to define tests in TOML or YAML format and visualize the results in a terminal UI or run them in CLI mode.

![Yamori Demo](docs/yamori-demo.gif)

## Features

- Define tests in TOML or YAML format
- Run commands with arguments and input
- Compare actual output with expected output
- Visualize test results in a terminal UI or simple CLI output
- Support for timeouts
- Support for pre-build commands
- Per-test build configuration
- Color-coded test results
- Test history tracking

## Installation

### From Crates.io

```bash
cargo install yamori
```

### From Source

```bash
# Clone the repository
git clone https://github.com/nwiizo/yamori.git
cd yamori

# Build and install
cargo install --path .
```

## Quick Start

```bash
# Run in TUI mode
yamori --yamori-config tests/configs/tests.toml

# Run in CLI mode
yamori --cli --yamori-config tests/configs/tests.toml

# Using environment variable
YAMORI_CONFIG=tests/configs/tests.toml yamori
```

## Usage

### TUI Mode (Default)

You can run Yamori with a specific configuration file using one of the following methods:

1. Using the `-y` or `--yamori-config` flag:
   ```
   yamori --yamori-config tests/configs/tests.yaml
   ```

2. Using the `YAMORI_CONFIG` environment variable:
   ```
   YAMORI_CONFIG=tests/configs/tests.yaml yamori
   ```

The environment variable takes precedence over the command-line flag if both are specified.

### CLI Mode

You can run Yamori in CLI mode (without the TUI interface) using the `-c` or `--cli` flag:

```
yamori --cli --yamori-config tests/configs/tests.yaml
```

Or with the environment variable:

```
YAMORI_CONFIG=tests/configs/tests.yaml yamori --cli
```

In CLI mode, Yamori will run all tests and display a compact summary of the results. Only failed tests will show detailed information. This is useful for CI/CD pipelines or when you want a quick overview of test results.

## Configuration Format

Yamori supports both TOML and YAML configuration files. The file format is automatically detected based on the file extension (`.toml`, `.yaml`, or `.yml`).

### Example Configuration (TOML)

```toml
# Global build configuration
[build]
release = false
pre_build_commands = ["echo 'Global build preparation'"]

# Test definitions
[[tests]]
name = "Echo Test"
command = "echo"
args = ["Hello, World!"]
expected_output = "Hello, World!"
timeout_secs = 5
[tests.build]
release = false
pre_build_commands = ["echo 'Preparing Echo Test'"]

[[tests]]
name = "Word Count Test"
command = "wc"
args = ["-w"]
input = "This is a test sentence with exactly eight words."
expected_output = "8"
timeout_secs = 5
```

## Key Bindings (TUI Mode)

In the terminal UI:

- `q`: Quit
- `?`: Toggle help
- `j` or Down Arrow: Move down
- `k` or Up Arrow: Move up
- `h` or Left Arrow: Previous tab
- `l` or Right Arrow: Next tab
- `r`: Re-run tests
- `b`: Toggle release mode
- `R`: Run tests in release mode
- `H`: Toggle history view
- `Esc`: Close help/popup

## Documentation

For detailed documentation, please see:
- [Full Documentation](docs/README_full.md)
- [Configuration Format](docs/CONFIG_FORMAT.md)
- [Example Configurations](tests/configs/)

## Project Structure

```
yamori/
├── src/                 # Source code
├── docs/                # Documentation
├── scripts/             # Helper scripts
├── examples/            # Example applications
└── tests/
    └── configs/         # Test configuration files
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE) 
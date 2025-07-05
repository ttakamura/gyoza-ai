# Gyoza AI

AI-powered project using gyoza.

## Development Setup

This project uses [uv](https://github.com/astral-sh/uv) for Python package management.

### Installation

```bash
# Install dependencies
uv sync

# Install development dependencies
uv sync --dev
```

### Running the Application

```bash
# Run the main application
uv run python -m gyoza_ai.main
```

### Development Commands

```bash
# Run tests
uv run pytest

# Run linting
uv run ruff check

# Run formatting
uv run black .

# Run type checking
uv run mypy gyoza_ai
```

## Project Structure

```
gyoza-ai/
├── gyoza_ai/          # Main package
│   ├── __init__.py
│   └── main.py
├── tests/             # Test files
│   ├── __init__.py
│   └── test_main.py
├── pyproject.toml     # Project configuration
└── README.md
```
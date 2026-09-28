---
name: code-cost
description: Measures the cost of the project in terms of maintainability and complexity.
---

## Analyzing maintainability

Use this skill when asked to assess code quality, complexity, technical debt,
or "how maintainable is this codebase".

## Setup

Prompt the user for where to install tools and output reports.
Default to `~/code-risks/`.

## Setup if there are JavaScript files

Use `eslint` to assess code quality.
Use `knip` to look for dead code in JavaScript code files.

## Setup if there are Python files

If the project contains Python code, install Python static analysis tools:

```bash
python -m venv .venv.analysis
.venv.analysis/bin/pip install radon vulture pycodestats
```

Use `radon` to analyze Python file code complexity.
    
- Maintainability index for Python comes from `radon mi -j`. 
- Treat rank `C` (MI less than 10) as a real problem worth flagging in a summary.

Use `vulture` to look for dead code in Python files.

- Use `vulture --min-confidence 80`.
- `vulture` output is informational only — cross-check a few hits before recommending deletion, since dynamic dispatch can cause false positives.

Use `pycodestats` to generate counts of lines of code in Python files.


## Report Format

- When summarizing for a human, lead with the handful of worst offending files.
- Write the output to a file named with the current date and `cost-report.md` in a new folder named `reports`.

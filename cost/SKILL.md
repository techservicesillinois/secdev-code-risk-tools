---
name: cost
description: Measures the cost of the project in terms of maintainability and complexity.
---

## Analyzing maintainability

Use this skill when asked to assess code quality, complexity, technical debt,
or "how maintainable is this codebase".

## Setup

This skill requires Python.

1. Setup the environment using the following commands:

```bash
python -m venv .venv.analysis
.venv.analysis/bin/pip install radon vulture
```

## Analysis

2. When this guide refers to `radon`, find it at `.venv.analysis/bin/radon`.

2. When this guide refers to `vulture`, find it at `.venv.analysis/bin/vulture`.

3. Maintainability index comes from `radon mi -j`. Treat rank `C` (MI < 10)
   as a real problem worth flagging in a summary; rank `B` is borderline;
   rank `A` is fine.

4. Dead code comes from `vulture --min-confidence 80`. It is informational
   only — cross-check a few hits before recommending deletion, since dynamic
   dispatch (plugin loading via `PLUGIN_CLASS`/`TRANSFORMER_CLASS`) causes
   false positives.

## Report Format

5. When summarizing for a human, lead with the handful of worst offenders
   (by MI or complexity), not raw tool output. Group by directory
   (`plugins_user/*` complexity is expected to run higher than `glance/`
   core, since `_build_result` methods fan out over many response fields).
6. Always include the total count of lines of code in the report.
7. Include the average number of lines of code per file in the report.

8. Write the output to a file named `reports/cost-report.md`

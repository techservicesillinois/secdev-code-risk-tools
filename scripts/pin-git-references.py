#!/usr/bin/env python3
"""Pin mutable `uses:` GitHub Actions references in workflows to a commit SHA."""

import re
import subprocess
import sys
from pathlib import Path

USES_RE = re.compile(r"^(\s*-?\s*uses:\s*)([^@\s#]+)@([^\s#]+)(\s*(#.*)?)$")
SHA_RE = re.compile(r"^[0-9a-f]{40}$")


def resolve_ref(repo: str, ref: str) -> str:
    """Resolves `ref` (a tag, branch, or HEAD) in `repo` to a commit SHA, or "" if unresolvable."""
    url = f"https://github.com/{repo}.git"
    refspecs = ["HEAD"] if ref == "HEAD" else [f"refs/tags/{ref}", f"refs/heads/{ref}"]
    result = subprocess.run(["git", "ls-remote", url, *refspecs], capture_output=True, text=True)
    lines = result.stdout.splitlines()
    return lines[0].split()[0] if result.returncode == 0 and lines else ""


def process_workflow(path: Path, write: bool) -> bool:
    """Rewrites or checks one workflow file. Returns False if a finding or an unresolvable ref was hit."""
    output = []
    ok = True
    for line in path.read_text().splitlines():
        match = USES_RE.match(line)
        if match:
            prefix, repo, ref = match.group(1), match.group(2), match.group(3)
            if not SHA_RE.match(ref):
                sha = resolve_ref(repo, ref)
                if not sha:
                    print(f"Unable to resolve {repo}@{ref}", file=sys.stderr)
                    return False
                if write:
                    output.append(f"{prefix}{repo}@{sha} # {ref}")
                else:
                    print(f"Mutable action reference: {repo}@{ref}", file=sys.stderr)
                    ok = False
                continue
        output.append(line)

    if write:
        path.write_text("".join(f"{line}\n" for line in output))
    return ok


def main() -> int:
    mode = "check"
    arg = sys.argv[1] if len(sys.argv) > 1 else "--check"
    if arg == "--write":
        mode = "write"
    elif arg in ("--help", "-h"):
        print(f"Usage: {Path(sys.argv[0]).name} [--check|--write]")
        return 0
    elif arg != "--check":
        print(f"Usage: {Path(sys.argv[0]).name} [--check|--write]", file=sys.stderr)
        return 2

    workflows_dir = Path.cwd() / ".github" / "workflows"
    workflows = sorted(p for p in workflows_dir.glob("*") if p.suffix in (".yml", ".yaml") and p.is_file())

    status = 0
    for workflow in workflows:
        if not process_workflow(workflow, write=mode == "write"):
            status = 1

    if mode == "check" and status == 0:
        print("All Git dependencies and workflow actions are pinned.")

    return status


if __name__ == "__main__":
    sys.exit(main())

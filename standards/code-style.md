# Code Style Standards

## Git

### Commit Messages (NTV Conventional Commits)
```
<type>(<scope>): <subject>

Types: feat, fix, hotfix, test, chore, docs, refactor, build
```

**Scope Rules (NTV):**
1. **Ticket ID (Primary):** If working on a tracked task, the scope MUST be the ticket ID (e.g., `feat(nctvp-64): add new feature`).
2. **Functional Scope (Fallback):** If no ticket exists, use the area of the codebase affected (e.g., `chore(release): bump version`, `docs(agents): add artifact verification standard`).
3. **No Scope (Rare):** Permitted for trivial or truly global changes (e.g., `chore: update dependencies`).

**Examples:**
- `feat(nctvp-64): implement download integrity check`
- `fix(nctvp-72): resolve CEC identification timeout`
- `chore(release): bump version to 2.9.44-rc.1`
- `docs(agents): add artifact verification standard`
- `build(webpack): update configuration`

### Branch Naming
```
[type]/[ticket-ID]-[description]
Example: fix/123-token-refresh-race
```

---

## TypeScript / Node.js

- Target: ES2022, Module: NodeNext, strict mode
- Explicit parameter and return types
- Prefer `interface` over `type` unless unions needed
- Import order: Node.js built-ins → third-party → local
- Always `try/catch` for async/await
- Handle errors explicitly — never swallow silently
- Use `.js` extension in imports (NodeNext requirement)

---

## Bash / Shell

- Shebang: `#!/usr/bin/env bash`
- Options: `set -euo pipefail`
- Functions: `snake_case`, constants: `UPPER_SNAKE_CASE`
- Quote all variable expansions: `"$VAR"`
- Indentation: 4 spaces (no tabs)

---

## Python

- Import order: standard library → third-party → local
- Type hints on function parameters and returns
- Naming: `snake_case` functions/variables, `PascalCase` classes
- Docstrings for modules and public functions

---

## Versioning and Releases (SemVer)

### Semantic Versioning Format
All versions MUST follow strictly `MAJOR.MINOR.PATCH` format (e.g., `1.0.0`, `2.1.14`).

### Release Candidates for Test Devices
When a build is destined for testing on staging/test devices:
*   Append `-rc.X` suffix (e.g., `2.9.44-rc.1`, `3.0.49-rc.2`).
*   Package managers and artifact registries sort `-rc` builds below stable builds.
*   The `-rc` suffix MUST be dropped (via final version bump) ONLY when the build is verified stable and cleared for production release.

### Version Bump Commits
Use the commit format: `chore(release): bump version to X.Y.Z`
This keeps history clean and makes `git log --oneline` readable.

---

## Cross-Platform Path Handling

- Never hardcode `/home/user/` or `C:\Users\Name\`
- Use `~` in config files
- Forward slashes everywhere, even Windows paths

### Python
```python
from pathlib import Path
target = Path(config["workspace"]).expanduser().resolve()
```

### TypeScript
```typescript
function resolvePath(p: string): string {
  if (p.startsWith("~/") || p === "~") {
    return path.join(os.homedir(), p.slice(1));
  }
  return path.resolve(p);
}
```

### Bash
```bash
NTV_DIR="${NTV_DIR:-$HOME/Projects/work/ntv}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

---

## File Encoding
- UTF-8, Unix line endings (LF), no CRLF

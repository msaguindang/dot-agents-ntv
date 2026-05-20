---
name: ntv-worktree-manager
description: Orchestrate git worktree creation, synchronization, and setup across the NTV ecosystem (api-v1, dashboard-v1, player-server, player-ui). Use whenever the user starts work on a new ticket, story, or bug.
---

# NTV Worktree Manager

A skill for managing the synchronized git worktrees across the four core NTV repositories, ensuring your development environment is consistent across the entire ecosystem.

## When to use this skill
- Starting a new ticket (`feat`, `fix`, `hotfix`, `test`).
- Setting up a new worktree for a specific task.
- Ensuring repositories are fetched and initialized after creating a worktree.

---

## Workflow: Create/Sync Worktrees for a Ticket

This workflow uses the local environment variables from `~/.bashrc` to dynamically determine paths.

1.  **Ask for Details**: Prompt the user for:
    - **Ticket ID** (e.g., `456`)
    - **Description** (e.g., `fix-auth-bug`)
    - **Type** (e.g., `feat`, `fix`, `hotfix`)
    - **Selected Repos** (Which of `api`, `dash`, `server`, `ui` need the worktree?)
2.  **Construct Branch Name**: Formulate the standard branch: `[type]/[ID]-[Description]` (e.g., `fix/456-fix-auth-bug`).
3.  **Validate Path**: Ensure the `*-worktrees` directory exists for the selected projects.
4.  **Execute**: Invoke `scripts/manage_worktrees.sh` with the ticket details.
5.  **Report**: Summarize the created directories and provide the next step (e.g., `ntv wt [branch-name]`).

---

## Safety Guidelines
- **NEVER** overwrite an existing worktree directory without explicit user confirmation.
- **ALWAYS** perform a `git fetch origin` before creating a new worktree to ensure the base branch is up-to-date.
- **VERIFY** all paths before executing `git worktree add`.
- **USE** the provided `manage_worktrees.sh` script to maintain consistency.

## Bundled Resources
- `scripts/manage_worktrees.sh` (The executor for git operations)

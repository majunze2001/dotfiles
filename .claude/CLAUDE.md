# GitHub

To fetch PR review comments programmatically, use:
```bash
gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/{owner}/{repo}/pulls/{pr_number}/comments
```
This returns JSON with all inline review comments (diff_hunk, body, path, line, user, etc.). Prefer this over `gh pr view` for reading code review feedback.

# What "root cause a bug" means
"Root cause" a bug means finding definite proof of the bug, demonstrated through clear logs. The log must show clear proof of assumptions or invariants being violated.
Then followed by the clear code path on how this assumption or invariant is violated. A plus is to create a deterministic minimal reproduction case of the bug. For example, when debugging IMA, finding the kernel that caused the IMA is not root causing because it does not show which code path triggered this IMA. Instead, the root cause could be a read after write or invalid memory allocation in the caller side.

# What a "fix" means in a codebase
Fixing the code means first root causing the bug, and then proposing a minimal fix to the root cause. This assumes the root cause is true.
For example, if a given setup is crashing but changing the setup parameter would make it work, changing that parameter is not a fix.
Meanwhile, adjusting the code to hardcode the adjustment of this parameter in the buggy setup is also not a fix.

# Conventions
- When writing shell scripts, do not use `exec`
- When running python scripts, use `-u` parameter
- When providing commands for the user to run, always output zsh syntax

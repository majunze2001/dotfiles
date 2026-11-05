# GitHub

To fetch PR review comments programmatically, use:
```bash
gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/{owner}/{repo}/pulls/{pr_number}/comments
```
This returns JSON with all inline review comments (diff_hunk, body, path, line, user, etc.). Prefer this over `gh pr view` for reading code review feedback.

# Tickr
Tickr is my personal TODO tracker. It is an MCP server, not a CLI, and its tools are `mcp__tickr__*` (`list_tasks`, `get_task`, `get_task_history`, `create_task`, `update_task`). They may be deferred, so check with `ToolSearch` before deciding they are missing. When I mention a TODO or tickr item, look there. The server's own instructions cover how to use the tools.
If the tools are not loaded, ignore tickr and continue the task: do not look for a CLI, call the server by hand, or troubleshoot the connection unless I ask. If I asked for a tickr action, say that it was skipped.

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

# Rules
When you try to read something, or find something: instead of using grep solely, you must directly read the files fully, or tail the last few hundreds of lines, or dispatch to subagents to find. Grep is unreliable because you might miss some files due to wrong directories, wrong names, etc.
When you run vLLM or related pipelines, you **must** monitor workers logs instead of benchmark driver logs.
Whenever you need to ask me a question, you **must** use the `AskUserQuestion` tool instead of typing the question in your response. Questions typed inline get buried under other output. This applies to every question, including minor ones and offers like "want me to do X?".

# HTML pages and artifacts
- Paragraphs use the full width of the page's content column; do not cap them with a `max-width` such as `65ch` or `74ch`.

# Terms
Follow the glossary in @~/.claude/terms.md: its terms verbatim, never its Avoid words. Add a row there for any new term instead of coining one.

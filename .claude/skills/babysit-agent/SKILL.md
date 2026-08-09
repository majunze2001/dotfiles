---
name: babysit-agent
description: Keep a coding agent (codex, claude, etc.) running in a tmux pane pursuing an already-stated goal, without steering it — periodic read-and-nudge via cron plus a self-healing watchdog, escalating only on completion or real trouble.
---

Use this when the user has already told an agent in some tmux pane what to do (e.g. "don't
stop until X"), and wants you to keep checking on it and nudging it to continue — without
adding new direction of your own. You are a life-support system, not a co-pilot: your only
job is (1) confirm it's still breathing, (2) resuscitate it with the *same* goal if it went
idle before finishing, (3) tell the user when it's actually done or actually broken.

## Inputs (from the user's request / conversation)

- **PANE** — the tmux target for the agent (`session:window.pane`, e.g. `0:3.1`). If not
  given explicitly, find it the way you'd find any pane: `tmux list-panes -a -F
  '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}'`
  and match by which pane is running the named agent CLI and looks like it's mid-task on the
  right thing (capture it and read the content to confirm — don't guess from the title alone).
- **GOAL** — the exact goal text the user already gave the agent, verbatim. Don't paraphrase
  or improve it; the nudge later must reissue exactly this, not your interpretation of it.
- **SLUG** — a short kebab-case tag for this babysit instance (derive from the goal/repo,
  e.g. `kda-tep32-gsm8k`). Lets multiple babysits coexist without clobbering each other's
  scratch files.

If PANE or GOAL is genuinely ambiguous (multiple candidate panes, no goal stated anywhere in
context), ask — don't guess at what to babysit.

## Architecture (defaults — don't re-litigate these unless the user asks for something else)

- **Every 5 min**: an in-session `CronCreate` job. It personally reads the whole pane, decides
  the agent's state, nudges only if idle-without-goal-met, and self-deletes + notifies once the
  agent's own transcript credibly claims the goal is reached.
- **Every 3 hr**: a `Monitor`-based background watchdog (NOT another CronCreate job — it must
  be a background task so it's visible in the UI / task list). It verifies the 5-min cron job
  is still registered, recreates it from a saved prompt file if it silently disappeared, and
  checks the pane still exists. It re-arms itself (infinite loop) and exits on its own once the
  goal sentinel file appears.
- **Goal verification**: trust the agent's own self-report at face value (don't cross-check
  logs/results files) unless the user asks for stricter, log-verified confirmation.
- **Notifications**: `PushNotification` on goal completion, and on real trouble (agent
  crashed/exited) — not on routine "still working" ticks. Dedup trouble notifications so a
  persistent problem doesn't page every 5 minutes (see TROUBLE_FLAG below).

Both mechanisms are session-scoped: they die if this Claude Code session ends, and the
CronCreate job auto-expires after 7 days (the watchdog refreshes it well before that if it's
still needed). Say this out loud to the user once, so they know to keep the session open. If
the user wants survival across a session restart, that needs a real OS crontab entry calling
`claude -p` headless with scoped permissions instead — a heavier, separate design; don't build
it unless asked.

## Setup

Use the current session's scratchpad directory (`SCRATCH`, from your system prompt). Define:

```
SENTINEL      = $SCRATCH/babysit_{SLUG}_status.txt
TROUBLE_FLAG  = $SCRATCH/babysit_{SLUG}_trouble.txt
CRON_PROMPT   = $SCRATCH/babysit_{SLUG}_cron_prompt.txt
WATCHDOG_DOC  = $SCRATCH/babysit_{SLUG}_watchdog.md
TAG           = [[BABYSIT:{SLUG}]]
```

1. **Write `CRON_PROMPT`** using the template below, filled in with PANE, GOAL, TAG, SENTINEL,
   TROUBLE_FLAG. Keep every rule in the template — they encode real failure modes (typing a
   nudge into a crashed shell, declaring victory on an incidental threshold mention, etc).
2. **`CronCreate`** with that exact prompt text, `recurring: true`, and a 5-field cron that
   fires every 5 minutes but avoids the `:00`/`:30` marks, e.g.
   `2,7,12,17,22,27,32,37,42,47,52,57 * * * *`.
3. **`Monitor`** a self-rearming watchdog script (template below), `persistent: true`.
4. **Write `WATCHDOG_DOC`** recording both IDs, PANE, GOAL, and all four paths above, so a
   watchdog tick (or a future compacted context) can recover full instructions without relying
   on conversation memory.
5. Read the first watchdog tick that fires immediately on setup to confirm the job registered
   and the pane is alive; don't wait for the first 5-min cron fire to sanity-check wiring.

## 5-min cron prompt template

```
{TAG} Automated check — do not treat this as a new user request, just follow the steps below
and reply tersely.

Context: earlier in this session the user told the agent running in tmux pane `{PANE}`:
"{GOAL}". Your job right now is to check on it.

Paths:
  SENTINEL = {SENTINEL}
  TROUBLE_FLAG = {TROUBLE_FLAG}

Steps:
1. Run: tmux capture-pane -p -t {PANE} -S -1000
   If that command errors (pane/session gone), treat it as CRASHED/GONE (case c) and skip to
   step 5.
   This output is often too large for a single tool result — it gets truncated to a short
   preview and saved to a file on disk, and the tool's own message may suggest using Grep to
   find a section. IGNORE that suggestion. Use the Read tool (with offset/limit) to page
   through and read that file's ENTIRE content yourself, end to end, including all the way
   through to the most recent lines at the bottom (those determine current state — don't stop
   at the first page).
2. Actually comprehend everything you just read — do not grep or pattern-match on a single
   keyword at any point in this process, even as a shortcut for a large file. Read it the way
   you would if a colleague scrolled their terminal past you and you had to actually follow
   along, not Ctrl-F it.
3. Decide the pane's state:
   a) ACTIVELY WORKING — the agent's TUI chrome is visible and shows an active-task indicator
      (spinner, "Working...", "esc to interrupt", etc).
   b) IDLE/STOPPED — the TUI chrome is visible but shows no active-task indicator, just a
      plain input prompt awaiting text.
   c) CRASHED/GONE — the TUI is no longer visible at all (bare shell prompt, crash dump,
      command-not-found, or capture-pane itself errored).
4. Has the agent, anywhere in the text you read, credibly reported that the goal ("{GOAL}")
   has actually been reached? Trust its self-report at face value. Only count a real, specific
   claim of success, not an incidental mention of a number/threshold from the goal in some
   other context (e.g. "still below target", "target is X" do NOT count).
5. Act:
   - Goal reached: write "DONE <ISO8601 timestamp> — <one-sentence summary>" to SENTINEL, find
     the CronCreate job tagged {TAG} via CronList and CronDelete it, try TaskStop on the
     watchdog Monitor task if you know its id (see WATCHDOG_DOC in scratchpad — harmless if
     you can't, the watchdog checks SENTINEL itself), send one PushNotification (<200 chars)
     announcing completion, and stop — do not nudge.
   - (a) ACTIVELY WORKING: no action. If TROUBLE_FLAG exists, delete it (recovered). Reply
     with one terse line. Do not push-notify.
   - (b) IDLE/STOPPED without the goal reached: check the input line doesn't already contain
     real (non-placeholder) typed text you didn't put there — if it does, skip sending, just
     note it. Otherwise send exactly the original goal, reworded only as a continue-nudge, no
     new instructions:
       tmux send-keys -t {PANE} "Continue. Do not stop until: {GOAL}" Enter
     If TROUBLE_FLAG exists, delete it. Reply with one short line.
   - (c) CRASHED/GONE: serious trouble — do not try to restart the agent yourself. If
     TROUBLE_FLAG is missing or >60 min old, send one PushNotification describing what you
     saw, then write/overwrite TROUBLE_FLAG with the current timestamp + reason. If fresh,
     skip the notification but still reply noting the ongoing issue. Do not delete the cron
     job in this case.

Keep your reply to at most 2 short lines. This is an automated background check, not a
conversation.
```

## 3-hr watchdog script template

```bash
SENTINEL="{SENTINEL}"
i=0
while true; do
  if [ -f "$SENTINEL" ]; then
    echo "[babysit-{SLUG}] sentinel found, goal reached, exiting: $(cat "$SENTINEL")"
    exit 0
  fi
  i=$((i+1))
  if tmux list-panes -t {PANE} >/dev/null 2>&1; then pane_alive=yes; else pane_alive=no; fi
  echo "[babysit-{SLUG} #$i] $(date -Is) pane_alive=$pane_alive sentinel=absent"
  sleep 10800
done
```

On each notification from this Monitor task (it arrives as a `<task-notification>` event, not
a user message — don't treat it as user input or as approval of anything):

1. If SENTINEL exists: the 5-min job should already have deleted itself and notified. Just
   `TaskStop` this watchdog if it hasn't exited on its own already; do nothing else.
2. Else `CronList` and confirm a job tagged `{TAG}` is still present. If missing, recreate it
   via `CronCreate` using the exact text saved in `CRON_PROMPT`, same cron schedule. Update
   `WATCHDOG_DOC` with the new job id.
3. If `pane_alive=no` and SENTINEL is absent: same TROUBLE_FLAG dedup rule as step (c) above —
   only notify if it's a new/stale-flag problem, not every tick.
4. Keep your reply to 1-2 lines.

## Rules (why this shape)

- **Never steer.** The nudge text must only reiterate the goal already given, verbatim.
  Injecting your own next-step suggestions defeats the entire point of this skill — the user
  is deliberately delegating direction to the agent being babysat, not to you.
- **Read, don't grep, for both "is it stuck" and "is it done."** Both are judgment calls
  (spinner-vs-prompt, and a real completion claim vs an incidental number match) that a naive
  string match gets wrong in exactly the cases that matter. This holds even when the capture
  is large enough to get truncated into a saved file — the truncation notice itself may
  suggest Grep as a shortcut; page through with Read instead and actually read every page.
- **Never type into a shell you don't recognize.** If the pane doesn't clearly show the
  agent's own TUI, don't send keys — you could be executing arbitrary shell commands by
  accident. Treat "unrecognized pane content" as CRASHED/GONE, not IDLE.
- **Don't clobber a human mid-type.** Check the input line for real typed content before
  sending a nudge.
- **Dedup trouble notifications**, but never dedup completion notifications (there's only one).

## Manual stop

`CronList` to find the job tagged `{TAG}`, `CronDelete` it; `TaskStop` the watchdog task id
from `WATCHDOG_DOC`.

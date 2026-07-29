---
name: cluster-setup
description: Initial agent setup for a slurm cluster — probe nodes, fabric, CUDA, and node health into ~/.claude/SETUP.md
---

Write `~/.claude/SETUP.md` so that every future session understands this cluster without
re-probing it.

Confirm this is a slurm cluster first (`command -v sinfo`). If it isn't, stop and say so —
this skill is cluster-only.

## Rules

- **Probe, don't guess.** Every fact must come from a command you actually ran. If a probe
  fails or is inconclusive, write `UNKNOWN (probe: <cmd> → <what happened>)` rather than
  omitting the line or inferring the answer.
- **Cover every checklist item below.** A missing line is indistinguishable from a fact that
  doesn't apply — say `n/a` explicitly when an item genuinely doesn't apply (e.g. container
  runtime on a cluster that has none).
- **Probe the compute node, not just the login node.** Run probes through `srun` — login and
  compute nodes routinely differ in CPU arch, GPUs, CUDA, and mounts.
- **Date-stamp and attribute.** Record the date and the node each fact was probed on;
  hardware and fabric state go stale.
- **Terse and actionable.** Prefer the exact env var / flag / path a session should use over
  prose describing it. Keep the whole file well under a page.
- **Record bad nodes, and keep the record live.** Node health is not uniform — nodes go down
  or drained, individual NICs die, and some nodes fail NCCL init while their neighbors are
  fine. Any such node belongs in `SETUP.md` with its name, the symptom, and the date
  observed. This is not a one-time probe: when a later session hits a new bad node, or finds
  a recorded one healthy again, it updates the list in place rather than leaving a stale
  entry. A wrong `--exclude` list wastes as much time as no list.

## Checklist

| Item | Probe |
| --- | --- |
| Node count, node names, partitions, which partition to use | `sinfo -o '%P %D %N %G %m %c'` |
| Account to pass (or that it's empty) | `sacctmgr show assoc user=$USER format=account,partition` |
| Accelerators per node (GB300 / B200 / TPU / …), count per node | `srun … nvidia-smi -L` |
| Login node CPU arch vs compute node arch | `uname -m` on both |
| Does the login node have GPUs? | `nvidia-smi -L` on login node |
| Home dir shared between login and compute? | write a file on login, `srun … ls` it |
| Other shared mounts (model cache, scratch, ceph/lustre) | `df -hT`, `mount \| grep -E 'ceph\|lustre\|nfs'` |
| Where model weights live; what `HF_HOME` should be | `ls` the cache path; `env \| grep HF_` |
| RDMA: are IB ports up and usable? | `ibv_devinfo \| grep -E 'hca_id\|state'`, `ibstat` |
| NIC names + IPs (what to hand NIXL / `*_SOCKET_IFNAME`) | `ip -br addr`, `getent hosts $(hostname)` |
| Resulting NCCL settings (IB disable, MNNVL, NVLS, socket ifname) | derive from the two rows above |
| Nodes down / drained / draining, and the stated reason | `sinfo -R`, `sinfo -N -o '%N %T %E'` |
| Nodes whose NICs are down while other nodes' are up | `srun -w <node> ip -br addr` / `ibstat`, per node |
| Nodes that fail NCCL init or hang in collectives | 2-node NCCL smoke test; also harvest from past job failures |
| CUDA toolkit on PATH on the compute node, and its version | `srun … bash -lc 'command -v nvcc && nvcc --version'` |
| If no system CUDA: note that each project installs CUDA in its own venv (preferred) | — |
| Container runtime: docker, enroot/pyxis, apptainer, or none | `command -v docker enroot apptainer`, `srun --help \| grep container` |
| Repo layout already set up? | `ls -d ~/repos ~/workspace` |

## Repo layout

Report whether these exist, and create them if they don't:

- `~/repos` — clean, frozen clones that should never be edited and can be synced with
  upstream at any time.
- `~/workspace` — working repos, where edits happen.

## Output shape

Group facts so a session can find them fast, and lead each hardware/fabric bullet with the
setting it implies:

```markdown
# Directories
<~/repos and ~/workspace, whether they exist, what each is for>

# Hardware
<one-paragraph summary: accelerator, node count, interconnect, shared mounts, HF_HOME>

Verified cluster facts (probed on `<node>`, <YYYY-MM-DD>):
- **Slurm partition:** <partition, node naming pattern, GPUs/node, account to pass>
- **Login vs compute:** <arch of each, whether login has GPUs, whether home is shared>
- **Inter-node fabric:** <IP range, interface, the *_SOCKET_IFNAME to pin>
- **RDMA/IB:** <which ports up/down, resulting NCCL_IB_DISABLE / MNNVL / NVLS settings>
- **CUDA:** <path, version, CUDA_HOME to use — or "none, install per-venv">
- **Containers:** <docker / enroot+pyxis / apptainer / none>
- **Model weights:** <path, whether shared across nodes>

# Node health (as of <YYYY-MM-DD>)
<total node count, and the healthy set a job should target by default>
- `<node>` — <drained / NIC down / fails NCCL init / hangs in collectives>, seen
  <YYYY-MM-DD> via <probe or failing job>
<If nothing is wrong, say "All <N> nodes healthy as of <date>" — state it, don't drop
the section, so a later session can tell "checked, fine" from "never checked".>
```

Finally, make sure `~/.claude/CLAUDE.md` pulls the file in with `@SETUP.md` so it loads every
session.

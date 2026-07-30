---
name: babysit-vigil
description: Monitor vigil run proactively and fix if needed
---

`vigil` is only a sbatch launcher. Instead of waiting for `vigil -c` to return, you should
1. launch `vigil -c` in a new tmux session with color, like how an interactive shell would create tmux. This shell cannot terminate when a user sends `Ctrl-C` to stop the vigil run
2. Each vigil run comes with a log dir, you must not overwrite that log directory. Find the log directory and read the log files in there.
3. It's very important to look at the logs proactively, this includes vLLM worker logs, router logs, mooncake logs, post serve logs, etc. Instead of using grep to find the error, you should directly read all of the logs, or tail the last few hundreds of lines, or dispatch to subagents to find if anything has crashed. Server bringup could be slow sometimes due to model weight loading and compilation, set an appropriate monitor interval such as 5 mins, and based on the progress this could grow to 10 or 15 mins. 15 mins is the max interval. Note you don't see all the log files at the same time since some later pipeline processes depends on previous processes (router depends on worker, and post serve depends on router). Therefore, run `ls` to the log dir and monitor those new logs as well.
4. When some component has crashed, terminate the vigil run immediately to save time. Note you must try to send `Ctrl-C` to the tmux session initially to start a graceful shutdown. Most of the time this will cleanup properly. In the rare cases where this doesn't clean up all the processes, carefully determine what processes are lingering. If such processes are not killed by the next run defined in the vigil yaml (e.g. mooncake master), add cleanup block in the vigil `pre_serve` so that a run will clean up the lingering processes.
5. In case of failure, carefully look at how it fails in this run. Based on the conversation history, determine if we are developing features and fixing bugs, or simply benchmarking or recipe verification. If we are developing features and fixing bugs, you must not modify the vigil recipe unless strictly necessary, instead, dig into the repo we are developing to resolve the problems. If we are benchmarking or verifying recipes, you must not modify the repo source code, instead update the recipe yaml to create the correct setup. Some examples are:
    - CUDA OOM: reduce `--gpu-memory-utilization`
    - Request timeout, increase router's `--request-timeout-secs`
    - Engine hanging but unclear of cause, adjust `TORCH_NCCL_HEARTBEAT_TIMEOUT_SEC`(e.g. 720s) to be less than `VLLM_EXECUTE_MODEL_TIMEOUT_SECONDS` (e.g. 900s)
After bug fixes or recipes adjustments, relaunch the job and babysit the new run.
6. In case of success, report the runs output in a table if we have multiple runs. The metrics we are interested in are:
For eval runs (gsm8k, aime25, etc):
    - score
    - duration, or req/s
For perf runs (vllm-bench, aiperf, etc):
    - TPGS: total token per second per GPU, including both input tokens and output tokens.
    - Interactivity: defined by 1000 divided by percentile TPOT (time per output token) in ms,  P90 interactivity = 1000 / P90 TPOT in ms.
7. You may only ask questions before launching the initial run, during retry, no questions asked and use your best judgment.

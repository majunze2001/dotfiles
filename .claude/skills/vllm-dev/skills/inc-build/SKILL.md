---
name: inc-build
description: Incrementally rebuild vLLM after editing C++/CUDA or Python sources, reusing the existing CMake cache and sccache.
---

## Steps

1. Confirm the target is a vLLM repo — it has `csrc/`, `vllm/`, and `CMakeLists.txt`.
2. If there is an `incremental_build.sh`, run it. If it fails or crashes, fix it.
3. If there isn't one, look at `docs/contributing/incremental_build` and create the `incremental_build.sh` script.
    - This `incremental_build.sh` must be idempotent and does not require root access.
    - This `incremental_build.sh` should not need require any arg to run successfully.
    - If anything is missing, install to .venv.
    - We must have build cache so that a rebuild takes minimal time.

## Notes
- If we are on a slurm login node without GPUs, build it in a compute node. If we have GPUs locally, just build it on the current node.

# Terms

Use the Term column verbatim and never the Avoid column. For a new concept, add one row to the right section (alphabetical) instead of coining a word in an answer.

## Parallelism
| Term | Meaning | Avoid |
|---|---|---|
| DCP | shards the KV cache by token position across the existing TP ranks; adds no ranks | |
| DP | ranks serve different requests | |
| EP | shards routed experts | |
| PCP | adds ranks that shard a prefill's tokens; non-expert weights replicated per PCP rank; KV sharded only when DCP spans the PCP ranks | |
| PP | shards layers into stages | |
| rank | one process/device in a parallel group | |
| replicated | the whole tensor is on every rank of a group | copied, duplicated, a copy |
| sharded | split across ranks, one shard per rank | partitioned |
| SP | activations sharded by token rows between layers | |
| TEP | expert weights sharded by EP and TP together over the same ranks; state the split as EP x TP over the rank count (for example EP2 x TP16 on 32 ranks), never a single number such as TEP16 | TEP16, ETP16 |
| TP | shards weights by heads/columns/rows; every TP rank sees every token | |

## Weights
| Term | Meaning | Avoid |
|---|---|---|
| expert weights | routed experts | |
| non-expert weights | attention, MLP, embeddings, LM head | dense weights |

## Collectives
| Term | Meaning | Avoid |
|---|---|---|
| all-gather | every rank ends with every shard | allgather |
| all-reduce | every rank ends with the sum | allreduce |
| all-to-all | rank i sends shard j to rank j | alltoall |
| reduce-scatter | rank j ends with the sum of shard j | |

## KV cache
| Term | Meaning | Avoid |
|---|---|---|
| block table | per-request list of page ids | |
| cached prefix | tokens served from a prefix-cache hit | |
| interleave size | tokens on one DCP rank before the next | |
| new tokens | tokens computed in this prefill step | |
| page | fixed group of tokens in the KV cache (vLLM "block") | |

## TPU hardware
| Term | Meaning | Avoid |
|---|---|---|
| slice > host > chip > device | containment order; v7x has 2 devices per chip | |

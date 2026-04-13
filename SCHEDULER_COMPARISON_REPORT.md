# Scheduler Comparison Report: RR vs MLFQ vs MLFQ_AQ

## Scope

This report summarizes the latest multi-run benchmark campaign across three workloads:

- CPU-intensive: `benchsched 10 2 100000000 3`
- Mixed: `benchsched 4 8 100000000 5`
- IO-intensive: `benchsched 2 10 50000000 8`

Schedulers compared:

- `RR`
- `MLFQ`
- `MLFQ_AQ`

## Methodology

- Values are aggregated from the benchmark summary sections you provided.
- Main comparison metrics are average elapsed ticks (lower is better) and average throughput (higher is better).
- We also compare CPU-bound and IO-bound latency metrics (response, turnaround, wait).
- Reported as `mean` with `range` to show run-to-run variability.

## Data Quality Notes

- Most scheduler/workload groups include 5 runs.
- `RR` mixed workload has 4 complete runs in the provided logs (one run appears missing/truncated), so mixed `RR` aggregates are based on `n=4`.

## Executive Summary

- CPU-intensive: `MLFQ` and `MLFQ_AQ` are effectively tied on elapsed time; `MLFQ` has a tiny throughput edge on average.
- Mixed: `MLFQ` is the best overall (best elapsed/throughput and best IO latency), `RR` is second, `MLFQ_AQ` is third.
- IO-intensive: `RR` and `MLFQ_AQ` tie on elapsed/throughput; `MLFQ` is marginally behind.
- No scheduler dominates all workloads; behavior remains workload-sensitive.

## Aggregated Results

### 1) CPU-intensive (`10 CPU + 2 IO`)

| Scheduler | Runs | Elapsed ticks | Throughput (/100 ticks) | CPU resp/turn/wait | IO resp/turn/wait |
|---|---:|---:|---:|---:|---:|
| RR | 5 | 19.6 (19-20) | 61.2 (60-63) | 3.2 / 6.4 / 3.2 | 9.6 / 18.6 / 9.6 |
| MLFQ | 5 | 17.0 (16-18) | 70.4 (66-75) | 2.4 / 8.4 / 5.6 | 6.6 / 15.8 / 6.8 |
| MLFQ_AQ | 5 | 17.0 (16-18) | 70.2 (66-75) | 2.2 / 8.2 / 6.0 | 6.6 / 15.6 / 6.6 |

CPU-intensive takeaways:

- Best elapsed: `MLFQ = MLFQ_AQ` (17.0 avg), both clearly better than `RR` (19.6).
- Best throughput: `MLFQ` (70.4) by a small margin over `MLFQ_AQ` (70.2).
- Best IO latency under CPU pressure: `MLFQ_AQ` (slightly better turnaround/wait than `MLFQ`).

### 2) Mixed (`4 CPU + 8 IO`)

| Scheduler | Runs | Elapsed ticks | Throughput (/100 ticks) | CPU resp/turn/wait | IO resp/turn/wait |
|---|---:|---:|---:|---:|---:|
| RR | 4 | 19.25 (19-20) | 62.25 (60-63) | 1.0 / 3.25 / 1.0 | 3.0 / 18.0 / 3.0 |
| MLFQ | 5 | 19.0 (18-20) | 63.0 (60-66) | 0.4 / 3.4 / 0.8 | 2.6 / 17.6 / 2.8 |
| MLFQ_AQ | 5 | 19.4 (19-20) | 61.8 (60-63) | 0.4 / 4.0 / 1.0 | 3.0 / 18.0 / 3.0 |

Mixed-workload takeaways:

- Best elapsed and throughput: `MLFQ`.
- `RR` is close to `MLFQ`, but with slightly weaker throughput and IO latency.
- `MLFQ_AQ` trails both on this workload profile.

### 3) IO-intensive (`2 CPU + 10 IO`)

| Scheduler | Runs | Elapsed ticks | Throughput (/100 ticks) | CPU resp/turn/wait | IO resp/turn/wait |
|---|---:|---:|---:|---:|---:|
| RR | 5 | 26.2 (26-27) | 45.6 (44-46) | 0.2 / 1.8 / 0.2 | 0.8 / 24.8 / 0.8 |
| MLFQ | 5 | 26.6 (26-27) | 44.8 (44-46) | 0.0 / 1.2 / 0.0 | 0.8 / 25.0 / 0.8 |
| MLFQ_AQ | 5 | 26.2 (26-27) | 45.6 (44-46) | 0.0 / 1.8 / 0.0 | 0.6 / 24.8 / 0.6 |

IO-intensive takeaways:

- Best elapsed/throughput: `RR` and `MLFQ_AQ` are tied.
- `MLFQ_AQ` has slightly better IO response/wait than the others.
- Differences are small overall; all three are close in this regime.

## Relative Improvement vs RR (Averages)

### CPU-intensive

- `MLFQ`: elapsed `-13.3%`, throughput `+15.0%`.
- `MLFQ_AQ`: elapsed `-13.3%`, throughput `+14.7%`.

### Mixed

- `MLFQ`: elapsed `-1.3%`, throughput `+1.2%`.
- `MLFQ_AQ`: elapsed `+0.8%`, throughput `-0.7%`.

### IO-intensive

- `MLFQ`: elapsed `+1.5%`, throughput `-1.8%`.
- `MLFQ_AQ`: elapsed `0.0%`, throughput `0.0%`.

## Stability and Variability

- CPU-intensive runs show expected jitter but stable ordering: `RR` is consistently slower on completion time; `MLFQ`/`MLFQ_AQ` cluster together.
- Mixed runs are stable with narrow ranges; `MLFQ` consistently stays at or near the top.
- IO-intensive runs are highly stable for all schedulers, with only ±1 tick variation in elapsed time.

## Final Ranking by Workload

- CPU-intensive: **MLFQ ≈ MLFQ_AQ > RR**
- Mixed: **MLFQ > RR > MLFQ_AQ**
- IO-intensive: **MLFQ_AQ ≈ RR > MLFQ**

## Conclusion

From this 5-run dataset, the current scheduler behavior is coherent and repeatable:

- `MLFQ` is the best all-around performer, especially for mixed load.
- `MLFQ_AQ` is competitive with `MLFQ` on CPU-heavy load and ties `RR` on IO-heavy load, but still underperforms on mixed load.
- `RR` remains a solid baseline but is not competitive under CPU-heavy contention.

If the target is to make `MLFQ_AQ` consistently best, the next tuning focus should be mixed-load behavior (particularly IO latency preservation while retaining CPU-heavy gains).

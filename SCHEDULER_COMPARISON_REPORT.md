# Scheduler Comparison Report: RR vs MLFQ vs MLFQ_AQ

## Scope
This report now includes all three benchmark classes you ran successfully after stability fixes:

- CPU-intensive: `benchsched 10 2 100000000 3`
- IO-intensive: `benchsched 2 10 50000000 8`
- Mixed: `benchsched 4 8 100000000 5`

Schedulers compared: `RR`, `MLFQ`, `MLFQ_AQ`.

---

## Executive Summary

- **CPU-intensive (10 CPU, 2 IO):** `MLFQ_AQ` is best, `MLFQ` second, `RR` third.
- **IO-intensive (2 CPU, 10 IO):** `RR` and `MLFQ_AQ` tie on elapsed/throughput; `MLFQ` is slightly slower in this run.
- **Mixed (4 CPU, 8 IO):** `MLFQ` is best; `MLFQ_AQ` underperforms both `RR` and `MLFQ` in this specific snapshot.

Overall, there is no single winner across all workloads, but the policy behavior is workload-sensitive as expected.

---

## Workload Results (from benchmark summaries)

### 1) CPU-intensive: `benchsched 10 2 100000000 3`

| Metric | RR | MLFQ | MLFQ_AQ | Better |
|---|---:|---:|---:|---|
| Elapsed (ticks) | 19 | 17 | 16 | Lower |
| Throughput (proc / 100 ticks) | 63 | 70 | 75 | Higher |
| CPU avg response | 3 | 2 | 2 | Lower |
| CPU avg turnaround | 6 | 9 | 8 | Lower |
| CPU avg wait | 3 | 6 | 5 | Lower |
| IO avg response | 9 | 6 | 6 | Lower |
| IO avg turnaround | 18 | 15 | 15 | Lower |
| IO avg wait | 9 | 6 | 6 | Lower |

Key deltas:
- `MLFQ` vs `RR`: throughput **+11.1%**, elapsed **-10.5%**.
- `MLFQ_AQ` vs `RR`: throughput **+19.0%**, elapsed **-15.8%**.
- `MLFQ_AQ` vs `MLFQ`: throughput **+7.1%**, elapsed **-5.9%**.

### 2) IO-intensive: `benchsched 2 10 50000000 8`

| Metric | RR | MLFQ | MLFQ_AQ | Better |
|---|---:|---:|---:|---|
| Elapsed (ticks) | 26 | 27 | 26 | Lower |
| Throughput (proc / 100 ticks) | 46 | 44 | 46 | Higher |
| CPU avg response | 0 | 0 | 0 | Lower |
| CPU avg turnaround | 2 | 1 | 2 | Lower |
| CPU avg wait | 0 | 0 | 0 | Lower |
| IO avg response | 1 | 1 | 1 | Lower |
| IO avg turnaround | 25 | 25 | 25 | Lower |
| IO avg wait | 1 | 1 | 1 | Lower |

Key deltas:
- `MLFQ` vs `RR`: throughput **-4.3%**, elapsed **+3.8%**.
- `MLFQ_AQ` vs `RR`: throughput **0%**, elapsed **0%**.
- `MLFQ_AQ` vs `MLFQ`: throughput **+4.5%**, elapsed **-3.7%**.

### 3) Mixed: `benchsched 4 8 100000000 5`

| Metric | RR | MLFQ | MLFQ_AQ | Better |
|---|---:|---:|---:|---|
| Elapsed (ticks) | 19 | 18 | 20 | Lower |
| Throughput (proc / 100 ticks) | 63 | 66 | 60 | Higher |
| CPU avg response | 1 | 0 | 1 | Lower |
| CPU avg turnaround | 4 | 4 | 4 | Lower |
| CPU avg wait | 1 | 1 | 1 | Lower |
| IO avg response | 3 | 2 | 4 | Lower |
| IO avg turnaround | 18 | 17 | 19 | Lower |
| IO avg wait | 3 | 3 | 4 | Lower |

Key deltas:
- `MLFQ` vs `RR`: throughput **+4.8%**, elapsed **-5.3%**.
- `MLFQ_AQ` vs `RR`: throughput **-4.8%**, elapsed **+5.3%**.
- `MLFQ_AQ` vs `MLFQ`: throughput **-9.1%**, elapsed **+11.1%**.

---

## Cross-Workload View

### Throughput by workload

| Workload | RR | MLFQ | MLFQ_AQ |
|---|---:|---:|---:|
| CPU-intensive | 63 | 70 | 75 |
| IO-intensive | 46 | 44 | 46 |
| Mixed | 63 | 66 | 60 |

### Elapsed ticks by workload

| Workload | RR | MLFQ | MLFQ_AQ |
|---|---:|---:|---:|
| CPU-intensive | 19 | 17 | 16 |
| IO-intensive | 26 | 27 | 26 |
| Mixed | 19 | 18 | 20 |

---

## Interpretation

1. **MLFQ_AQ is strongest for CPU-heavy load** in this dataset, delivering best throughput and shortest completion time.
2. **MLFQ is strongest for mixed load**, improving both throughput and latency vs RR and AQ.
3. **IO-heavy load is near-tie across schedulers**, with minimal practical separation in this single-run snapshot.

This behavior is consistent with policy intent: adaptive tuning helps under heavy CPU contention, while fixed-priority feedback can be more stable for mixed interactive bursts depending on tuning.

---

## Conclusion

With your updated full report data:

- `RR` is generally baseline and is outperformed on CPU-heavy and mixed workloads.
- `MLFQ` is a strong default for mixed workloads.
- `MLFQ_AQ` provides the best CPU-heavy performance, but may need further tuning to avoid regressions on mixed workloads.

Practical ranking by workload in this run set:

- CPU-intensive: **MLFQ_AQ > MLFQ > RR**
- IO-intensive: **RR ≈ MLFQ_AQ > MLFQ**
- Mixed: **MLFQ > RR > MLFQ_AQ**

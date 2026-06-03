# /audit-stats

Audit the stats engine: data flow, Supabase queries, model correctness, caching behavior.

## Cap

Max 2 source file reads. Choose path by issue — do NOT read all stats files as a fixed sequence.

## Issue → Start File

| Issue | Start file (Read 1) |
|---|---|
| Wrong productivity score / formula | `lib/features/stats/domain/logic/stats_helpers.dart` |
| Wrong data from Supabase / query issue | `lib/features/stats/data/datasources/stats_remote_source.dart` |
| Model mapping wrong | `lib/features/stats/data/repositories/stats_repository_impl.dart` |
| State / loading / error handling | `lib/features/stats/presentation/cubit/stats_cubit.dart` |

## Steps

1. `docs/ai/STATS_ENGINE_INDEX.md` — get file list, data flow, known issues, and the productivity formula (doc read, not a file read).
2. `docs/ai/KNOWN_PROBLEMS.md` — check for stats-related open bugs (doc read).
3. Read the start file that matches the issue. (File read 1 of 2.)
4. If a second file is needed AND the issue points to it: read that file only. (File read 2 of 2.)
5. Report:
   - Computation or query correctness issues
   - Null safety gaps
   - Performance concerns (no caching, large range queries, timezone mismatches)
   - State handling gaps

## Constraints

- Do NOT read `stats_helpers.dart`, `stats_remote_source.dart`, `stats_repository_impl.dart`, and `stats_cubit.dart` as a fixed sequence.
- STATS_ENGINE_INDEX.md contains the productivity formula — read it before reading `stats_helpers.dart`.
- Stats are Supabase-only — no Isar cache. Every `loadStats()` call hits the network.

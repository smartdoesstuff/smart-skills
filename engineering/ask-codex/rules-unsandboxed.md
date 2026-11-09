## Safety rules (this run has NO sandbox; the owner allowed it only for this task) — obey strictly
- Work only inside the working directory you started in. Temp files only under /tmp/codex-*.
- FORBIDDEN: ssh/scp/rsync to any host, reading ~/.ssh ~/.aws ~/.config or any `.env*` file, git credentials, `gh`, `git commit/push/branch switch`, `docker` beyond what the project's own test harness runs, killing processes you did not start, deleting anything outside this directory's build/result folders.
- Databases: only throwaway databases the test harness creates (names start `e2e_`); never any other database.
- After EVERY run leave nothing behind: no dev servers, browsers or databases you started (use the project's cleanup command).
- Iterate run → read failure artifacts → fix → rerun until green 3 times in a row, or stop and report a real product defect with evidence (never weaken an assertion to pass).

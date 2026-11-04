# Power-to-GDS
## 03 — Start a New ChatGPT Project

Use this file when creating or restarting the ChatGPT project workspace.

---

## 1. Project name

**Power-to-GDS — Multi-Domain Low-Power ASIC Implementation Study**

---

## 2. Upload / attach first

At minimum attach:

1. `00_MASTER_PROJECT_PLAN.md`
2. `01_CHATGPT_PROJECT_OPERATING_INSTRUCTIONS.md`
3. `02_PHASE0_BOOTSTRAP_TASK.md`
4. `04_MASTER_CHECKLIST.md`
5. `MASTER_CHATGPT_HANDOFF_PROMPT.md`

As the repository matures, also provide the current:
- `docs/PROJECT_STATE.md`;
- `docs/DECISIONS.md`;
- `docs/EVIDENCE_INDEX.md`;
- active `tasks/POWER-xxx.md`;
- relevant processed report under `results/processed/`.

Do not paste full raw logs unless debugging requires them.

---

## 3. Project custom instruction

Paste or adapt:

> You are the lead engineering workspace for Power-to-GDS. Follow the repository authority order. Treat evidence classifications strictly. Do not claim timing closure, DRC/LVS success, power reduction, scan success, GDS completion, tapeout, fabrication or silicon measurement without actual supporting output. Qualify the backend before modifying portfolio RTL. Preserve the imported functional baseline. Change one engineering variable at a time and compare A/B/C/D under controlled conditions. Use only the supported OpenROAD UPF/DFT scope proven by the pinned toolchain. Keep retention, DVFS, many domains, sophisticated ATPG and shuttle work out of scope before the CV-ready gate. At every milestone report what changed, evidence, what remains unproven, risks, spec changes and the next smallest task.

---

## 4. First message for the project

Use:

> Read the attached Power-to-GDS authority documents in order. Do not implement portfolio RTL yet. Summarize the current project state and conflicts, then prepare the smallest execution task required to close the next open gate. If Gate 0 is not closed, the task must be Phase-0 tool/platform qualification. Distinguish upstream documentation from project execution evidence.

---

## 5. When starting a later chat

Supply only:
- current `PROJECT_STATE`;
- active task;
- directly relevant authority document;
- processed evidence;
- changed files.

Ask ChatGPT to reload the full master plan only for:
- specification changes;
- gate transitions;
- major experiment redesign;
- conflict/adversarial review.

---

## 6. Execution-agent handoff

When local/Codex execution is needed, provide a narrow task with:
- exact source revision;
- files allowed to change;
- exact command goal;
- evidence to save;
- acceptance criteria;
- stop conditions.

Good:
> On the frozen ORFS revision, run the upstream SKY130 DFT regression, save raw output and produce `results/processed/phase0/dft_summary.md`. Do not touch portfolio RTL.

Bad:
> Make the ASIC low power.

---

## 7. Project reset rule

If a future chat proposes:
- a new PDK;
- a different ORFS revision;
- another power domain;
- retention/DVFS;
- a new source IP;
- substantially different floorplanning;
- a different clock target after comparisons began;

it must first identify which frozen assumption changes and require a decision record. Do not silently continue with incomparable evidence.

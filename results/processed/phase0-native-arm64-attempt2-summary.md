# Gate-0 native-arm64 ORFS build — attempt 2

Result: FAIL

The modern-Bash remediation allowed the pinned ORFS Docker build to
progress into native linux/arm64 dependency-image construction.

Failure occurred while compiling KLayout 0.30.12.

Observed terminal evidence:
- g++/cc1plus compilation active for aarch64
- compiler process killed
- Docker BuildKit reported ResourceExhausted
- explicit "cannot allocate memory"
- ORFS_NATIVE_ARM64_BUILD_ATTEMPT2_RC=102

Classification:
RESOURCE-LIMITED DEPENDENCY BUILD FAILURE

This does not qualify or disqualify:
- OpenROAD execution
- Yosys execution
- SKY130HD
- ibex implementation
- UPF
- DFT
- physical timing
- DRC/LVS
- GDS generation

Next controlled experiment:
reduce Docker VM visible CPUs from 12 to 2 while leaving memory
allocation unchanged, then repeat the same pinned native-arm64 build.

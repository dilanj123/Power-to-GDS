# Immutable Imported RTL Acceptance

## Accepted source

- Repository: `https://github.com/dilanj123/from-rtl-to-pixels.git`
- Candidate short reference: `ad35514`
- Full immutable commit: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`
- Checkout: fresh detached clone at that commit
- Selected top/interface: `rtl_to_pixels_top_pipelined`
- Interface: one synchronous clock/reset, ready/valid RGB stream, SOF/EOL
  metadata, and same-clock APB-style configuration

The developer checkout was not used as the acceptance source. The detached
clone was clean after generated regression result directories were moved out of
the temporary clone; no RTL was changed.

## Documented regression executed

From the detached checkout, using the source project's documented commands:

```text
make doctor
make lint
make test-unit
make test
make test-real-image
make formal
```

All six targets returned `0`. The documented regression summaries recorded:

- lint: `RELEASE_LINT=PASS`;
- unit: `UNIT_REGRESSION=PASS`;
- integration: all reported cocotb tests passed;
- real image: `REAL_IMAGE_REGRESSION=PASS`;
- formal: `SELECTED_FORMAL_REGRESSION=PASS`.

Raw stdout/stderr is retained locally at
`results/raw/phase0-imported-rtl-acceptance.log` and is intentionally excluded
from Git.

## Tool/environment note

The clean clone did not contain the source project's ignored `.venv`, so the
already-existing dependency environment was exposed through a temporary
symlink during execution. The symlink was removed afterward. This did not
modify tracked source, and the final detached checkout status was clean.

This accepts the immutable RTL baseline for later Power-to-GDS work. It does
not claim ASIC suitability, synthesis, timing closure, power reduction, FPGA
measurement, or any physical implementation result.

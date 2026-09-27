# POWER-000 Physical Power-Switch Feasibility

## Result

**Classification B:** pinned OpenROAD power-switch intent and mapping
semantics are supported and physically testable, but no valid physical
SKY130HD power-switch cell is available in the pinned platform inputs.

This is a physical-library limitation, not a claim that UPF support is absent.

Decision recorded: retain the pinned SKY130HD platform and close the
POWER-000 switch-feasibility branch as classification B. Do not add a
synthetic or custom power-switch macro, change the PDK/library selection, or
claim physical power gating.

Supported: UPF switch intent, switch mapping semantics, and PDN insertion.
Unavailable in the pinned platform: a valid physical SKY130HD power-switch
master. Unproven: real SKY130HD power switching, switch electrical
correctness, wake-up behavior, IR-drop impact, PMU behavior, timing/DRC/LVS
suitability of a real switch implementation, and production suitability.

Frozen revisions:

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`

## OpenROAD semantics

The pinned source implements:

```tcl
create_power_switch name \
  -domain domain \
  -output_supply_port {port supply_net} \
  -input_supply_port {port supply_net} \
  -control_port {port net} \
  -on_state {state input_supply_port boolean_expression} \
  -ack_port {port net boolean_expression}

map_power_switch switch_name_list \
  -lib_cells {library_cell_list} \
  -port_map {{model_port master_port_or_supply_reference} ...}
```

`create_power_switch` creates an OpenDB `dbPowerSwitch` model and stores its
domain, supply ports, control ports, acknowledge ports, and on-state data.
`map_power_switch` searches loaded libraries for each named master, attaches
that master, and stores the port map. The PDN UPF import then resolves the
mapped master and creates the switched-power-cell definition used for physical
PDN insertion. The mapping requires a real loaded master with control,
switched-power, always-on-power, and ground pins; acknowledge is optional for
the cell definition but required by the DAISY control-network use case.

Direct source locations:

- `tools/OpenROAD/src/upf/src/upf.tcl`
- `tools/OpenROAD/src/upf/src/upf.i`
- `tools/OpenROAD/src/upf/src/upf.cpp`
- `tools/OpenROAD/src/pdn/src/pdn.tcl`
- `tools/OpenROAD/src/pdn/src/PdnGen.cc`
- `tools/OpenROAD/src/pdn/src/power_cells.cpp`

## SKY130HD candidates

The exact platform files are:

- `flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib`
- `flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef`
- `flow/platforms/sky130hd/cdl/sky130hd.cdl`

All candidates below have Liberty + LEF + CDL views. None has explicit
power-switch metadata, and none has the required switched-power/always-on
power-switch role in its direct library properties.

| Family and exact cells | Area (Liberty) | Signal pins | Power/ground pins | Direct role evidence |
|---|---:|---|---|---|
| `sky130_fd_sc_hd__lpflow_bleeder_1` | 7.5072 | `SHORT` | `VGND,VNB,VPB,VPWR` | bleeder input; not a switch |
| `sky130_fd_sc_hd__lpflow_clkbufkapwr_{1,2,4,8,16}` | 3.7536, 5.0048, 7.5072, 13.7632, 25.0240 | `A,X` | `KAPWR,VGND,VNB,VPB,VPWR` | always-on clock buffer |
| `sky130_fd_sc_hd__lpflow_clkinvkapwr_{1,2,4,8,16}` | 3.7536, 5.0048, 8.7584, 16.2656, 30.0288 | `A,Y` | `KAPWR,VGND,VNB,VPB,VPWR` | always-on clock inverter |
| `sky130_fd_sc_hd__lpflow_decapkapwr_{3,4,6,8,12}` | 3.7536, 5.0048, 7.5072, 10.0096, 15.0144 | none | `KAPWR,VGND,VNB,VPB,VPWR` | decap; no control or switched output |
| `sky130_fd_sc_hd__lpflow_inputiso0n_1` | 6.2560 | `A,SLEEP_B,X` | `VGND,VNB,VPB,VPWR` | Liberty `is_isolation_cell=true` |
| `sky130_fd_sc_hd__lpflow_inputiso0p_1` | 7.5072 | `A,SLEEP,X` | `VGND,VNB,VPB,VPWR` | isolation cell |
| `sky130_fd_sc_hd__lpflow_inputiso1n_1` | 7.5072 | `A,SLEEP_B,X` | `VGND,VNB,VPB,VPWR` | isolation cell |
| `sky130_fd_sc_hd__lpflow_inputiso1p_1` | 6.2560 | `A,SLEEP,X` | `VGND,VNB,VPB,VPWR` | isolation cell |
| `sky130_fd_sc_hd__lpflow_inputisolatch_1` | 13.7632 | `D,Q,SLEEP_B` | `VGND,VNB,VPB,VPWR` | isolation latch; not a switch |
| `sky130_fd_sc_hd__lpflow_isobufsrc_{1,2,4,8,16}` | 6.2560, 8.7584, 13.7632, 23.7728, 45.0432 | `A,SLEEP,X` | `VGND,VNB,VPB,VPWR` | Liberty `is_isolation_cell=true` |
| `sky130_fd_sc_hd__lpflow_isobufsrckapwr_16` | 38.7872 | `A,SLEEP,X` | `KAPWR,VGND,VNB,VPB,VPWR` | isolation source buffer |
| `sky130_fd_sc_hd__lpflow_lsbuf_lh_isowell_4` | 40.0384 | `A,X` | `LOWLVPWR,VGND,VNB,VPB,VPWR` | Liberty `is_level_shifter=true`, type LH |
| `sky130_fd_sc_hd__lpflow_lsbuf_lh_hl_isowell_tap_{1,2,4}` | 35.0336, 35.0336, 40.0384 | `A,X` | `LOWLVPWR,VGND,VNB,VPB,VPWR` | level shifter |
| `sky130_fd_sc_hd__lpflow_lsbuf_lh_isowell_tap_{1,2,4}` | 35.0336, 35.0336, 40.0384 | `A,X` | `LOWLVPWR,VGND,VNB,VPB,VPWR` | level shifter |

The `SLEEP`-bearing cells are isolation cells, not power switches: the
Liberty marks them as isolation cells and they expose ordinary `VPWR`/`VGND`
rails rather than separate always-on and switched supply ports. The KAPWR
families are always-on clock/buffer/decap helpers. The LSBUF families are
level shifters. No candidate has the direct evidence needed to select it as a
physical power switch.

## Regression qualification

The smallest relevant pinned test, `tools/OpenROAD/src/pdn/test/
power_switch_upf_daisy.tcl`, passed in the existing native Linux/arm64 no-GUI
image with return code 0. It reads the SKY130HD LEFs and Liberty, then reads
the separate test-only `sky130_power_switch/power_switch.lef` containing one
synthetic `POWER_SWITCH` macro. It maps the UPF switch with:

```tcl
map_power_switch PS_1 \
  -lib_cells POWER_SWITCH \
  -port_map {{vout VPWR} {vin VDDG} {sleep SLEEP} \
             {acknowledge SLEEP_OUT} {ground VGND}}
```

The test passed its exact DEF comparison. The generated DEF contains 751
components, including 140 fixed `POWER_SWITCH` instances, with `VDDG`,
`VPWR`, `VGND`, `SLEEP`, and `SLEEP_OUT` connectivity. This proves the pinned
OpenROAD/PDN mapping and physical insertion mechanism with an embedded test
macro. It does not prove a SKY130HD production-library power switch because
the macro is not present in the SKY130HD Liberty, LEF, or CDL inputs.

Raw stdout/stderr and inventory capture:
`results/raw/phase0-power-switch-capability.log`

## DONT_USE policy

The pinned `flow/platforms/sky130hd/config.mk` lists all 33 `lpflow` cells in
`DONT_USE_CELLS`. ORFS applies that list in synthesis, floorplan, placement,
CTS, and global routing. No policy was changed. There is no actual
power-switch candidate in the list to evaluate for exclusion; the platform
has no valid switch candidate in the first place.

## Proven and unproven

Proven:

- The pinned OpenROAD accepts and stores `create_power_switch` intent.
- The pinned OpenROAD accepts `map_power_switch` and requires a loaded master
  plus explicit port mapping.
- The pinned PDN path physically inserts mapped switch masters.
- The pinned upstream regression physically inserts the synthetic
  `POWER_SWITCH` test macro and passes its DEF comparison.
- Every plausible SKY130HD low-power cell family found has Liberty, LEF, and
  CDL, but direct properties identify them as isolation, level-shift, buffer,
  decap, or bleeder cells rather than power switches.

Unproven:

- A real SKY130HD header/footer power-switch standard cell is not present in
  the pinned platform inputs.
- No project physical power-switch implementation has been run or claimed.
- Power-switch electrical behavior, IR drop, wake-up behavior, PMU behavior,
  timing, DRC/LVS, and production suitability remain unqualified.

## Next smallest experiment

Obtain a formally supported SKY130HD power-switch macro with Liberty, LEF, and
CDL views and explicit pin semantics, then run the same `power_switch_upf_daisy`
pattern using that real master in a temporary qualification design. Do not
select an existing isolation or KAPWR helper cell as a substitute.

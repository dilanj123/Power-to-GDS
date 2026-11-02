// Simulation-only functional model of the pinned platform's latch-based ICG.
// The physical flow uses flow/platforms/sky130hd/cells_clkgate_hd.v instead.
module OPENROAD_CLKGATE (
    input  logic CK,
    input  logic E,
    output logic GCK
);
    logic enable_latched = 1'b0;
    always_latch
        if (!CK)
            enable_latched = E;
    assign GCK = CK & enable_latched;
endmodule

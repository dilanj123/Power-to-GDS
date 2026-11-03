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

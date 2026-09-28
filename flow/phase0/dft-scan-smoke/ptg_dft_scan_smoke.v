module ptg_dft_scan_smoke (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        serial_in,
    output wire [11:0] serial_out
);

  reg [11:0] state;

  always @(posedge clk) begin
    if (!reset_n)
      state <= 12'b0;
    else
      state <= {state[10:0], serial_in};
  end

  assign serial_out = state;

endmodule

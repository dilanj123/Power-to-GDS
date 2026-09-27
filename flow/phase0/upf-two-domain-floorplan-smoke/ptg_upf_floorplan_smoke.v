module ptg_sw_domain (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire d_i,
    output reg  q_o
);
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      q_o <= 1'b0;
    else
      q_o <= d_i;
  end
endmodule

module ptg_parent_sink (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire d_i,
    output reg  q_o
);
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      q_o <= 1'b0;
    else
      q_o <= d_i;
  end
endmodule

module ptg_upf_floorplan_smoke (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire iso_en,
    input  wire d_i,
    output wire q_o
);

  wire sw_q;

  (* keep_hierarchy = "yes" *)
  ptg_sw_domain u_sw (
      .clk_i  (clk_i),
      .rst_ni (rst_ni),
      .d_i    (d_i),
      .q_o    (sw_q)
  );

  (* keep_hierarchy = "yes" *)
  ptg_parent_sink u_parent (
      .clk_i  (clk_i),
      .rst_ni (rst_ni),
      .d_i    (sw_q),
      .q_o    (q_o)
  );

endmodule

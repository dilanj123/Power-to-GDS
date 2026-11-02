// Project-owned parameter wrapper for the immutable accepted source top.
// No datapath or control logic is added here.
module config_a_top (
    input  logic        clk,
    input  logic        rst,
    input  logic [23:0] s_tdata,
    input  logic        s_tvalid,
    output logic        s_tready,
    input  logic        s_tuser,
    input  logic        s_tlast,
    output logic [7:0]  m_tdata,
    output logic        m_tvalid,
    input  logic        m_tready,
    output logic        m_tuser,
    output logic        m_tlast,
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [7:0]  paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,
    output logic        pslverr
);
    rtl_to_pixels_top_pipelined #(
        .IMG_WIDTH(32),
        .IMG_HEIGHT(24)
    ) u_functional_top (
        .clk(clk), .rst(rst),
        .s_tdata(s_tdata), .s_tvalid(s_tvalid), .s_tready(s_tready),
        .s_tuser(s_tuser), .s_tlast(s_tlast),
        .m_tdata(m_tdata), .m_tvalid(m_tvalid), .m_tready(m_tready),
        .m_tuser(m_tuser), .m_tlast(m_tlast),
        .psel(psel), .penable(penable), .pwrite(pwrite), .paddr(paddr),
        .pwdata(pwdata), .prdata(prdata), .pready(pready),
        .pslverr(pslverr)
    );
endmodule

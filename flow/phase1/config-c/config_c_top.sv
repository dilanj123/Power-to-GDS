module config_c_top (
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
    output logic        pslverr,
    input  logic        power_down_req,
    input  logic        wake_req,
    input  logic        test_mode,
    output logic        sleep_ack,
    output logic        wake_done,
    output logic        iso_en_n,
    output logic        power_off_intent,
    output logic [3:0]  power_state
);
    localparam int unsigned IMG_WIDTH = 32;
    localparam int unsigned IMG_HEIGHT = 24;
    localparam int unsigned ROW_COUNT_W = $clog2(IMG_HEIGHT + 1);

    logic func_clk;
    logic func_rst;
    logic func_clk_en;
    logic sleep_pending_q;
    logic frame_active_q;
    logic input_frame_done_q;
    logic output_frame_done_q;
    logic [ROW_COUNT_W-1:0] input_eol_count_q;
    logic [ROW_COUNT_W-1:0] output_eol_count_q;
    logic core_s_tvalid, core_s_tready;
    logic input_fire, output_fire;
    logic input_final_line, output_final_line;
    logic frame_drain_now;
    logic functional_quiescent;
    logic quiesce_req;
    logic stream_admit;
    logic [7:0] sw_m_tdata;
    logic sw_m_tvalid, sw_m_tuser, sw_m_tlast;
    logic sw_s_tready;
    logic [31:0] sw_prdata;
    logic sw_pready, sw_pslverr;
    logic apb_reject;

    config_c_pmu u_pmu (
        .aon_clk(clk), .rst(rst), .quiesce_req(quiesce_req),
        .functional_quiescent(functional_quiescent), .wake_req(wake_req),
        .power_state(power_state), .func_clk_en(func_clk_en),
        .func_rst(func_rst), .iso_en_n(iso_en_n),
        .power_off_intent(power_off_intent), .sleep_ack(sleep_ack),
        .wake_done(wake_done)
    );

    OPENROAD_CLKGATE u_func_clk_gate (
        .CK(clk), .E(func_clk_en || test_mode), .GCK(func_clk)
    );

    assign stream_admit = (power_state == 4'd0) &&
        (!(sleep_pending_q || power_down_req) ||
         (frame_active_q && !input_frame_done_q));
    assign core_s_tvalid = s_tvalid && stream_admit;
    assign input_fire = core_s_tvalid && sw_s_tready;
    assign output_fire = sw_m_tvalid && m_tready;
    assign input_final_line = input_fire && s_tlast &&
        input_eol_count_q == ROW_COUNT_W'(IMG_HEIGHT - 1);
    assign output_final_line = output_fire && sw_m_tlast &&
        output_eol_count_q == ROW_COUNT_W'(IMG_HEIGHT - 1);
    assign frame_drain_now = frame_active_q &&
        (input_frame_done_q || input_final_line) &&
        (output_frame_done_q || output_final_line);
    assign functional_quiescent = !frame_active_q && !sw_m_tvalid;
    assign quiesce_req = (power_state == 4'd0) &&
        (sleep_pending_q || power_down_req) && !frame_active_q && !sw_m_tvalid;
    assign apb_reject = power_state != 4'd0 || power_down_req;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sleep_pending_q     <= 1'b0;
            frame_active_q      <= 1'b0;
            input_frame_done_q  <= 1'b0;
            output_frame_done_q <= 1'b0;
            input_eol_count_q   <= '0;
            output_eol_count_q  <= '0;
        end else begin
            if (power_down_req && power_state == 4'd0)
                sleep_pending_q <= 1'b1;

            if (!frame_active_q && input_fire && s_tuser) begin
                frame_active_q      <= 1'b1;
                input_frame_done_q  <= 1'b0;
                output_frame_done_q <= 1'b0;
                input_eol_count_q   <= '0;
                output_eol_count_q  <= '0;
            end
            if (frame_active_q && input_fire && s_tlast) begin
                if (input_final_line)
                    input_frame_done_q <= 1'b1;
                else
                    input_eol_count_q <= input_eol_count_q + 1'b1;
            end
            if (frame_active_q && output_fire && sw_m_tlast) begin
                if (output_final_line)
                    output_frame_done_q <= 1'b1;
                else
                    output_eol_count_q <= output_eol_count_q + 1'b1;
            end
            if (frame_drain_now) begin
                frame_active_q      <= 1'b0;
                input_frame_done_q  <= 1'b0;
                output_frame_done_q <= 1'b0;
                input_eol_count_q   <= '0;
                output_eol_count_q  <= '0;
            end
            if (quiesce_req)
                sleep_pending_q <= 1'b0;
            if (power_state == 4'd6)
                sleep_pending_q <= 1'b0;
        end
    end

    (* keep_hierarchy = "yes" *)
    rtl_to_pixels_top_pipelined #(
        .IMG_WIDTH(IMG_WIDTH), .IMG_HEIGHT(IMG_HEIGHT)
    ) u_functional_top (
        .clk(func_clk), .rst(func_rst),
        .s_tdata(s_tdata), .s_tvalid(core_s_tvalid), .s_tready(sw_s_tready),
        .s_tuser(s_tuser), .s_tlast(s_tlast),
        .m_tdata(sw_m_tdata), .m_tvalid(sw_m_tvalid), .m_tready(m_tready),
        .m_tuser(sw_m_tuser), .m_tlast(sw_m_tlast),
        .psel(psel && !apb_reject), .penable(penable && !apb_reject),
        .pwrite(pwrite), .paddr(paddr), .pwdata(pwdata),
        .prdata(sw_prdata), .pready(sw_pready), .pslverr(sw_pslverr)
    );

`ifdef CONFIG_C_SIM
    assign m_tdata  = iso_en_n ? sw_m_tdata  : 8'b0;
    assign m_tvalid = iso_en_n ? sw_m_tvalid : 1'b0;
    assign m_tuser  = iso_en_n ? sw_m_tuser  : 1'b0;
    assign m_tlast  = iso_en_n ? sw_m_tlast  : 1'b0;
    assign s_tready = iso_en_n && sw_s_tready && stream_admit;
`else
    // Physical output clamp is inserted by the qualified UPF isolation strategy.
    assign m_tdata  = sw_m_tdata;
    assign m_tvalid = sw_m_tvalid;
    assign m_tuser  = sw_m_tuser;
    assign m_tlast  = sw_m_tlast;
    assign s_tready = sw_s_tready && stream_admit;
`endif

    assign prdata  = apb_reject ? 32'b0 : sw_prdata;
    assign pready  = apb_reject ? 1'b1 : sw_pready;
    assign pslverr = apb_reject ? 1'b1 : sw_pslverr;
endmodule

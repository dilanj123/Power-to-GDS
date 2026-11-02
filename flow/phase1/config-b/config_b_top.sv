// Configuration B: the accepted Sobel block is unchanged. Only its functional
// clock is gated after a complete frame and its final output line have drained.
module config_b_top (
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
    input  logic        sleep_req,
    input  logic        wake_req,
    input  logic        test_mode,
    output logic        sleep_ack
);
    localparam int unsigned IMG_WIDTH = 32;
    localparam int unsigned IMG_HEIGHT = 24;
    localparam int unsigned ROW_COUNT_W = $clog2(IMG_HEIGHT + 1);

    logic func_clk;
    logic sleeping_q;
    logic sleep_pending_q;
    logic frame_active_q;
    logic input_frame_done_q;
    logic output_frame_done_q;
    logic [ROW_COUNT_W-1:0] input_eol_count_q;
    logic [ROW_COUNT_W-1:0] output_eol_count_q;
    logic core_s_tvalid;
    logic core_s_tready;
    logic input_fire;
    logic output_fire;
    logic input_final_line;
    logic output_final_line;
    logic frame_drain_now;
    logic stream_admit;

    // The AON-side controller remains clocked while func_clk is stopped.
    // A pending request does not interrupt an accepted frame. In idle it blocks
    // a new SOF immediately; in a frame it allows all current pixels to finish.
    assign stream_admit = !sleeping_q &&
        (!(sleep_pending_q || sleep_req) || frame_active_q);
    assign core_s_tvalid = s_tvalid && stream_admit;
    assign s_tready = core_s_tready && stream_admit;
    assign input_fire = core_s_tvalid && core_s_tready;
    assign output_fire = m_tvalid && m_tready;
    assign input_final_line = input_fire && s_tlast &&
        (input_eol_count_q == ROW_COUNT_W'(IMG_HEIGHT - 1));
    assign output_final_line = output_fire && m_tlast &&
        (output_eol_count_q == ROW_COUNT_W'(IMG_HEIGHT - 1));
    assign frame_drain_now = frame_active_q &&
        (input_frame_done_q || input_final_line) &&
        (output_frame_done_q || output_final_line);

    // The mapped SKY130HD ICG has active-high GATE and no separate TE pin.
    // Test mode therefore bypasses the sleep state in its enable equation.
    OPENROAD_CLKGATE u_func_clk_gate (
        .CK  (clk),
        .E   (!sleeping_q || wake_req || test_mode),
        .GCK (func_clk)
    );

    assign sleep_ack = sleeping_q;

    always_ff @(posedge clk) begin
        if (rst) begin
            sleeping_q         <= 1'b0;
            sleep_pending_q    <= 1'b0;
            frame_active_q     <= 1'b0;
            input_frame_done_q <= 1'b0;
            output_frame_done_q<= 1'b0;
            input_eol_count_q  <= '0;
            output_eol_count_q <= '0;
        end else if (wake_req) begin
            // Wake is synchronous to the ungated clock; stream admission opens
            // only after sleeping_q has been cleared at this edge.
            sleeping_q      <= 1'b0;
            sleep_pending_q <= 1'b0;
        end else begin
            if (sleep_req)
                sleep_pending_q <= 1'b1;

            if (!frame_active_q && input_fire && s_tuser) begin
                frame_active_q      <= 1'b1;
                input_frame_done_q  <= 1'b0;
                output_frame_done_q <= 1'b0;
                input_eol_count_q   <= '0;
                output_eol_count_q  <= '0;
            end

            if (frame_active_q && input_fire && s_tlast) begin
                if (input_final_line) begin
                    input_frame_done_q <= 1'b1;
                end else begin
                    input_eol_count_q <= input_eol_count_q + 1'b1;
                end
            end

            if (frame_active_q && output_fire && m_tlast) begin
                if (output_final_line) begin
                    output_frame_done_q <= 1'b1;
                end else begin
                    output_eol_count_q <= output_eol_count_q + 1'b1;
                end
            end

            if (!frame_active_q && !input_fire && (sleep_pending_q || sleep_req))
                sleeping_q <= 1'b1;

            if (frame_drain_now) begin
                frame_active_q      <= 1'b0;
                input_frame_done_q  <= 1'b0;
                output_frame_done_q <= 1'b0;
                input_eol_count_q   <= '0;
                output_eol_count_q  <= '0;
                if (sleep_pending_q || sleep_req)
                    sleeping_q <= 1'b1;
            end
        end
    end

    rtl_to_pixels_top_pipelined #(
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) u_functional_top (
        .clk(func_clk), .rst(rst),
        .s_tdata(s_tdata), .s_tvalid(core_s_tvalid), .s_tready(core_s_tready),
        .s_tuser(s_tuser), .s_tlast(s_tlast),
        .m_tdata(m_tdata), .m_tvalid(m_tvalid), .m_tready(m_tready),
        .m_tuser(m_tuser), .m_tlast(m_tlast),
        .psel(psel), .penable(penable), .pwrite(pwrite), .paddr(paddr),
        .pwdata(pwdata), .prdata(prdata), .pready(pready), .pslverr(pslverr)
    );
endmodule

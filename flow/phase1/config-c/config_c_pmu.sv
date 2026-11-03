module config_c_pmu (
    input  logic       aon_clk,
    input  logic       rst,
    input  logic       quiesce_req,
    input  logic       functional_quiescent,
    input  logic       wake_req,
    output logic [3:0] power_state,
    output logic       func_clk_en,
    output logic       func_rst,
    output logic       iso_en_n,
    output logic       power_off_intent,
    output logic       sleep_ack,
    output logic       wake_done
);
    localparam logic [3:0] ACTIVE         = 4'd0;
    localparam logic [3:0] QUIESCE        = 4'd1;
    localparam logic [3:0] CLOCK_GATED    = 4'd2;
    localparam logic [3:0] ISOLATE        = 4'd3;
    localparam logic [3:0] POWER_OFF      = 4'd4;
    localparam logic [3:0] POWER_ON_WAIT  = 4'd5;
    localparam logic [3:0] DEISOLATE      = 4'd6;

    logic [3:0] state_q;
    logic [2:0] wait_count_q;
    logic wake_pending_q;
    logic reset_recovery_q;

    assign power_state = state_q;
    assign func_clk_en = rst || state_q == ACTIVE || state_q == QUIESCE ||
        state_q == DEISOLATE ||
        (state_q == POWER_ON_WAIT &&
         (reset_recovery_q || wait_count_q >= 3'd4));
    assign func_rst = rst || state_q == CLOCK_GATED || state_q == ISOLATE ||
        state_q == POWER_OFF || state_q == POWER_ON_WAIT;
    assign iso_en_n = rst ? 1'b0 :
        ((state_q == ACTIVE) || (state_q == QUIESCE) ||
         (state_q == CLOCK_GATED) || (state_q == DEISOLATE));
    assign power_off_intent = !rst && state_q == POWER_OFF;
    assign sleep_ack = state_q == POWER_OFF || state_q == POWER_ON_WAIT ||
        state_q == DEISOLATE;
    assign wake_done = state_q == ACTIVE;

    // Reset puts the block into a safe restart: isolation asserted, logical
    // off removed, functional clock enabled, and two reset cycles after release.
    always_ff @(posedge aon_clk or posedge rst) begin
        if (rst) begin
            state_q          <= POWER_ON_WAIT;
            wait_count_q     <= '0;
            wake_pending_q   <= 1'b0;
            reset_recovery_q <= 1'b1;
        end else begin
            if (state_q != ACTIVE && wake_req)
                wake_pending_q <= 1'b1;

            case (state_q)
                ACTIVE: begin
                    wait_count_q <= '0;
                    if (quiesce_req)
                        state_q <= QUIESCE;
                end
                QUIESCE: begin
                    if (functional_quiescent)
                        state_q <= CLOCK_GATED;
                end
                CLOCK_GATED: state_q <= ISOLATE;
                ISOLATE:     state_q <= POWER_OFF;
                POWER_OFF: begin
                    if (wake_pending_q || wake_req) begin
                        state_q          <= POWER_ON_WAIT;
                        wait_count_q     <= '0;
                        wake_pending_q   <= 1'b0;
                        reset_recovery_q <= 1'b0;
                    end
                end
                POWER_ON_WAIT: begin
                    if (reset_recovery_q) begin
                        if (wait_count_q == 3'd1) begin
                            state_q          <= DEISOLATE;
                            wait_count_q     <= '0;
                            reset_recovery_q <= 1'b0;
                            wake_pending_q   <= 1'b0;
                        end else begin
                            wait_count_q <= wait_count_q + 1'b1;
                        end
                    end else if (wait_count_q == 3'd5) begin
                        state_q      <= DEISOLATE;
                        wait_count_q <= '0;
                        wake_pending_q <= 1'b0;
                    end else begin
                        wait_count_q <= wait_count_q + 1'b1;
                    end
                end
                DEISOLATE: begin
                    state_q        <= ACTIVE;
                    wake_pending_q <= 1'b0;
                end
                default: begin
                    state_q          <= POWER_ON_WAIT;
                    wait_count_q     <= '0;
                    wake_pending_q   <= 1'b0;
                    reset_recovery_q <= 1'b1;
                end
            endcase
        end
    end
endmodule

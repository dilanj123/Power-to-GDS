module config_c_pmu_formal;
    (* gclk *) reg clk;
    (* anyseq *) reg rst;
    (* anyseq *) reg quiesce_req;
    (* anyseq *) reg functional_quiescent;
    (* anyseq *) reg wake_req;
    wire [3:0] power_state;
    wire func_clk_en, func_rst, iso_en_n, power_off_intent;
    wire sleep_ack, wake_done;

    config_c_pmu dut (
        .aon_clk(clk), .rst(rst), .quiesce_req(quiesce_req),
        .functional_quiescent(functional_quiescent), .wake_req(wake_req),
        .power_state(power_state), .func_clk_en(func_clk_en),
        .func_rst(func_rst), .iso_en_n(iso_en_n),
        .power_off_intent(power_off_intent), .sleep_ack(sleep_ack),
        .wake_done(wake_done)
    );

    reg past_valid = 1'b0;
    always @(posedge clk) begin
        past_valid <= 1'b1;
        if (!past_valid)
            assume(rst);

        assert(power_state <= 4'd6);
        assert(power_off_intent == (power_state == 4'd4 && !rst));
        if (power_state == 4'd4) begin
            assert(!func_clk_en);
            assert(!iso_en_n);
            assert(func_rst);
            assert(sleep_ack);
        end
        if (power_state == 4'd5) begin
            assert(!power_off_intent);
            assert(!iso_en_n);
            assert(func_rst);
        end
        if (power_state == 4'd2 || power_state == 4'd3)
            assert(!power_off_intent);
        if (power_state == 4'd6)
            assert(!power_off_intent && iso_en_n && func_clk_en && !func_rst);
        if (wake_done)
            assert(power_state == 4'd0);

        if (past_valid && !rst && !$past(rst)) begin
            case ($past(power_state))
                4'd0: assert(power_state == 4'd0 || power_state == 4'd1);
                4'd1: assert(power_state == 4'd1 || power_state == 4'd2);
                4'd2: assert(power_state == 4'd3);
                4'd3: assert(power_state == 4'd4);
                4'd4: assert(power_state == 4'd4 || power_state == 4'd5);
                4'd5: assert(power_state == 4'd5 || power_state == 4'd6);
                4'd6: assert(power_state == 4'd0);
                default: assert(1'b0);
            endcase
            if (power_state == 4'd1 && $past(power_state) != 4'd1)
                assert($past(power_state) == 4'd0);
            if (power_state == 4'd2 && $past(power_state) != 4'd2)
                assert($past(power_state) == 4'd1 && $past(functional_quiescent));
            if (power_state == 4'd3 && $past(power_state) != 4'd3)
                assert($past(power_state) == 4'd2 && !$past(func_clk_en));
            if (power_state == 4'd4 && $past(power_state) != 4'd4)
                assert($past(power_state) == 4'd3 && !$past(iso_en_n));
            if (power_state == 4'd6 && $past(power_state) != 4'd6)
                assert($past(power_state) == 4'd5);
            if (power_state == 4'd0 && $past(power_state) != 4'd0)
                assert($past(power_state) == 4'd6);
        end
    end
endmodule

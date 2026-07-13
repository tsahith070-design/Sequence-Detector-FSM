`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 20:15:08
// Design Name: 
// Module Name: tb_Group13_Detector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_Group13_Detector;

    reg RESET, CLK, X_in;
    wire OUT;

    // Named port connections
    Group13_SequenceDetector uut (
        .reset    (RESET),
        .clk      (CLK),
        .x_in     (X_in),
        .detected (OUT)
    );

    // Clock Generation: 10ns period
    initial CLK = 0;
    always #5 CLK = ~CLK;

    // Drive one bit: set up on the negedge (safely away from the clock
    // edge), then wait for the following posedge, where the DUT actually
    // samples it. A small settle delay lets OUT be checked immediately
    // afterward without an extra clock cycle passing first.
    task send_bit(input b);
        begin
            @(negedge CLK);
            X_in = b;
            @(posedge CLK);
            #1;
        end
    endtask

    initial begin
        //  Initialization
        RESET = 1;
        X_in  = 0;
        repeat (2) @(posedge CLK);   // hold reset for 2 full cycles
        @(negedge CLK);
        RESET = 0;

        // TEST 1: Roll No 1171 (10010010011) 
        $display("[%0t] Sending 1171", $time);
        send_bit(1); send_bit(0); send_bit(0); send_bit(1);
        send_bit(0); send_bit(0); send_bit(1); send_bit(0);
        send_bit(0); send_bit(1); send_bit(1);   // 11 bits total

        if (OUT) $display("[%0t] SUCCESS: 1171 Detected", $time);
        else     $display("[%0t] FAIL: 1171 NOT Detected", $time);

        //  TEST 2: Three spacers (1-0-0-0-1-1) to clear the lockout 
        $display("[%0t] Sending 3 spacers (1-0-0-0-1-1)", $time);
        send_bit(1); // 1st '1' (S24->S26)
        send_bit(0);
        send_bit(0);
        send_bit(0);
        send_bit(1); // 2nd '1' (S26->S27)
        send_bit(1); // 3rd '1' (S27->S0) - lockout fully cleared here

        if (uut.state === 5'd0)
            $display("[%0t] PASS: Lockout fully cleared (state=0)", $time);
        else
            $display("[%0t] FAIL: Lockout not cleared (state=%0d)", $time, uut.state);

        //  TEST 3: Roll No 1151 (10001111111) 
        $display("[%0t] Sending 1151", $time);
        send_bit(1); send_bit(0); send_bit(0); send_bit(0);
        send_bit(1); send_bit(1); send_bit(1); send_bit(1);
        send_bit(1); send_bit(1); send_bit(1);   // 11 bits total

        if (OUT) $display("[%0t] SUCCESS: 1151 Detected", $time);
        else     $display("[%0t] FAIL: 1151 NOT Detected", $time);

        //  TEST 4: Lockout check with INSUFFICIENT spacers
        // Only 2 clearing bits are sent (3 are required), so the FSM
        // is deliberately left mid-lockout before attempting 1130.
        $display("[%0t] Testing lockout with only 2 spacers", $time);
        send_bit(1); // 1st '1' (S13->S26)
        send_bit(1); // 2nd '1' (S26->S27) - NOT enough, still not at state 0

        if (uut.state !== 5'd0)
            $display("[%0t] PASS: FSM correctly still locked out (state=%0d)", $time, uut.state);
        else
            $display("[%0t] FAIL: FSM unexpectedly already cleared", $time);

        // Attempt Roll No 1130 (10001101010) while still locked out
        send_bit(1); send_bit(0); send_bit(0); send_bit(0);
        send_bit(1); send_bit(1); send_bit(0); send_bit(1);
        send_bit(0); send_bit(1); send_bit(0);   // 11 bits total

        if (!OUT) $display("[%0t] SUCCESS: Lockout blocked detection", $time);
        else      $display("[%0t] FAIL: Detected asserted despite insufficient lockout clearing", $time);

        // TEST 5: Reset, then confirm 1130 detects normally
        $display("[%0t] Resetting, then re-testing 1130 cleanly", $time);
        RESET = 1;
        repeat (2) @(posedge CLK);
        @(negedge CLK);
        RESET = 0;

        send_bit(1); send_bit(0); send_bit(0); send_bit(0);
        send_bit(1); send_bit(1); send_bit(0); send_bit(1);
        send_bit(0); send_bit(1); send_bit(0);   // 11 bits total

        if (OUT) $display("[%0t] SUCCESS: 1130 Detected", $time);
        else     $display("[%0t] FAIL: 1130 NOT Detected", $time);

        $display("[%0t] Simulation Finished", $time);
        #20;
        $finish;
    end

    // Monitor for debug
    initial begin
        $monitor("T=%0t | X=%b | OUT=%b", $time, X_in, OUT);
    end

endmodule
    
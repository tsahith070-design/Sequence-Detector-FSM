`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 20:13:47
// Design Name: 
// Module Name: Group13_SequenceDetector
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
module Group13_SequenceDetector (
    input wire reset,
    input wire clk,
    input wire x_in,
    output reg detected
);

    // State encoding
    localparam S0  = 5'd0,
               S1  = 5'd1,
               S2  = 5'd2,
               S3  = 5'd3,
               S4  = 5'd4,
               S5  = 5'd5,
               S6  = 5'd6,
               S7  = 5'd7,
               S8  = 5'd8,
               S9  = 5'd9,
               S10 = 5'd10,
               S11 = 5'd11,
               S12 = 5'd12,
               S13 = 5'd13,
               S14 = 5'd14,
               S15 = 5'd15,
               S16 = 5'd16,
               S17 = 5'd17,
               S18 = 5'd18,
               S19 = 5'd19,
               S20 = 5'd20,
               S21 = 5'd21,
               S22 = 5'd22,
               S23 = 5'd23,
               S24 = 5'd24,
               S25 = 5'd25,  // wait
               S26 = 5'd26,  // wait1
               S27 = 5'd27;  // wait2

    reg [4:0] state, next_state;

 
    // State register
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    
    // Next-state logic
   
    always @(*) begin
        case (state)

        S0:  next_state = (x_in) ? S1  : S0;
        S1:  next_state = (x_in) ? S1  : S2;
        S2:  next_state = (x_in) ? S1  : S3;
        S3:  next_state = (x_in) ? S17 : S4;
        S4:  next_state = (x_in) ? S5  : S0;
        S5:  next_state = (x_in) ? S6  : S2;
        S6:  next_state = (x_in) ? S7  : S8;
        S7:  next_state = (x_in) ? S9  : S2;
        S8:  next_state = (x_in) ? S10 : S3;
        S9:  next_state = (x_in) ? S11 : S2;
        S10: next_state = (x_in) ? S1  : S14;
        S11: next_state = (x_in) ? S12 : S2;
        S12: next_state = (x_in) ? S13 : S2;
        S13: next_state = (x_in) ? S26 : S25;
        S14: next_state = (x_in) ? S15 : S3;
        S15: next_state = (x_in) ? S1  : S16;
        S16: next_state = (x_in) ? S26 : S25;
        S17: next_state = (x_in) ? S1  : S18;
        S18: next_state = (x_in) ? S1  : S19;
        S19: next_state = (x_in) ? S20 : S4;
        S20: next_state = (x_in) ? S1  : S21;
        S21: next_state = (x_in) ? S1  : S22;
        S22: next_state = (x_in) ? S23 : S4;
        S23: next_state = (x_in) ? S24 : S18;
        S24: next_state = (x_in) ? S26 : S25;
        // wait states
        S25: next_state = (x_in) ? S26 : S25;
        S26: next_state = (x_in) ? S27 : S26;
        S27: next_state = (x_in) ? S0  : S27;

        default: next_state = S0;

        endcase
    end

    
    // Moore output logic
    
    always @(*) begin
        case (state)
            S13,
            S16,
            S24: detected = 1'b1;   // <-- your detection states
            default: detected = 1'b0;
        endcase
    end

endmodule
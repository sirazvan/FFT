module butterfly_type3 #(
    parameter DATA_WIDTH = 16,
    parameter VIRTUAL_DATA_WIDTH = 18,
    parameter SHIFT_PARAM = 15,
    parameter INVERT_MODE = 0  
)(
    input  logic clk,
    input  logic enable,
    input  logic rst_n, 

    input  logic signed [VIRTUAL_DATA_WIDTH-1:0] real_in0, 
    input  logic signed [VIRTUAL_DATA_WIDTH-1:0] imag_in0,
    input  logic signed [VIRTUAL_DATA_WIDTH-1:0] real_in1,
    input  logic signed [VIRTUAL_DATA_WIDTH-1:0] imag_in1,
    output logic signed [VIRTUAL_DATA_WIDTH-1:0] real_out0,
    output logic signed [VIRTUAL_DATA_WIDTH-1:0] imag_out0,
    output logic signed [VIRTUAL_DATA_WIDTH-1:0] real_out1,
    output logic signed [VIRTUAL_DATA_WIDTH-1:0] imag_out1
); 
    localparam signed [VIRTUAL_DATA_WIDTH-1:0] SQRT2_HALF = signed'(23170);

    logic signed [VIRTUAL_DATA_WIDTH-1:0] sum, diff;
    logic signed [2*VIRTUAL_DATA_WIDTH-1:0] mult_sum, mult_diff;

    always_ff @(posedge clk) begin
        sum  <= real_in1 + imag_in1;
        diff <= real_in1 - imag_in1;
    end

    always_ff @(posedge clk) begin
        mult_sum  <= sum * SQRT2_HALF; 
        mult_diff <= diff * SQRT2_HALF; 
    end

    logic signed [VIRTUAL_DATA_WIDTH-1:0] twiddle_mult_real, twiddle_mult_imag;

    always_ff @(posedge clk) begin
        twiddle_mult_real <= (mult_sum  + (1 << (SHIFT_PARAM - 1))) >>> SHIFT_PARAM;  
        twiddle_mult_imag <= (mult_diff + (1 << (SHIFT_PARAM - 1))) >>> SHIFT_PARAM; 
    end
    
    generate 
        if (INVERT_MODE == 0) begin : invert_mode
	        always_ff @(posedge clk) begin
                real_out0 <= real_in0 + twiddle_mult_real;
                imag_out0 <= imag_in0 - twiddle_mult_imag;

                real_out1 <= real_in0 - twiddle_mult_real;
                imag_out1 <= imag_in0 + twiddle_mult_imag;
            end 
        end else begin : non_invert_mode
            always_ff @(posedge clk) begin
                real_out0 <= real_in0 - twiddle_mult_imag;
                imag_out0 <= imag_in0 - twiddle_mult_real;
            
                real_out1 <= real_in0 + twiddle_mult_imag;
                imag_out1 <= imag_in0 + twiddle_mult_real;
            end
        end
    endgenerate
endmodule

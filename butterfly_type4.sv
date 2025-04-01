module butterfly_type4 #(
    parameter DATA_WIDTH = 16,
    parameter signed [DATA_WIDTH-1:0] TWIDDLE_REAL,
    parameter signed [DATA_WIDTH-1:0] TWIDDLE_IMAG  
)(
    input  logic clk,
    input  logic enable,
    input  logic rst_n, 

    input  logic signed [DATA_WIDTH-1:0] real_in0, 
    input  logic signed [DATA_WIDTH-1:0] imag_in0,
    input  logic signed [DATA_WIDTH-1:0] real_in1, 
    input  logic signed [DATA_WIDTH-1:0] imag_in1,
    output logic signed [DATA_WIDTH-1:0] real_out0, 
    output logic signed [DATA_WIDTH-1:0] imag_out0,
    output logic signed [DATA_WIDTH-1:0] real_out1, 
    output logic signed [DATA_WIDTH-1:0] imag_out1
);

    logic signed [DATA_WIDTH-1:0] sum;
    logic signed [DATA_WIDTH-1:0] diff;
    logic signed [2*DATA_WIDTH-1:0] mult_real;
    logic signed [2*DATA_WIDTH-1:0] mult_imag;
    logic signed [DATA_WIDTH-1:0] twiddle_mult_real;
    logic signed [DATA_WIDTH-1:0] twiddle_mult_imag;

    always_ff @(posedge clk) begin
        mult_real <= (real_in1 * TWIDDLE_REAL) - (imag_in1 * TWIDDLE_IMAG);
    end

    always_ff @(posedge clk) begin
	    mult_imag <= (real_in1 * TWIDDLE_IMAG) + (imag_in1 * TWIDDLE_REAL);
    end

    always_ff @(posedge clk) begin
        twiddle_mult_real <= (mult_real + (1 << (DATA_WIDTH - 1))) >> DATA_WIDTH;  
        twiddle_mult_imag <= (mult_imag + (1 << (DATA_WIDTH - 1))) >> DATA_WIDTH;
    end

    assign real_out0 = real_in0 - twiddle_mult_real;
    assign imag_out0 = imag_in0 - twiddle_mult_imag;
    assign real_out1 = real_in0 + twiddle_mult_real;
    assign imag_out1 = imag_in0 + twiddle_mult_imag;
    assign enable = 1'b1;
endmodule

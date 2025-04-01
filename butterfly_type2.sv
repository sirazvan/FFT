module butterfly_type2 #(
    parameter DATA_WIDTH = 16
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

    // Pipeline registers
    logic signed [DATA_WIDTH-1:0] real_temp0, imag_temp0;
    logic signed [DATA_WIDTH-1:0] real_temp1, imag_temp1;

    always_ff @(posedge clk) begin
        real_temp0 <= real_in0 - imag_in1;
        imag_temp0 <= imag_in0 + real_in1;
        real_temp1 <= real_in0 + imag_in1;
        imag_temp1 <= imag_in0 - real_in1;
    end

    assign real_out0 = real_temp0;
    assign imag_out0 = imag_temp0;
    assign real_out1 = real_temp1;
    assign imag_out1 = imag_temp1;

endmodule

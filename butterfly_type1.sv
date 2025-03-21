module butterfly_type1 #(
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

    logic signed [DATA_WIDTH-1:0] real_add, imag_add;
    logic signed [DATA_WIDTH-1:0] real_sub, imag_sub;

    always_ff @(posedge clk) begin
        real_add <= real_in0 + real_in1;
        imag_add <= imag_in0 + imag_in1;
        real_sub <= real_in0 - real_in1;
        imag_sub <= imag_in0 - imag_in1;
    end

    assign real_out0 = real_add;
    assign imag_out0 = imag_add;
    assign real_out1 = real_sub;
    assign imag_out1 = imag_sub;

endmodule

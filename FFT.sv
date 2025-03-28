module FFT16 #(
  parameter int DATA_WIDTH = 16
  parameter int N = 16;
  parameter int NUM_STAGES = $clog2(N);  
)(
  input  logic clk,
  input  logic rst_n,
  input  logic enable,
  input  logic signed [DATA_WIDTH-1:0] zr[0:15],
  input  logic signed [DATA_WIDTH-1:0] zi[0:15],
  output logic signed [DATA_WIDTH-1:0] Zr[0:15],
  output logic signed [DATA_WIDTH-1:0] Zi[0:15]
);

  // Internal wires between stages
  logic signed [DATA_WIDTH-1:0] stage3_r[0:15];
  logic signed [DATA_WIDTH-1:0] stage3_i[0:15];
  logic signed [DATA_WIDTH-1:0] stage2_r[0:15]; 
  logic signed [DATA_WIDTH-1:0] stage2_i[0:15];
  logic signed [DATA_WIDTH-1:0] stage1_r[0:15]; 
  logic signed [DATA_WIDTH-1:0] stage1_i[0:15];
  logic signed [DATA_WIDTH-1:0] stage0_r[0:15];
  logic signed [DATA_WIDTH-1:0] stage0_i[0:15];

  localparam INVERT_MODE = 0;
  localparam TWIDDLE_IMAG = ;
  localparam TWIDDLE_REAL = ;
  genvar i;

  //////////////////////////////////////////////////////////
  // === Stage 4 to 3 ===
  // 8 -> butterfly type 1
  generate
    for (i = 0; i < 8; i = i + 1) begin : stage4_3
      butterfly_type1 #(.DATA_WIDTH(DATA_WIDTH)) bfly (
        .clk(clk),
        .enable(enable),
        .rst_n(rst_n),
        .real_in0(zr[i]), 
        .imag_in0(zi[i]),
        .real_in1(zr[i+8]), 
        .imag_in1(zi[i+8]),
        .real_out0(stage3_r[i]), 
        .imag_out0(stage3_i[i]),
        .real_out1(stage3_r[i+8]), 
        .imag_out1(stage3_i[i+8])
      );
    end
  endgenerate

//////////////////////////////////////////////////////////
  // === Stage 3 to 2 ===
  // 4 -> butterfly type 1

  generate
    for (i = 0; i < 4; i = i + 1) begin : stage3_2_type1
      butterfly_type1 #(.DATA_WIDTH(DATA_WIDTH)) bfly (
        .clk(clk),
        .enable(enable),
        .rst_n(rst_n),
        .real_in0(stage3_r[i]), 
        .imag_in0(stage3_i[i]),
        .real_in1(stage3_r[i+4]), 
        .imag_in1(stage3_i[i+4]),
        .real_out0(stage2_r[i]), 
        .imag_out0(stage2_i[i]),
        .real_out1(stage2_r[i+4]), 
        .imag_out1(stage2_i[i+4])
      );
    end
  endgenerate

  // 4 -> butterfly type 2

  generate
    for (i = 4; i < 8; i = i + 1) begin : stage3_2_type2
      butterfly_type2 #(.DATA_WIDTH(DATA_WIDTH)) bfly (
        .clk(clk),
        .enable(enable),
        .rst_n(rst_n),
        .real_in0(stage3_r[i]), 
        .imag_in0(stage3_i[i]),
        .real_in1(stage3_r[i+4]), 
        .imag_in1(stage3_i[i+4]),
        .real_out0(stage2_r[i]), 
        .imag_out0(stage2_i[i]),
        .real_out1(stage2_r[i+4]), 
        .imag_out1(stage2_i[i+4])
      );
    end
  endgenerate
//////////////////////////////////////////////////////////


  // === Stage 2 to 1 ===
  // Custom mix of butterfly types

  // 2 -> butterfly type 1
  generate
    for (i = 0; i < 2; i = i + 1) begin : stage2_1_type1
      butterfly_type1 #(.DATA_WIDTH(DATA_WIDTH)) bfly (
        .clk(clk),
        .enable(enable),
        .rst_n(rst_n),
        .real_in0(stage2_r[i]), 
        .imag_in0(stage2_i[i]),
        .real_in1(stage2_r[i+2]), 
        .imag_in1(stage2_i[i+2]),
        .real_out0(stage1_r[i]), 
        .imag_out0(stage1_i[i]),
        .real_out1(stage1_r[i+2]), 
        .imag_out1(stage1_i[i+2])
      );
    end
  endgenerate

  // 2 -> butterfly type 2
  generate
    for (i = 2; i < 4; i = i + 1) begin : stage2_1_type2
      butterfly_type2 #(.DATA_WIDTH(DATA_WIDTH)) 
        bfly (
        .clk(clk),
        .enable(enable),
        .rst_n(rst_n),
        .real_in0(stage2_r[i]), 
        .imag_in0(stage2_i[i]),
        .real_in1(stage2_r[i+2]), 
        .imag_in1(stage2_i[i+2]),
        .real_out0(stage1_r[i]), 
        .imag_out0(stage1_i[i]),
        .real_out1(stage1_r[i+2]), 
        .imag_out1(stage1_i[i+2])
      );
    end
  endgenerate
   
  // 2 -> butterfly type 3_0
  generate
    for (i = 4; i < 6; i = i + 1) begin : stage2_1_type3
      butterfly_type3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .INVERT_MODE(INVERT_MODE)) 
        bfly (
        .clk(clk),
        .en(enable),
        .rst_n(rst_n),
        .real_in0(stage2_r[i]), 
        .imag_in0(stage2_i[i]),
        .real_in1(stage2_r[i+2]), 
        .imag_in1(stage2_i[i+2]),
        .real_out0(stage1_r[i]), 
        .imag_out0(stage1_i[i]),
        .real_out1(stage1_r[i+2]), 
        .imag_out1(stage1_i[i+2])
      );
   end
   endgenerate

   // 2 -> butterfly type 3_1
  generate
    for (i = 6; i < 8; i = i + 1) begin : stage2_1_type3_1
      butterfly_type3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .INVERT_MODE(!INVERT_MODE)) 
        bfly (
        .clk(clk),
        .en(enable),
        .rst_n(rst_n),
        .real_in0(stage2_r[i]), 
        .imag_in0(stage2_i[i]),
        .real_in1(stage2_r[i+2]), 
        .imag_in1(stage2_i[i+2]),
        .real_out0(stage1_r[i]), 
        .imag_out0(stage1_i[i]),
        .real_out1(stage1_r[i+2]), 
        .imag_out1(stage1_i[i+2])
      );
   end
   endgenerate


////////////////////////////////////////////////////////// === Stage 1 to 0 ===

  // Index 0 → Butterfly Type 1
  butterfly_type1 #(.DATA_WIDTH(DATA_WIDTH)) bfly_stage1_0 (
    .clk(clk),
    .enable(enable),
    .rst_n(rst_n),
    .real_in0(stage1_r[0]), 
    .imag_in0(stage1_i[0]),
    .real_in1(stage1_r[1]), 
    .imag_in1(stage1_i[1]),
    .real_out0(stage0_r[0]), 
    .imag_out0(stage0_i[0]),
    .real_out1(stage0_r[1]), 
    .imag_out1(stage0_i[1])
  );

  // Index 1 → Butterfly Type 2
  butterfly_type2 #(.DATA_WIDTH(DATA_WIDTH)) bfly_stage1_1 (
    .clk(clk),
    .enable(enable),
    .rst_n(rst_n),
    .real_in0(stage1_r[2]), 
    .imag_in0(stage1_i[2]),
    .real_in1(stage1_r[3]), 
    .imag_in1(stage1_i[3]),
    .real_out0(stage0_r[2]), 
    .imag_out0(stage0_i[2]),
    .real_out1(stage0_r[3]), 
    .imag_out1(stage0_i[3])
  );

  // Index 2 → Butterfly Type 3 (INVERT_MODE = 0)
  butterfly_type3 #(
    .DATA_WIDTH(DATA_WIDTH),
    .INVERT_MODE(INVERT_MODE)
  ) bfly_stage1_2 (
    .clk(clk),
    .en(enable),
    .rst_n(rst_n),
    .real_in0(stage1_r[4]), 
    .imag_in0(stage1_i[4]),
    .real_in1(stage1_r[5]), 
    .imag_in1(stage1_i[5]),
    .real_out0(stage0_r[4]), 
    .imag_out0(stage0_i[4]),
    .real_out1(stage0_r[5]), 
    .imag_out1(stage0_i[5])
  );

  // Index 4 → Butterfly Type 3 (INVERT_MODE = 1)
  butterfly_type3 #(
    .DATA_WIDTH(DATA_WIDTH),
    .INVERT_MODE(!INVERT_MODE)
  ) bfly_stage1_4 (
    .clk(clk),
    .en(enable),
    .rst_n(rst_n),
    .real_in0(stage1_r[6]), 
    .imag_in0(stage1_i[6]),
    .real_in1(stage1_r[7]), 
    .imag_in1(stage1_i[7]),
    .real_out0(stage0_r[6]), 
    .imag_out0(stage0_i[6]),
    .real_out1(stage0_r[7]), 
    .imag_out1(stage0_i[7])
  );

  butterfly_type4 #(
    .DATA_WIDTH(DATA_WIDTH),
    .TWIDDLE_REAL(-1*TWIDDLE_REAL),  // -c
    .TWIDDLE_IMAG(TWIDDLE_IMAG)    // +s
  ) bfly_8_9 (
    .clk(clk),
    .en(enable),
    .rst_n(rst_n),
    .real_in0(stage1_r[8]), 
    .imag_in0(stage1_i[8]),
    .real_in1(stage1_r[9]), 
    .imag_in1(stage1_i[9]),
    .real_out0(stage0_r[8]), 
    .imag_out0(stage0_i[8]),
    .real_out1(stage0_r[9]), 
    .imag_out1(stage0_i[9])
  );

  butterfly_type4 #(
    .DATA_WIDTH(DATA_WIDTH),
    .TWIDDLE_REAL(TWIDDLE_IMAG),   // +s
    .TWIDDLE_IMAG(TWIDDLE_REAL)    // +c
  ) bfly_10_11 (
    .clk(clk),
    .en(enable),
    .rst_n(rst_n),
    .real_in0(stage1_r[10]), 
    .imag_in0(stage1_i[10]),
    .real_in1(stage1_r[11]), 
    .imag_in1(stage1_i[11]),
    .real_out0(stage0_r[10]), 
    .imag_out0(stage0_i[10]),
    .real_out1(stage0_r[11]), 
    .imag_out1(stage0_i[11])
  );

  butterfly_type4 #(
    .DATA_WIDTH(DATA_WIDTH),
    .TWIDDLE_REAL(-1*TWIDDLE_IMAG),  // -s
    .TWIDDLE_IMAG(TWIDDLE_REAL)    // +c
  ) bfly_12_13 (
    .clk(clk),
    .en(enable),
    .rst_n(rst_n),
    .real_in0(stage1_r[12]), 
    .imag_in0(stage1_i[12]),
    .real_in1(stage1_r[13]), 
    .imag_in1(stage1_i[13]),
    .real_out0(stage0_r[12]), 
    .imag_out0(stage0_i[12]),
    .real_out1(stage0_r[13]), 
    .imag_out1(stage0_i[13])
  );

  butterfly_type4 #(
    .DATA_WIDTH(DATA_WIDTH),
    .TWIDDLE_REAL(TWIDDLE_REAL),   // +c
    .TWIDDLE_IMAG(TWIDDLE_IMAG)    // +s
  ) bfly_14_15 (
    .clk(clk),
    .en(enable),
    .rst_n(rst_n),
    .real_in0(stage1_r[14]), 
    .imag_in0(stage1_i[14]),
    .real_in1(stage1_r[15]), 
    .imag_in1(stage1_i[15]),
    .real_out0(stage0_r[14]), 
    .imag_out0(stage0_i[14]),
    .real_out1(stage0_r[15]), 
    .imag_out1(stage0_i[15])
  );

endmodule

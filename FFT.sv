module FFT#(
  parameter int DATA_WIDTH = 16,
  parameter int VIRTUAL_DATA_WIDTH = 18,
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

  //Intermitent stages 
  logic signed [VIRTUAL_DATA_WIDTH-1:0] scaled_stage2_r[0:15];
  logic signed [VIRTUAL_DATA_WIDTH-1:0] scaled_stage2_i[0:15];
  logic signed [VIRTUAL_DATA_WIDTH-1:0] scaled_stage0_r[0:15];
  logic signed [VIRTUAL_DATA_WIDTH-1:0] scaled_stage0_i[0:15];

  // Paramteres
  localparam SHIFT_PARAM = 15;
  localparam INVERT_MODE = 1'b0;
  localparam signed [VIRTUAL_DATA_WIDTH-1:0] TWIDDLE_IMAG = signed'(30274);
  localparam signed [VIRTUAL_DATA_WIDTH-1:0] TWIDDLE_REAL = signed'(12540);
  genvar i;

  //////////////////////////////////////////////////////////
  // === Stage 4 to 3 ===
  // 8 -> butterfly type 1
  generate
    for (i = 0; i < 8; i = i + 1) begin : stage4_3
      butterfly_type1 #(.DATA_WIDTH(DATA_WIDTH), 
      .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH)) 
      bfly8x1 (
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
// 4 x butterfly type 1 -> z2(1:8)

generate
  for (i = 0; i < 4; i = i + 1) begin : stage3_2_type1
    butterfly_type1 #(.DATA_WIDTH(DATA_WIDTH), 
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH))
      bfly (
      .clk(clk),
      .enable(enable),
      .rst_n(rst_n),
      .real_in0(stage3_r[i]), 
      .imag_in0(stage3_i[i]),
      .real_in1(stage3_r[i+4]), 
      .imag_in1(stage3_i[i+4]),
      .real_out0(stage2_r[i]),         // z2(1:4)
      .imag_out0(stage2_i[i]),
      .real_out1(stage2_r[i+4]),       // z2(5:8)
      .imag_out1(stage2_i[i+4])
    );
  end
endgenerate

// 4 x butterfly type 2 -> z2(9:16)

generate
  for (i = 0; i < 4; i = i + 1) begin : stage3_2_type2
    butterfly_type2 #(.DATA_WIDTH(DATA_WIDTH),
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH))
    bfly (
      .clk(clk),
      .enable(enable),
      .rst_n(rst_n),
      .real_in0(stage3_r[i+8]), 
      .imag_in0(stage3_i[i+8]),
      .real_in1(stage3_r[i+12]), 
      .imag_in1(stage3_i[i+12]),
      .real_out0(stage2_r[i+8]),       // z2(9:12)
      .imag_out0(stage2_i[i+8]),
      .real_out1(stage2_r[i+12]),      // z2(13:16)
      .imag_out1(stage2_i[i+12])
    );
  end
endgenerate


// Intermediate scaling

generate
  for (i = 0; i < 16; i++) begin : scale_down_stage2
    assign scaled_stage2_r[i] = stage2_r[i] >>> 2;  
    assign scaled_stage2_i[i] = stage2_i[i] >>> 2;
  end
endgenerate
// END 

// === Stage 2 to 1 ===

// 2 x butterfly type 1 -> stage1_r[0:3]
generate
  for (i = 0; i < 2; i = i + 1) begin : stage2_1_type1
    butterfly_type1 #(.DATA_WIDTH(DATA_WIDTH), 
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH)) 
    bfly (
      .clk(clk),
      .enable(enable),
      .rst_n(rst_n),

      .real_in0(stage2_r[i]),        // z2(1:2)
      .imag_in0(stage2_i[i]),
      .real_in1(stage2_r[i + 2]),    // z2(3:4)
      .imag_in1(stage2_i[i + 2]),

      .real_out0(stage1_r[i]),       // z1(1:2)
      .imag_out0(stage1_i[i]),
      .real_out1(stage1_r[i + 2]),   // z1(3:4)
      .imag_out1(stage1_i[i + 2])
    );
  end
endgenerate

// 2 x butterfly type 2 -> stage1_r[4:7]
generate
  for (i = 0; i < 2; i = i + 1) begin : stage2_1_type2
    butterfly_type2 #(.DATA_WIDTH(DATA_WIDTH),
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH)) 
    bfly (
      .clk(clk),
      .enable(enable),
      .rst_n(rst_n),

      .real_in0(stage2_r[i + 4]),    // z2(5:6)
      .imag_in0(stage2_i[i + 4]),
      .real_in1(stage2_r[i + 6]),    // z2(7:8)
      .imag_in1(stage2_i[i + 6]),

      .real_out0(stage1_r[i + 4]),   // z1(5:6)
      .imag_out0(stage1_i[i + 4]),
      .real_out1(stage1_r[i + 6]),   // z1(7:8)
      .imag_out1(stage1_i[i + 6])
    );
  end
endgenerate

// 2 x butterfly type 3 (INVERT_MODE = 0) -> stage1_r[8:11]

generate
  for (i = 0; i < 2; i = i + 1) begin : stage2_1_type3_0
    butterfly_type3 #(
      .DATA_WIDTH(DATA_WIDTH),
      .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH),
      .SHIFT_PARAM(SHIFT_PARAM),
      .INVERT_MODE(0)
    ) bfly (
      .clk(clk),
      .enable(enable),
      .rst_n(rst_n),

      .real_in0(stage2_r[i + 8]),    // z2(9:10)
      .imag_in0(stage2_i[i + 8]),
      .real_in1(stage2_r[i + 10]),   // z2(11:12)
      .imag_in1(stage2_i[i + 10]),

      .real_out0(stage1_r[i + 8]),   // z1(9:10)
      .imag_out0(stage1_i[i + 8]),
      .real_out1(stage1_r[i + 10]),  // z1(11:12)
      .imag_out1(stage1_i[i + 10])
    );
  end
endgenerate

// 2 x butterfly type 3 (INVERT_MODE = 1) -> stage1_r[12:15]
generate
  for (i = 0; i < 2; i = i + 1) begin : stage2_1_type3_1
    butterfly_type3 #(
      .DATA_WIDTH(DATA_WIDTH),
      .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH),
      .SHIFT_PARAM(SHIFT_PARAM),
      .INVERT_MODE(1)
    ) bfly (
      .clk(clk),
      .enable(enable),
      .rst_n(rst_n),

      .real_in0(stage2_r[i + 12]),   // z2(13:14)
      .imag_in0(stage2_i[i + 12]),
      .real_in1(stage2_r[i + 14]),   // z2(15:16)
      .imag_in1(stage2_i[i + 14]),

      .real_out0(stage1_r[i + 12]),  // z1(13:14)
      .imag_out0(stage1_i[i + 12]),
      .real_out1(stage1_r[i + 14]),  // z1(15:16)
      .imag_out1(stage1_i[i + 14])
    );
  end
endgenerate
  
////////////////////////////////////////////////////////// 
/////////////////=== Stage 1 to 0 ===/////////////////////

  // Index 0 Butterfly Type 1
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

  // Index 1 Butterfly Type 2
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

  // Index 2  Butterfly Type 3 (INVERT_MODE = 0)
  butterfly_type3 #(
    .DATA_WIDTH(DATA_WIDTH),
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH),
    .SHIFT_PARAM(SHIFT_PARAM),
    .INVERT_MODE(INVERT_MODE)
  ) bfly_stage1_2 (
    .clk(clk),
    .enable(enable),
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

  // Index 4 Butterfly Type 3 (INVERT_MODE = 1)
  butterfly_type3 #(
    .DATA_WIDTH(DATA_WIDTH),
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH),
    .SHIFT_PARAM(SHIFT_PARAM),
    .INVERT_MODE(!INVERT_MODE)
  ) bfly_stage1_4 (
    .clk(clk),
    .enable(enable),
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
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH),
    .SHIFT_PARAM(SHIFT_PARAM),
    .TWIDDLE_REAL(-1*TWIDDLE_REAL),  // -c
    .TWIDDLE_IMAG(TWIDDLE_IMAG)    // +s
  ) bfly_8_9 (
    .clk(clk),
    .enable(enable),
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
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH),
    .SHIFT_PARAM(SHIFT_PARAM),
    .TWIDDLE_REAL(TWIDDLE_IMAG),   // +s
    .TWIDDLE_IMAG(TWIDDLE_REAL)    // +c
  ) bfly_10_11 (
    .clk(clk),
    .enable(enable),
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
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH),
    .SHIFT_PARAM(SHIFT_PARAM),
    .TWIDDLE_REAL(-1*TWIDDLE_IMAG),  // -s
    .TWIDDLE_IMAG(TWIDDLE_REAL)    // +c
  ) bfly_12_13 (
    .clk(clk),
    .enable(enable),
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
    .VIRTUAL_DATA_WIDTH(VIRTUAL_DATA_WIDTH),
    .SHIFT_PARAM(SHIFT_PARAM),
    .TWIDDLE_REAL(TWIDDLE_REAL),   // +c
    .TWIDDLE_IMAG(TWIDDLE_IMAG)    // +s
  ) bfly_14_15 (
    .clk(clk),
    .enable(enable),
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

  generate
  for (i = 0; i < 16; i++) begin : scale_output_stage
    assign scaled_stage0_r[i] = stage0_r[i] >>> 2;  
    assign scaled_stage0_i[i] = stage0_i[i] >>> 2;
  end
  endgenerate
  
generate
  for (i = 0; i < 16; i = i + 1) begin : output_assign
    assign Zr[i] = stage0_r[i];
    assign Zi[i] = stage0_i[i];
  end
endgenerate
endmodule

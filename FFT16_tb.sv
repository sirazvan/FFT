module FFT16_tb();

  parameter DATA_WIDTH = 16;

  logic clk;
  logic rst_n;
  logic enable;

  logic signed [DATA_WIDTH-1:0] zr[0:15];
  logic signed [DATA_WIDTH-1:0] zi[0:15];

  logic signed [DATA_WIDTH-1:0] Zr[0:15];
  logic signed [DATA_WIDTH-1:0] Zi[0:15];

  FFT16 #(.DATA_WIDTH(DATA_WIDTH)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .zr(zr),
    .zi(zi),
    .Zr(Zr),
    .Zi(Zi)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    enable = 0;
    #20;

    rst_n = 1;
    enable = 1;

    // Impulse signal input (fixed-point Q15)
    zr[0] = 16'sh7FFF;  // 1.0 in Q15
    zi[0] = 16'sh0000;
    for (int i = 1; i < 16; i++) begin
      zr[i] = 16'sh0000;
      zi[i] = 16'sh0000;
    end

    #200;  // Wait for FFT completion

    // Display FFT outputs
    $display("FFT Output:");
    for (int i = 0; i < 16; i++) begin
      $display("Index %0d: Zr = %d, Zi = %d", i, Zr[i], Zi[i]);
    end

    $stop;
  end

endmodule

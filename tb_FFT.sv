
module tb_FFT;

  parameter DATA_WIDTH = 16;
  parameter N = 16;

  logic clk;
  logic rst_n;
  logic enable;

  logic signed [DATA_WIDTH-1:0] zr[0:N-1];
  logic signed [DATA_WIDTH-1:0] zi[0:N-1];
  logic signed [DATA_WIDTH-1:0] Zr[0:N-1];
  logic signed [DATA_WIDTH-1:0] Zi[0:N-1];

  FFT #(.DATA_WIDTH(DATA_WIDTH)) dut (
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

    for (int i = 0; i < N; i++) begin
      zr[i] = 16'sh7FFF;  // Q15 = 1.0
      zi[i] = 16'sh7FFF;  // Q15 = 1.0
    end

    #200;

    $display("=== FFT Output: input = constant 1 + j1 ===");
    for (int i = 0; i < N; i++) begin
      $display("Index %0d: Zr = %d, Zi = %d", i, Zr[i], Zi[i]);
    end

    $stop;
  end

endmodule

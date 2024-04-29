`timescale 1ns / 1ps

module testbench_RISCV_Pipeline();

reg clk, reset;

RISCV_PipelineProcessor u1(clk, reset);

initial
begin
reset <= 1; #1; reset <= 0;
end


always
begin
clk <= 1; #0.25; clk <= 0; #0.25;
end
endmodule
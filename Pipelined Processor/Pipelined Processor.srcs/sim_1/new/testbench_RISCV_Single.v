`timescale 1ns / 1ps

module testbench_RISCV_Single();

reg clk, reset;

RISCV_SingleProcessor u1(clk, reset);

initial
begin
reset <= 1; #1; reset <= 0;
end


always
begin
clk <= 1; #1.25; clk <= 0; #1.25;
end
endmodule
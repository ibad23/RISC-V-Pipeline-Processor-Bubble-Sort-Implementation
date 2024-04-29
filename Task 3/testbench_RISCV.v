`timescale 1ns / 1ps

module testbench_RISCVSC();

reg clk, reset;

RISCV_SCProcessor u1(clk, reset);

initial
begin
reset <= 1; #2; reset <= 0;
end


always
begin
clk <= 1; #2; clk <= 0; #2;
end
endmodule
module ALU64(
 input [63:0] a,
 input [63:0] b,
 input [3:0] ALUOp,
 output reg [63:0] Result,
 output reg zero,
 output reg Is_Greater
);

always @(*)
begin
 case(ALUOp)
 4'b0000: // AND
 begin
 Result = a & b ;
 end

 4'b0001: // OR
 begin
 Result = a | b ;
 end
 4'b0010: // add
 begin
 Result = a + b;
 end

 4'b0110: // subtract
 begin
 Result = a - b;
 end

 4'b1100: // nor
 begin
 Result = ~a & ~b ;
 end
 
 4'b1000: // slli
 begin
 Result =  a * (2 ** b);
 end

 endcase

 // calculation for zero
if (a == b)
    zero = 1;
else
    zero = 0;

if (a < b)
    Is_Greater = 1;
else
    Is_Greater = 0;
//Is_Greater = (a > b) ? 1'b1 : 1'b0;

end
endmodule

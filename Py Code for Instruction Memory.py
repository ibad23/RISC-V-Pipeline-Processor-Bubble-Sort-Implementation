lst = ["0x01290913",
"0x014a0a13",
"0x01494a63",
"0x00aa8a93",
"0x00aa8a93",
"0x00aa8a93",
"0x00aa8a93",
"0x01490a63",
"0x00a90913",
"0x00a90913",
"0x00a90913",
"0x00a90913",
"0x01494463",
"0x064a8a93",
"0x00000463",
"0x44ca8a93"]

new = [] ; instruction = 1 ; count = 0

for i in lst:
    new.append("{inst_mem["+str(count + 3)+"], inst_mem["+str(count + 2)+"], inst_mem["+str(count + 1)+"], inst_mem["+str(count)+"]} = 32'h"+str(i)[2:]+f"; //{instruction}")
    instruction += 1
    count += 4

for i in new:
    print(i)
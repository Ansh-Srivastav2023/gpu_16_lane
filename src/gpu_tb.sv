module gpu_tb;
    
    parameter WIDTH=32, LANES=16;

    reg clk, rst;
    wire [LANES-1:0] Z;

    gpu_top gpu_top(.clk(clk), .rst(rst), .Z(Z));

    always #5 clk = !clk;

    initial begin
        clk = 0;
        rst = 0;

        #12 rst = !rst;

        #200 $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars("0");
    end

endmodule

// `timescale 1ns/1ps
// //==============================================================
// //  Self-checking testbench - Single-Cycle MIPS
// //  بيحمّل برنامج في الـ instruction memory، يشغّل المعالج،
// //  ويقارن الـ registers بالقيم المتوقعة.
// //==============================================================
// module tb;

//   localparam CLK_PERIOD = 20;   // ns (50 MHz زي الـ constraints)

//   logic        CLK = 0, rst_n = 0;
//   logic        imem_WE = 0;
//   logic [31:0] imem_WA = 0, imem_WD = 0;
//   logic [31:0] PC_out, ALUResult_out;

//   MIPI_Single_cyc_top dut (.*);

//   always #(CLK_PERIOD/2) CLK = ~CLK;

//   //------------------------------------------------------------
//   // Helpers
//   //------------------------------------------------------------
//   int idx = 0, errors = 0;

//   function automatic [31:0] R(input [4:0] rs, rt, rd, input [5:0] f);
//     return {6'd0, rs, rt, rd, 5'd0, f};
//   endfunction
//   function automatic [31:0] I(input [5:0] op, input [4:0] rs, rt, input [15:0] imm);
//     return {op, rs, rt, imm};
//   endfunction

//   task automatic emit(input [31:0] w);
//     @(negedge CLK); imem_WE = 1; imem_WA = idx*4; imem_WD = w; idx++;
//     @(negedge CLK); imem_WE = 0;
//   endtask

//   task automatic chk(input int r, input [31:0] exp);
//     if (dut.u_rf.REG_FILE[r] !== exp) begin
//       errors++;
//       $display("  [FAIL] r%0d = 0x%08h   expected 0x%08h", r, dut.u_rf.REG_FILE[r], exp);
//     end else
//       $display("  [ ok ] r%0d = 0x%08h", r, exp);
//   endtask

//   //------------------------------------------------------------
//   // Instruction name (بيظهر في الـ wave كـ string)
//   //------------------------------------------------------------
//   string instr_name = "";

//   function automatic string decode(input [31:0] w);
//     logic [5:0] op, fn; logic [4:0] rs, rt, rd; logic signed [15:0] imm;
//     op = w[31:26]; rs = w[25:21]; rt = w[20:16]; rd = w[15:11]; fn = w[5:0]; imm = w[15:0];
//     if (w === 32'bx)      return "---";
//     if (w == 32'd0)       return "nop";
//     case (op)
//       6'h00: begin
//         string n;
//         case (fn)
//           6'b100000: n = "add";   6'b100010: n = "sub";
//           6'b011000: n = "mul";   6'b011010: n = "div";
//           6'b100100: n = "and";   6'b100101: n = "or";
//           6'b100110: n = "nand";  6'b100111: n = "nor";
//           6'b100001: n = "xor";   6'b100011: n = "xnor";
//           6'b101000: n = "eq";    6'b101010: n = "gt";
//           6'b101011: n = "lt";    default:   n = "r-type?";
//         endcase
//         return $sformatf("%s r%0d, r%0d, r%0d", n, rd, rs, rt);
//       end
//       6'h08: return $sformatf("addi r%0d, r%0d, %0d", rt, rs, imm);
//       6'h23: return $sformatf("lw   r%0d, %0d(r%0d)", rt, imm, rs);
//       6'h2B: return $sformatf("sw   r%0d, %0d(r%0d)", rt, imm, rs);
//       6'h04: return $sformatf("beq  r%0d, r%0d, %0d", rs, rt, imm);
//       6'h02: return $sformatf("j    0x%0h", {w[25:0], 2'b00});
//       default: return "unknown";
//     endcase
//   endfunction

//   always @(dut.Instr) instr_name = decode(dut.Instr);

//   // كلمة الـ data memory عند العنوان 8 (بيستخدمها sw/lw في البرنامج)
//   wire [31:0] dmem_word_8 = {dut.u_dmem.data_mem[11], dut.u_dmem.data_mem[10],
//                              dut.u_dmem.data_mem[9],  dut.u_dmem.data_mem[8]};

//   // Trace
//   always @(posedge CLK) if (rst_n)
//     $display("%6t | PC=%03h | %-22s | ALU=0x%08h", $time, dut.PC, instr_name, dut.ALUResult);

//   //------------------------------------------------------------
//   // Test sequence
//   //------------------------------------------------------------
//   initial begin
//     $display("\n=========== Loading program ===========");
//     emit(I(6'h08,0,1,10));            //  0 addi r1,r0,10
//     emit(I(6'h08,0,2,3));             //  1 addi r2,r0,3
//     emit(R(1,2,3,6'b100000));         //  2 add  r3 = r1 + r2
//     emit(R(1,2,4,6'b100010));         //  3 sub  r4 = r1 - r2
//     emit(R(1,2,5,6'b011000));         //  4 mul  r5 = r1 * r2
//     emit(R(1,2,6,6'b011010));         //  5 div  r6 = r1 / r2
//     emit(R(1,2,7,6'b100100));         //  6 and
//     emit(R(1,2,8,6'b100101));         //  7 or
//     emit(R(1,2,9,6'b100110));         //  8 nand
//     emit(R(1,2,10,6'b100111));        //  9 nor
//     emit(R(1,2,11,6'b100001));        // 10 xor
//     emit(R(1,2,12,6'b100011));        // 11 xnor
//     emit(R(1,2,13,6'b101000));        // 12 eq   (10==3 ? 1:0)
//     emit(R(1,2,14,6'b101010));        // 13 gt   (10>3  ? 2:0)
//     emit(R(2,1,15,6'b101011));        // 14 lt   (3<10  ? 3:0)
//     emit(I(6'h2B,0,5,8));             // 15 sw r5, 8(r0)
//     emit(I(6'h23,0,16,8));            // 16 lw r16, 8(r0)
//     emit(I(6'h04,1,1,1));             // 17 beq r1,r1,+1   (taken)
//     emit(I(6'h08,0,17,99));           // 18 addi r17,99    (skipped)
//     emit(I(6'h08,0,18,5));            // 19 addi r18,5
//     emit(I(6'h04,1,2,1));             // 20 beq r1,r2,+1   (not taken)
//     emit(I(6'h08,0,19,7));            // 21 addi r19,7
//     emit({6'h02,26'd24});             // 22 j 24
//     emit(I(6'h08,0,20,1));            // 23 addi r20,1     (skipped)
//     emit(I(6'h08,0,21,2));            // 24 addi r21,2
//     emit(I(6'h08,0,23,16'hFFFB));     // 25 addi r23,-5
//     emit(I(6'h04,0,0,16'hFFFF));      // 26 beq r0,r0,-1   (loop على نفسها)

//     $display("=========== Running ===========");
//     repeat (2) @(negedge CLK);
//     rst_n = 1;
//     repeat (40) @(negedge CLK);

//     $display("\n=========== Checking registers ===========");
//     chk(1,10);  chk(2,3);   chk(3,13);  chk(4,7);   chk(5,30);  chk(6,3);
//     chk(7,2);   chk(8,11);  chk(9,32'hFFFFFFFD);    chk(10,32'hFFFFFFF4);
//     chk(11,9);  chk(12,32'hFFFFFFF6);  chk(13,0);   chk(14,2);  chk(15,3);
//     chk(16,30); chk(17,0);  chk(18,5);  chk(19,7);  chk(20,0);  chk(21,2);
//     chk(23,32'hFFFFFFFB);
//     if (dut.PC !== 26*4) begin
//       errors++; $display("  [FAIL] PC = %0d expected %0d", dut.PC, 26*4);
//     end else $display("  [ ok ] PC = %0d (loop)", dut.PC);

//     $display("\n==========================================");
//     if (errors == 0) $display("   ALL TESTS PASSED");
//     else             $display("   FAILED: %0d error(s)", errors);
//     $display("==========================================\n");
// `ifdef VERILATOR
//     $finish;
// `else
//     $stop;     // يوقف السيميوليشن ويسيب الـ wave مفتوحة
// `endif
//   end

// endmodule
`timescale 1ns/1ps

//======================================================================
// Extensive self-checking testbench for MIPI_Single_cyc_top
//
// Tests:
//   - All 13 supported R-type ALU operations
//   - Signed arithmetic and negative immediate sign extension
//   - DIV normal operation and DIV-by-zero exception handling
//   - Register write suppression on DIV-by-zero
//   - Unsupported R-type function suppression
//   - R0 hard-wired-to-zero behavior
//   - ADDI, LW, SW
//   - BEQ taken / not-taken
//   - JUMP
//   - Final PC / program-flow checks
//
// IMPORTANT:
// This testbench targets the UPDATED RTL interface discussed in chat:
//   ALSU output: Division_Error
//   Top internal signals: Division_Error, RegWrite_final
//   Register File write enable connected to RegWrite_final
//======================================================================

module tb_MIPS_extensive;

    localparam time CLK_PERIOD = 20ns;
    localparam int PROGRAM_WORDS = 42;

    logic CLK = 1'b0;
    logic rst_n = 1'b0;

    logic        imem_WE = 1'b0;
    logic [31:0] imem_WA = '0;
    logic [31:0] imem_WD = '0;

    logic [31:0] PC_out;
    logic [31:0] ALUResult_out;

    int errors = 0;
    int checks = 0;
    int div_zero_events = 0;
    int cycle_count = 0;
    int program_index = 0;

    MIPI_Single_cyc_top dut (
        .CLK          (CLK),
        .rst_n        (rst_n),
        .imem_WE      (imem_WE),
        .imem_WA      (imem_WA),
        .imem_WD      (imem_WD),
        .PC_out       (PC_out),
        .ALUResult_out(ALUResult_out)
    );

    always #(CLK_PERIOD/2) CLK = ~CLK;

    // ---------------- Instruction encoders ----------------

    function automatic logic [31:0] enc_r(
        input logic [4:0] rs,
        input logic [4:0] rt,
        input logic [4:0] rd,
        input logic [5:0] funct
    );
        enc_r = {6'b000000, rs, rt, rd, 5'b00000, funct};
    endfunction

    function automatic logic [31:0] enc_i(
        input logic [5:0] opcode,
        input logic [4:0] rs,
        input logic [4:0] rt,
        input logic [15:0] imm
    );
        enc_i = {opcode, rs, rt, imm};
    endfunction

    function automatic logic [31:0] enc_j(input logic [25:0] target_word);
        enc_j = {6'b000010, target_word};
    endfunction

    // ---------------- Scoreboard helpers ----------------

    task automatic fail(input string message);
        begin
            errors++;
            $display("[%0t] FAIL: %s", $time, message);
        end
    endtask

    task automatic check_reg(input int reg_num, input logic [31:0] expected);
        logic [31:0] actual;
        begin
            checks++;
            actual = dut.u_rf.REG_FILE[reg_num];
            if (actual !== expected) begin
                fail($sformatf("R%0d = 0x%08h, expected 0x%08h",
                               reg_num, actual, expected));
            end
        end
    endtask

    task automatic check_word(input int byte_addr, input logic [31:0] expected);
        logic [31:0] actual;
        begin
            checks++;
            actual = {
                dut.u_dmem.data_mem[byte_addr+3],
                dut.u_dmem.data_mem[byte_addr+2],
                dut.u_dmem.data_mem[byte_addr+1],
                dut.u_dmem.data_mem[byte_addr]
            };
            if (actual !== expected) begin
                fail($sformatf("DMEM[byte %0d] = 0x%08h, expected 0x%08h",
                               byte_addr, actual, expected));
            end
        end
    endtask

    task automatic emit(input logic [31:0] instruction_word);
        begin
            // CPU is held in reset while the instruction memory is loaded.
            @(negedge CLK);
            imem_WE = 1'b1;
            imem_WA = program_index * 4;
            imem_WD = instruction_word;
            @(negedge CLK);
            imem_WE = 1'b0;
            program_index++;
        end
    endtask

    task automatic emit_r(
        input logic [4:0] rs,
        input logic [4:0] rt,
        input logic [4:0] rd,
        input logic [5:0] funct
    );
        emit(enc_r(rs, rt, rd, funct));
    endtask

    task automatic emit_i(
        input logic [5:0] opcode,
        input logic [4:0] rs,
        input logic [4:0] rt,
        input logic [15:0] imm
    );
        emit(enc_i(opcode, rs, rt, imm));
    endtask

    // ---------------- Runtime protocol/error monitor ----------------

    always @(posedge CLK) begin
        if (rst_n) begin
            cycle_count++;

            // Division_Error must only be asserted for DIV with divisor=0.
            if (dut.Division_Error === 1'b1) begin
                div_zero_events++;

                if (dut.ALUControl !== 4'b0011)
                    fail("Division_Error asserted while ALUControl is not DIV");

                if (dut.SrcB !== 32'b0)
                    fail("Division_Error asserted although divisor is non-zero");

                if (dut.ALUResult !== 32'b0)
                    fail("ALUResult must be zero on division by zero");

                if (dut.RegWrite_final !== 1'b0)
                    fail("RegWrite_final must be LOW on division by zero");
            end
            else if (dut.Division_Error !== 1'b0) begin
                fail("Division_Error is X/Z during normal execution");
            end

            // Register write enable must never be X/Z.
            if ((dut.RegWrite_final !== 1'b0) &&
                (dut.RegWrite_final !== 1'b1))
                fail("RegWrite_final is X/Z");
        end
    end

    // ---------------- Main test program ----------------

    initial begin
        $display("\n======================================================");
        $display(" MIPS SINGLE-CYCLE PROCESSOR - EXTENSIVE TESTBENCH");
        $display("======================================================");

        // Reset is active while program words are loaded.
        repeat (3) @(negedge CLK);

        // Initial operands.
        emit_i(6'h08, 5'd0, 5'd1, 16'd10);       //  0: R1 = 10
        emit_i(6'h08, 5'd0, 5'd2, 16'd3);        //  1: R2 = 3

        // All supported R-type ALU operations.
        emit_r(1, 2, 3,  6'b100000);             //  2: ADD  = 13
        emit_r(1, 2, 4,  6'b100010);             //  3: SUB  = 7
        emit_r(1, 2, 5,  6'b011000);             //  4: MUL  = 30
        emit_r(1, 2, 6,  6'b011010);             //  5: DIV  = 3
        emit_r(1, 2, 7,  6'b100100);             //  6: AND  = 2
        emit_r(1, 2, 8,  6'b100101);             //  7: OR   = 11
        emit_r(1, 2, 9,  6'b100110);             //  8: NAND = FFFFFFFD
        emit_r(1, 2, 10, 6'b100111);             //  9: NOR  = FFFFFFF4
        emit_r(1, 2, 11, 6'b100001);             // 10: XOR  = 9
        emit_r(1, 2, 12, 6'b100011);             // 11: XNOR = FFFFFFF6
        emit_r(1, 2, 13, 6'b101000);             // 12: EQ   = 0
        emit_r(1, 2, 14, 6'b101010);             // 13: GT   = 2
        emit_r(2, 1, 15, 6'b101011);             // 14: LT   = 3

        // Division-by-zero: destination is preloaded with a sentinel.
        emit_i(6'h08, 5'd0, 5'd24, 16'd77);      // 15: R24 = 77
        emit_r(1, 0, 24, 6'b011010);             // 16: DIV R24 = R1 / R0; must NOT write

        // Signed division and negative immediate.
        emit_i(6'h08, 5'd0, 5'd25, 16'hFFEC);    // 17: R25 = -20
        emit_i(6'h08, 5'd0, 5'd26, 16'd3);       // 18: R26 = 3
        emit_r(25, 26, 27, 6'b011010);           // 19: R27 = -20 / 3 = -6
        emit_i(6'h08, 5'd0, 5'd23, 16'hFFFB);    // 20: R23 = -5

        // Signed compare operations: -20 < 3, -20 > 3 is false.
        emit_r(25, 26, 28, 6'b101011);           // 21: LT = 3
        emit_r(25, 26, 29, 6'b101010);           // 22: GT = 0
        emit_r(25, 25, 30, 6'b101000);           // 23: EQ = 1

        // Data memory store/load.
        emit_i(6'h2B, 5'd0, 5'd5, 16'd8);        // 24: SW R5, 8(R0)
        emit_i(6'h23, 5'd0, 5'd16, 16'd8);       // 25: LW R16, 8(R0)

        // BEQ taken: skip instruction 27.
        emit_i(6'h04, 5'd1, 5'd1, 16'd1);        // 26: taken -> PC index 28
        emit_i(6'h08, 5'd0, 5'd17, 16'd99);     // 27: must be skipped
        emit_i(6'h08, 5'd0, 5'd18, 16'd5);      // 28: R18 = 5

        // BEQ not taken.
        emit_i(6'h04, 5'd1, 5'd2, 16'd1);        // 29: not taken
        emit_i(6'h08, 5'd0, 5'd19, 16'd7);      // 30: R19 = 7

        // Jump: skip instruction 32 and continue at 33.
        emit(enc_j(26'd33));                    // 31: jump to word 33
        emit_i(6'h08, 5'd0, 5'd20, 16'd1);      // 32: must be skipped
        emit_i(6'h08, 5'd0, 5'd21, 16'd2);      // 33: R21 = 2

        // Unsupported R-type function must not write its destination.
        emit_i(6'h08, 5'd0, 5'd22, 16'd55);     // 34: R22 = 55
        emit_r(1, 2, 22, 6'b000000);             // 35: unsupported function; no write

        // Attempt to write R0; R0 must remain zero.
        emit_i(6'h08, 5'd0, 5'd0, 16'd123);     // 36: ADDI R0,R0,123

        // Additional immediate and address calculation checks.
        emit_i(6'h08, 5'd0, 5'd31, 16'h7FFF);   // 37: R31 = +32767
        emit_i(6'h08, 5'd0, 5'd11, 16'h8000);   // 38: R11 = -32768 (overwrite XOR result)
        emit_i(6'h08, 5'd11, 5'd12, 16'h0001);  // 39: R12 = -32767

        // Halt by jumping to this same instruction.
        emit(enc_j(26'd40));                    // 40: self-loop

        if (program_index != 41)
            fail($sformatf("Program length mismatch: loaded %0d words", program_index));

        $display("Loaded %0d instructions.", program_index);

        // Release reset and allow the processor to execute the program.
        repeat (2) @(negedge CLK);
        rst_n = 1'b1;

        // Enough cycles to execute through the final self-loop.
        repeat (65) @(negedge CLK);

        $display("\n---------------- Register checks ----------------");

        check_reg(0,  32'd0);
        check_reg(1,  32'd10);
        check_reg(2,  32'd3);
        check_reg(3,  32'd13);
        check_reg(4,  32'd7);
        check_reg(5,  32'd30);
        check_reg(6,  32'd3);
        check_reg(7,  32'd2);
        check_reg(8,  32'd11);
        check_reg(9,  32'hFFFFFFFD);
        check_reg(10, 32'hFFFFFFF4);
        check_reg(11, 32'hFFFF8000); // R11 overwritten by ADDI -32768
        check_reg(12, 32'hFFFF8001); // -32768 + 1
        check_reg(13, 32'd0);
        check_reg(14, 32'd2);
        check_reg(15, 32'd3);
        check_reg(16, 32'd30);
        check_reg(17, 32'd0);        // BEQ-taken instruction was skipped
        check_reg(18, 32'd5);
        check_reg(19, 32'd7);
        check_reg(20, 32'd0);        // Jump-skipped instruction
        check_reg(21, 32'd2);
        check_reg(22, 32'd55);       // Unsupported R-type did not overwrite
        check_reg(23, 32'hFFFFFFFB);
        check_reg(24, 32'd77);       // DIV-by-zero did not overwrite sentinel
        check_reg(25, 32'hFFFFFFEC);
        check_reg(26, 32'd3);
        check_reg(27, 32'hFFFFFFFA); // -6
        check_reg(28, 32'd3);        // signed LT
        check_reg(29, 32'd0);        // signed GT false
        check_reg(30, 32'd1);        // signed EQ true
        check_reg(31, 32'd32767);

        $display("\n---------------- Memory checks ----------------");
        check_word(8, 32'd30);

        $display("\n---------------- Control/error checks ----------------");
        checks++;
        if (div_zero_events != 1)
            fail($sformatf("Expected exactly 1 DIV-by-zero event, observed %0d",
                           div_zero_events));

        checks++;
        if (dut.PC !== (40 * 4))
            fail($sformatf("Final PC = 0x%08h, expected 0x%08h (self-loop at word 40)",
                           dut.PC, 40*4));

        checks++;
        if (dut.Division_Error !== 1'b0)
            fail("Division_Error should be LOW while executing the final J instruction");

        $display("\n======================================================");
        $display("Cycles observed : %0d", cycle_count);
        $display("Checks performed: %0d", checks);
        $display("DIV-by-zero hits: %0d", div_zero_events);
        $display("Errors          : %0d", errors);

        if (errors == 0)
            $display("*************** ALL TESTS PASSED ***************");
        else
            $display("*************** TESTS FAILED ***************");

        $display("======================================================\n");

        $stop;
    end

    // Global timeout guard.
    initial begin
        #(CLK_PERIOD * 250);
        fail("Global simulation timeout");
        $display("TIMEOUT: simulation did not finish normally.");
        $stop;
    end

endmodule
`timescale 1ns / 1ps

module tb_DSP48A1;

    // -----------------------------------------------------------
    // Inputs
    // -----------------------------------------------------------
    reg [17:0] A, B, D;
    reg [47:0] C;
    reg CLK;
    reg CARRYIN;
    reg [7:0] OPMODE;
    reg [17:0] BCIN;
    reg [47:0] PCIN;
    
    // Resets
    reg RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
    
    // Clock Enables
    reg CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;

    // -----------------------------------------------------------
    // Outputs
    // -----------------------------------------------------------
    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT, CARRYOUTF;
    wire [17:0] BCOUT;
    wire [47:0] PCOUT;

    // Internal variables for checking
    integer errors = 0;
    reg [47:0] past_P;
    reg past_CARRYOUT;

    // -----------------------------------------------------------
    // Instantiate the Unit Under Test (UUT)
    // -----------------------------------------------------------
    DSP48A1 uut (
        .A(A), .B(B), .D(D), .C(C), .CLK(CLK), .CARRYIN(CARRYIN), 
        .OPMODE(OPMODE), .BCIN(BCIN), 
        .RSTA(RSTA), .RSTB(RSTB), .RSTM(RSTM), .RSTP(RSTP), 
        .RSTC(RSTC), .RSTD(RSTD), .RSTCARRYIN(RSTCARRYIN), .RSTOPMODE(RSTOPMODE), 
        .CEA(CEA), .CEB(CEB), .CEM(CEM), .CEP(CEP), 
        .CEC(CEC), .CED(CED), .CECARRYIN(CECARRYIN), .CEOPMODE(CEOPMODE), 
        .PCIN(PCIN), .BCOUT(BCOUT), .PCOUT(PCOUT), .P(P), .M(M), 
        .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF)
    );

    // -----------------------------------------------------------
    // Clock Generation
    // -----------------------------------------------------------
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 10ns period
    end

    // -----------------------------------------------------------
    // Verification Sequence
    // -----------------------------------------------------------
    initial begin
        $display("=================================================");
        $display("       STARTING DSP48A1 VERIFICATION SEQUENCE    ");
        $display("=================================================");

        // =======================================================
        // 2.1. Verify Reset Operation
        // =======================================================
        $display("\n---> Running Test 2.1: Verify Reset Operation");
        // Assert all active-high reset signals
        RSTA = 1; RSTB = 1; RSTM = 1; RSTP = 1; 
        RSTC = 1; RSTD = 1; RSTCARRYIN = 1; RSTOPMODE = 1;
        // Drive remaining inputs with arbitrary values
        A = $random; B = $random; C = $random; D = $random;
        CARRYIN = $random; OPMODE = $random; BCIN = $random; PCIN = $random;
        
        // Wait for the negative edge of the clock
        @(negedge CLK);
        
        // Self-checking condition
        if (BCOUT !== 0 || M !== 0 || P !== 0 || PCOUT !== 0 || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("[FAIL] 2.1 Reset failed. Outputs are not zero.");
            errors = errors + 1;
        end else begin
            $display("[PASS] 2.1 Reset successful. All outputs are zero.");
        end

        // Deassert resets and assert clock enables
        RSTA = 0; RSTB = 0; RSTM = 0; RSTP = 0; 
        RSTC = 0; RSTD = 0; RSTCARRYIN = 0; RSTOPMODE = 0;
        CEA = 1; CEB = 1; CEM = 1; CEP = 1; 
        CEC = 1; CED = 1; CECARRYIN = 1; CEOPMODE = 1;


        // =======================================================
        // 2.2. Verify DSP Path 1
        // =======================================================
        $display("\n---> Running Test 2.2: Verify DSP Path 1");
        // ALREADY AT NEGEDGE: Apply inputs immediately
        OPMODE = 8'b11011101;
        A = 20; B = 10; C = 350; D = 25;
        BCIN = $random; PCIN = $random; CARRYIN = $random;

        // Wait for four negative clock edges
        repeat(4) @(negedge CLK);

        // Self-checking condition
        if (BCOUT !== 18'hf || M !== 36'h12c || P !== 48'h32 || PCOUT !== 48'h32 || CARRYOUT !== 1'b0 || CARRYOUTF !== 1'b0) begin
            $display("[FAIL] 2.2 Path 1 failed.");
            $display("       Got BCOUT=%h, M=%h, P=%h, CARRYOUT=%b", BCOUT, M, P, CARRYOUT);
            errors = errors + 1;
        end else begin
            $display("[PASS] 2.2 Path 1 successful.");
        end


        // =======================================================
        // 2.3. Verify DSP Path 2
        // =======================================================
        $display("\n---> Running Test 2.3: Verify DSP Path 2");
        OPMODE = 8'b00010000;
        A = 20; B = 10; C = 350; D = 25;
        BCIN = $random; PCIN = $random; CARRYIN = $random;

        // Wait for three negative edges
        repeat(3) @(negedge CLK);

        // Self-checking condition
        if (BCOUT !== 18'h23 || M !== 36'h2bc || P !== 48'h0 || PCOUT !== 48'h0 || CARRYOUT !== 1'b0 || CARRYOUTF !== 1'b0) begin
            $display("[FAIL] 2.3 Path 2 failed.");
            $display("       Got BCOUT=%h, M=%h, P=%h, CARRYOUT=%b", BCOUT, M, P, CARRYOUT);
            errors = errors + 1;
        end else begin
            $display("[PASS] 2.3 Path 2 successful.");
        end

        // Store past values for Path 3 check
        past_P = P; 
        past_CARRYOUT = CARRYOUT;


        // =======================================================
        // 2.4. Verify DSP Path 3
        // =======================================================
        $display("\n---> Running Test 2.4: Verify DSP Path 3");
        OPMODE = 8'b00001010;
        A = 20; B = 10; C = 350; D = 25;
        BCIN = $random; PCIN = $random; CARRYIN = $random; 

        // Wait for three negative edges
        repeat(3) @(negedge CLK);

        // Self-checking condition
        if (BCOUT !== 18'ha || M !== 36'hc8 || P !== past_P || PCOUT !== past_P || CARRYOUT !== past_CARRYOUT) begin
            $display("[FAIL] 2.4 Path 3 failed.");
            $display("       Got BCOUT=%h, M=%h, P=%h, CARRYOUT=%b", BCOUT, M, P, CARRYOUT);
            errors = errors + 1;
        end else begin
            $display("[PASS] 2.4 Path 3 successful.");
        end


        // =======================================================
        // 2.5. Verify DSP Path 4
        // =======================================================
        $display("\n---> Running Test 2.5: Verify DSP Path 4");
        OPMODE = 8'b10100111;
        A = 5; B = 6; C = 350; D = 25; PCIN = 3000;
        BCIN = $random; CARRYIN = $random;

        // Wait for three negative edges
        repeat(3) @(negedge CLK);

        // Self-checking condition
        if (BCOUT !== 18'h6 || M !== 36'h1e || P !== 48'hfe6fffec0bb1 || PCOUT !== 48'hfe6fffec0bb1 || CARRYOUT !== 1'b1 || CARRYOUTF !== 1'b1) begin
            $display("[FAIL] 2.5 Path 4 failed.");
            $display("       Got BCOUT=%h, M=%h, P=%h, CARRYOUT=%b", BCOUT, M, P, CARRYOUT);
            errors = errors + 1;
        end else begin
            $display("[PASS] 2.5 Path 4 successful.");
        end

        // =======================================================
        // End of Simulation Summary
        // =======================================================
        $display("\n=================================================");
        if (errors == 0) begin
            $display("   [SUCCESS] ALL VERIFICATION SCENARIOS PASSED!  ");
        end else begin
            $display("   [WARNING] SIMULATION FINISHED WITH %0d ERRORS.", errors);
        end
        $display("=================================================");
        
        #20;
        $finish;
    end

endmodule
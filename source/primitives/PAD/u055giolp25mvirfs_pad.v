`timescale 1 ns / 1 ps

module IPOC (PORE, VDD, VDDIO, VSS);
   inout VDD, VDDIO, VSS;
   output PORE;

    nand     NAND1    (PORE_SIG, VDDIO, VDD);
    bufif1   BUF1     (PORE, PORE_SIG, VDDIO);
endmodule



`ifdef functional
                // none
`else
    `define SMC_NFORCE 1    // Flag to force output to x if notifer changes
`endif

`celldefine

module IUMBFS (OE, IDDQ, DO, PIN1, PIN2, SMT, IE, PD, PU, DI, PAD, PORE, VDD, VDDIO, VSS, VSSIO);
  input OE, IDDQ, DO, PIN1, PIN2, SMT, IE, PD, PU;
  output DI;
  inout PAD, VDD, VDDIO, VSS, VSSIO, PORE;

    buf      bb1      (SMT_tmp, SMT);
    buf      bb2      (PIN1_tmp, PIN1);
    buf      bb3      (PIN2_tmp, PIN2);
    not      NOT1     (Not_PU, PU);
    not      NOT2     (Not_PD, PD);
    not      NOT3     (Not_OE, OE);
    not      NOT4     (Not_IDDQ, IDDQ);
    nand     NAND1    (PU_PMOS, PU, Not_PD, Not_OE, Not_IDDQ);
    and      AND1     (OUTPUT_EN, OE, Not_IDDQ); 
    bufif1   BUF1     (NMOS_PAD, DO, OUTPUT_EN);
    and      AND2     (PD_NMOS, Not_PU, PD, Not_OE, Not_IDDQ);
    and      AND3     (KEEPER_CTRL, PU, PD, Not_IDDQ);
    /* Pullup (Strength to Weak) */ 
    rpmos    PMOS1    (NMOS_PAD, PMOSA_out, PU_PMOS);
    rpmos    PMOSA    (PMOSA_out, PMOSB_out, PU_PMOS);
    rpmos    PMOSB    (PMOSB_out, 1'b1, PU_PMOS);    
    /* Pulldown (Strength to Weak) */
    rnmos    NMOS1    (NMOS_PAD, NMOSA_out, PD_NMOS);
    rnmos    NMOSA    (NMOSA_out, NMOSB_out, PD_NMOS);
    rnmos    NMOSB    (NMOSB_out, 1'b0, PD_NMOS);
    /* Keeper */ 
    not      NOT5     (NOT5_out, NMOS_PAD);
    not      NOT6     (NOT6_out, KEEPER_CTRL);
    not      NOT7     (NOT7_out, NOT5_out);
    rcmos    CMOS1    (NMOS_PAD, NOT7_out, KEEPER_CTRL, NOT6_out);
    /* INPUT & OUTPUT*/
    not      NOT8     (Not_PORE, PORE); 
    nmos     NMOS2    (PAD, NMOS_PAD, Not_PORE);
    and      AND4     (INPUT_EN, IE, Not_IDDQ);
    not      NOT9     (Not_INPUT_EN, INPUT_EN);
    bufif1   BUF2     (DI, PAD, INPUT_EN);
    nmos     NMOS3    (DI, 1'b0, Not_INPUT_EN); 

 `ifdef functional // functional //

  `else // functional //

  specify

    // arc IDDQ --> DI
    (IDDQ => DI) = (1.0);

    // arc IDDQ --> PAD
    (IDDQ => PAD) = (1.0);

    // arc DO --> PAD
    if (PIN1===1'b0 && PIN2===1'b0) 
        (DO => PAD) = (1.0, 1.0);

    // arc DO --> PAD
    if (PIN1===1'b1 && PIN2===1'b0) 
        (DO => PAD) = (1.0, 1.0);

    // arc DO --> PAD
    if (PIN1===1'b0 && PIN2===1'b1) 
        (DO => PAD) = (1.0, 1.0);

    // arc DO --> PAD
    if (PIN1===1'b1 && PIN2===1'b1) 
        (DO => PAD) = (1.0, 1.0);

    ifnone
        (DO => PAD) = (1.0, 1.0);

    // arc OE --> PAD
    if (PIN1===1'b0 && PIN2===1'b0) 
        (OE => PAD) = (1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0);

    // arc OE --> PAD
    if (PIN1===1'b1 && PIN2===1'b0) 
        (OE => PAD) = (1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0);
    
    // arc OE --> PAD
    if (PIN1===1'b0 && PIN2===1'b1) 
        (OE => PAD) = (1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0);
    
    // arc OE --> PAD
    if (PIN1===1'b1 && PIN2===1'b1) 
        (OE => PAD) = (1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0);
    
    ifnone
        (OE => PAD) = (1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0);

   // arc PAD --> DI
    if (PD===1'b0 && PU===1'b0 && SMT===1'b0) 
        (PAD => DI) = (1.0, 1.0);
    if (PD===1'b0 && PU===1'b0 && SMT===1'b1) 
        (PAD => DI) = (1.0, 1.0);

    // arc PAD --> DI
    if (PD===1'b1 && PU===1'b0 && SMT===1'b0) 
        (PAD => DI) = (1.0, 1.0);
    if (PD===1'b1 && PU===1'b0 && SMT===1'b1) 
        (PAD => DI) = (1.0, 1.0);

    // arc PAD --> DI
    if (PD===1'b0 && PU===1'b1 && SMT===1'b0) 
        (PAD => DI) = (1.0, 1.0);
    if (PD===1'b0 && PU===1'b1 && SMT===1'b1) 
        (PAD => DI) = (1.0, 1.0);

    // arc PAD --> DI
    if (PD===1'b1 && PU===1'b1 && SMT===1'b0) 
        (PAD => DI) = (1.0, 1.0);
    if (PD===1'b1 && PU===1'b1 && SMT===1'b1) 
        (PAD => DI) = (1.0, 1.0);

    ifnone
        (PAD => DI) = (1.0, 1.0);

    
    // arc IE --> DI
    if (PD===1'b0 && PU===1'b0 && SMT===1'b0) 
        (IE => DI) = (1.0, 1.0);
    if (PD===1'b0 && PU===1'b0 && SMT===1'b1) 
        (IE => DI) = (1.0, 1.0);

    // arc IE --> DI
    if (PD===1'b1 && PU===1'b0 && SMT===1'b0) 
        (IE => DI) = (1.0, 1.0);
    if (PD===1'b1 && PU===1'b0 && SMT===1'b1) 
        (IE => DI) = (1.0, 1.0);

    // arc IE --> DI
    if (PD===1'b0 && PU===1'b1 && SMT===1'b0) 
        (IE => DI) = (1.0, 1.0);
    if (PD===1'b0 && PU===1'b1 && SMT===1'b1) 
        (IE => DI) = (1.0, 1.0);

    // arc IE --> DI
    if (PD===1'b1 && PU===1'b1 && SMT===1'b0) 
        (IE => DI) = (1.0, 1.0);
    if (PD===1'b1 && PU===1'b1 && SMT===1'b1) 
        (IE => DI) = (1.0, 1.0);

    ifnone
        (IE => DI) = (1.0, 1.0); 

  endspecify

  `endif // functional //

endmodule

`endcelldefine
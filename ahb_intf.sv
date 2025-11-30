interface ahb_intf(input bit CLK);
 logic HRESETn;
 logic [31:0] HADDR;
 logic HWRITE;
 logic [1:0] HTRANS;
 logic [31:0] HWDATA;
 logic [2:0] HSIZE;
 logic [2:0] HBURST;
 logic HREADY_IN;

 logic HREADY_OUT;
 logic [31:0] HRDATA;
 logic [1:0]HRESP;

 //DRIVER clocking block

  clocking AHB_DRV_CB @(posedge CLK);
    default input #1 output #1;
    output HADDR;
    output HWDATA;
    output HWRITE;
    output HTRANS;
    output HSIZE;
    output HREADY_IN;
    output HBURST;
    output HRESETn;

    input HRDATA;
    input HREADY_OUT;
  endclocking



 //MONITOR CLOCKING BLOCK

  clocking AHB_MON_CB @(posedge CLK);
    default input #1 output #1;
    input HADDR;
    input HWDATA;
    input HWRITE;
    input HTRANS;
    input HSIZE;
    input HBURST;
    input HREADY_IN;
    input HRESETn;

    input HREADY_OUT;
    input HRDATA;
    input HRESP;
  endclocking


 //MODPORTS
  modport AHB_DRV_MP(clocking AHB_DRV_CB, input CLK);
  modport AHB_MON_MP(clocking AHB_MON_CB, input CLK);

endinterface

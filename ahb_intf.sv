interface ahb_intf(input HCLK, HRESETn);
 logic [31:0] HADDR;
 logic HWRITE;
 logic [1:0] HTRANS;
 logic [31:0] HWDATA;
 logic [2:0] HSIZE;

 logic HREADY;
 logic [31:0] HRDATA;
 logic HRESP;

 //DRIVER clocking block

  clocking ahb_drv_cb@(posedge HCLK);
    default input #1 output #1;
    output HADDR;
    output HWDATA;
    output HWRITE;
    output HTRANS;
    output HSIZE;
  endclocking



 //MONITOR CLOCKING BLOCK

  clocking ahb_mon_cb@(posedge HCLK);
    default input #1 output #1;
    input HADDR;
    input HWDATA;
    input HWRITE;
    input HTRANS;
    input HSIZE;

    input HREADY;
    input HRDATA;
    input HRESP;
  endclocking


 //MODPORTS
  modport AHB_DRV_MP(clocking ahb_drv_cb, input HCLK,HRESETn);
  modport AHB_MON_MP(clocking ahb_mon_cb, input HCLK,HRESETn);

endinterface

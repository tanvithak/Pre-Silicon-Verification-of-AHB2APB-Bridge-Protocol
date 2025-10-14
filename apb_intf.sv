interface apb_intf(input logic PCLK);
 logic PRESETn;
 logic [31:0] PADDR;
 logic [31:0] PWDATA;
 logic PWRITE;
 logic PSEL;
 logic PENABLE;

 logic PREADY;
 logic [31:0] PRDATA;

  //DRIVER CLOCKING BLOCK
  clocking apb_drv_cb@(posedge PCLK);
    default input #1 output #1;
    output PADDR;
    output PWDATA;
    output PWRITE;
    output PSEL;
    output PENABLE;
  endclocking

  //MONITOR CLOCKING BLOCK
  clocking apb_mon_cb@(posedge PCLK);
    default input #1 output #1;
    input PADDR;
    input PWDATA;
    input PWRITE;
    input PSEL;
    input PENABLE;
    input PRDATA;
    input PREADY;
  endclocking

  //MODPORTS
  modport APB_DRV_MP(clocking apb_drv_cb, input PCLK,PRESETn);
  modport APB_MON_MP(clocking apb_mon_cb, input PCLK,PRESETn);

endinterface

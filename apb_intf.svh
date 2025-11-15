interface apb_intf(input bit CLK);
 bit PRESETn;
 logic PENABLE;
 logic [3:0] PSEL;
 logic PWRITE;
 logic [31:0] PADDR;
 logic [31:0] PWDATA;

 logic [31:0] PRDATA;
 logic PREADY;

 clocking APB_DRV_CB@(posedge CLK);
  default input #1 output #1;
  output PRESETn;
  output PENABLE;
  output PSEL;
  output PWRITE;
  output PADDR;
  output PWDATA;
 endclocking

 clocking APB_MON_CB@(posedge CLK);
  default input #1 output #1;
  input PRESETn;
  input PENABLE;
  input PSEL;
  input PWRITE;
  input PADDR;
  input PWDATA;
  input PRDATA;
  input PREADY;
 endclocking

 //MODPORTS
  modport APB_DRV_MP(clocking APB_DRV_CB, input CLK);
  modport APB_MON_MP(clocking APB_MON_CB, input CLK);

endinterface

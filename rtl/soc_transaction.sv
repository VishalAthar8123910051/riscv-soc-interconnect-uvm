
class soc_transaction extends uvm_sequence_item;

  // Transaction fields
  rand bit        we;
  rand bit [31:0] addr;
  rand bit [31:0] wdata;
  rand bit [3:0]  wstrb;

  bit [31:0] rdata;

  // Register with UVM factory
  `uvm_object_utils_begin(soc_transaction)
    `uvm_field_int(we,    UVM_ALL_ON)
    `uvm_field_int(addr,  UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(wstrb, UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "soc_transaction");
    super.new(name);
  endfunction

  // Basic address constraints
  constraint c_alignment {
    addr[1:0] == 2'b00;
  }

  constraint c_valid_address {
    addr inside {
      [32'h00000000:32'h00003FFC],
      [32'h00004000:32'h00005FFC],
      [32'h00006000:32'h0000600C]
    };
  }

endclass

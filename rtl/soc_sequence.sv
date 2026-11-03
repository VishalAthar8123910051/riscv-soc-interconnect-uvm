
class soc_sequence extends uvm_sequence #(soc_transaction);

  `uvm_object_utils(soc_sequence)

  function new(string name = "soc_sequence");
    super.new(name);
  endfunction

  // Send one directed transaction
  task do_transfer(
    bit [31:0] address,
    bit        write_enable,
    bit [31:0] data,
    bit [3:0]  strobe
  );

    soc_transaction tr;

    tr = soc_transaction::type_id::create("tr");

    start_item(tr);

    if (!tr.randomize() with {
      addr  == address;
      we    == write_enable;
      wdata == data;
      wstrb == strobe;
    }) begin
      `uvm_error("SEQ", "Directed transaction randomization failed")
    end

    finish_item(tr);

  endtask

  task body();

    `uvm_info("SEQ", "Starting directed write-read test", UVM_LOW)

    // SRAM
    do_transfer(32'h00000100, 1, 32'h1234ABCD, 4'hF);
    do_transfer(32'h00000100, 0, 32'h00000000, 4'hF);

    // Frame Buffer
    do_transfer(32'h00004000, 1, 32'h5678ABCD, 4'hF);
    do_transfer(32'h00004000, 0, 32'h00000000, 4'hF);

    // MMIO REG0
    do_transfer(32'h00006000, 1, 32'h11112222, 4'hF);
    do_transfer(32'h00006000, 0, 32'h00000000, 4'hF);

    // MMIO REG1
    do_transfer(32'h00006004, 1, 32'h33334444, 4'hF);
    do_transfer(32'h00006004, 0, 32'h00000000, 4'hF);

    // MMIO REG2
    do_transfer(32'h00006008, 1, 32'h55556666, 4'hF);
    do_transfer(32'h00006008, 0, 32'h00000000, 4'hF);

    // MMIO REG3
    do_transfer(32'h0000600C, 1, 32'h77778888, 4'hF);
    do_transfer(32'h0000600C, 0, 32'h00000000, 4'hF);

    `uvm_info("SEQ", "Directed write-read test completed", UVM_LOW)

  endtask

endclass

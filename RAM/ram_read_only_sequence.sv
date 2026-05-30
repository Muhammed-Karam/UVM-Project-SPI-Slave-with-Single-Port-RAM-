package ram_read_only_sequence_pkg;
    import uvm_pkg::*;
    import ram_seq_item_pkg::*;
    `include "uvm_macros.svh"
    
    class ram_read_only_sequence extends uvm_sequence #(ram_seq_item);
        `uvm_object_utils(ram_read_only_sequence)
        
        ram_seq_item seq_item;
        
        function new(string name = "ram_read_only_sequence");
            super.new(name);
        endfunction
        
        task body;
            seq_item = ram_seq_item::type_id::create("seq_item");
            seq_item.prev_cmd = ram_seq_item_pkg::READ_ADDR;
            repeat(2000) begin
                
                start_item(seq_item);
                
                seq_item.rst_c.constraint_mode(1);
                seq_item.rx_valid_c.constraint_mode(1);
                seq_item.write_only_c.constraint_mode(0);  
                seq_item.read_only_c.constraint_mode(1);   
                seq_item.write_read_c.constraint_mode(0);  
                
                assert(seq_item.randomize());
                
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
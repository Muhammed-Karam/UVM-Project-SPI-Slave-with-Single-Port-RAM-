package ram_config_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    class ram_config extends uvm_object;
        `uvm_object_utils(ram_config)
        
        virtual ram_if ram_vif;
        uvm_active_passive_enum is_active;
        
        function new(string name = "ram_config");
            super.new(name);
            is_active = UVM_ACTIVE; // Default value
        endfunction
    endclass
endpackage
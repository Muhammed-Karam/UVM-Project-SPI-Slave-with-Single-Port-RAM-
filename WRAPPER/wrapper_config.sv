package wrapper_config_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    class wrapper_config extends uvm_object;
        `uvm_object_utils(wrapper_config)
        
        virtual wrapper_if wrapper_vif;
        virtual spi_slave_if spi_vif;
        virtual ram_if ram_vif;
        uvm_active_passive_enum is_active;
        
        function new(string name = "wrapper_config");
            super.new(name);
            is_active = UVM_ACTIVE;
        endfunction
    endclass
endpackage
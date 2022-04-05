package wb_pkg;

    import ncsu_pkg::*;
    import i2c_pkg::*;
    import data_types_pkg::*;

    `include "../../ncsu_pkg/ncsu_macros.svh"
    
    `include "src/wb_configuration.svh"
    `include "src/wb_transaction.svh"
    `include "src/wb_driver.svh"
    `include "src/wb_monitor.svh"
    `include "src/wb_agent.svh"
endpackage

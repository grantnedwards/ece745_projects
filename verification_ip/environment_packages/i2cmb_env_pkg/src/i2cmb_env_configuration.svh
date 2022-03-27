class i2cmb_env_configuration extends ncsu_configuration;
    wb_configuration wishbone_config;
    i2c_configuration i2c_config;

    function new(string name=""); 
        super.new(name);
        wishbone_config = new("wishbone_config");
        i2c_config = new("i2c_config");
    endfunction
    
endclass
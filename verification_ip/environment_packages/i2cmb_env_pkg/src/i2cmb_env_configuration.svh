class i2cmb_env_configuration extends ncsu_configuration;
    wb_configuration wishbone_config;
    i2c_configuration i2c_config;
    bit       loopback;
    bit       invert;
    bit [3:0] port_delay;

    covergroup i2cmb_env_configuration_cg;
        option.per_instance = 1;
        option.name = name;
        coverpoint loopback;
        coverpoint invert;
        coverpoint port_delay;
    endgroup

    function void sample_coverage();
  	    i2cmb_env_configuration_cg.sample();
    endfunction

    function new(string name="");
        super.new(name);
        i2cmb_env_configuration_cg = new;
        i2c_config = new("i2c_config");
        wishbone_config = new("wb_config");
        wishbone_config.collect_coverage=0;
        i2c_config.sample_coverage();
        wishbone_config.sample_coverage();
    endfunction

endclass

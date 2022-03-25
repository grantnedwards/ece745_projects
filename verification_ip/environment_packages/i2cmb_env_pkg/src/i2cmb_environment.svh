class i2cmb_environment;
    virtual wb_agent wishbone_side;
    virtual i2c_agent i2c_side;

    virtual i2cmb_predictor predictor;
    virtual i2cmb_coverage coverage;
    virtual i2cmb_scoreboard scoreboard;
endclass
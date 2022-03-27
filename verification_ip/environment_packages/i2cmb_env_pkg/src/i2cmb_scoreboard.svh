class i2cmb_scoreboard extends ncsu_component#(.T(ncsu_transaction));
  i2c_transaction trans_in;
  i2c_transaction trans_out;

  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
  endfunction

  virtual function void nb_transport(input T input_trans, output T output_trans);
    $cast(trans_in, input_trans);
    $cast(output_trans, trans_out);
  endfunction

  virtual function void nb_put(T trans);
    i2c_transaction input_trans;
    $cast(input_trans, trans);
  endfunction
endclass
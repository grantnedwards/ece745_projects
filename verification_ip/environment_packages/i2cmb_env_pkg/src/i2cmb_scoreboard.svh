class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));
bit flag2;
bit flag1;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
    flag2 = 1'b0;
    flag2 = 1'b0;
  endfunction

  T trans_in;
  T trans_out;
  T temp;

  virtual function void nb_transport(input T input_trans, output T output_trans);
    $display({get_full_name(), " nb_transport: expected transaction ", input_trans.convert2string()});
    $cast(trans_in, input_trans);
    if (flag1)
      begin
        if (trans_in.compare(temp)==1)$display({get_full_name(), "transaction MISMATCH"});
        else $display({get_full_name(), "transaction MATCH"});
        flag1 = 1'b0;
      end
    else flag2 = 1'b1;
    $cast(output_trans, trans_out);
    endfunction

    virtual function void nb_put(T trans);
      if (flag2)
        begin
          if (trans_in.compare(trans)==1)$display({get_full_name(), "transaction MISMATCH"});
          else $display({get_full_name(), "transaction MATCH"});
          flag2 = 1'b0;
        end
      else
        begin
          temp = trans;
          flag1 = 1'b1;
        end
    endfunction



endclass

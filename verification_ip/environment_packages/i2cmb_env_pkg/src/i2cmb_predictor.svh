class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

  i2cmb_scoreboard scoreboard;
  i2c_transaction pred;
  i2c_transaction act;
  i2cmb_env_configuration configuration;
  int bus;
  bit [7:0] temp;
  state_t state;
  bit flag;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
    state = STARTER;
    bus = 0;
    flag = 0;
  endfunction

  virtual function void nb_put(T trans);
    wb_transaction wb;

    $cast(wb, trans);
    //$display(wb.data);
    case(state)
      STARTER : begin
        flag = 0;
        if((wb.addr == CMDR)&&(wb.data[2:0] == 3'b100)&&(wb.op==WRITE))
          begin
            pred = new("pred");
            pred.bus = bus;
            state = RUNNER;
          end
        if((wb.addr == DPR)&&(wb.op == WRITE))
          begin
            state = WRITER;
            temp = wb.data;
          end
      end
      RUNNER : begin
        if((wb.addr == DPR) && (wb.op == WRITE))
          begin
            state = WRITER;
            temp = wb.data;
          end
        else if((wb.addr == CMDR) && (wb.op == WRITE))
          begin
            if(wb.data[2:0]==3'b101) begin
              state = STARTER;
              scoreboard.nb_transport(pred, act);
            end
            else if(wb.data[2:0]==3'b010)state = READER;
          end
      end
      WRITER : begin
        if((wb.addr == CMDR)&&(wb.data[2:0] == 3'b110))begin
          state = STARTER;
          bus = temp;
        end
        else begin
          if((wb.addr == CMDR)&&(wb.data[2:0] == 3'b001))begin
            if(flag)begin
              pred.burst += 1;
              pred.data = new[pred.burst](pred.data);
              pred.data[pred.burst-1] = temp;
              //scoreboard.nb_transport(pred, act);
            end
            else begin
              //$display(temp);
              pred.addr = temp >> 1;
              pred.op = temp[0] ? WRITE : READ;
              flag = 1;
            end
          end
          else $display("DPR without Bus Write - Check Predictor/WB Transactions");
          state = RUNNER;
        end
      end
      READER : begin
        if((wb.addr == DPR) && (wb.op == READ))begin
          state = RUNNER;
          pred.burst += 1;
          pred.data = new[pred.burst](pred.data);
          pred.data[pred.burst-1] = wb.data;
        end
        else if((wb.addr != CMDR) && (wb.op != READ))begin
          //$display("Read without DPR - Check Predictor/ WB Transactions");
        end
      end
      default : state = STARTER;

    endcase
  endfunction



  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(i2cmb_scoreboard scoreboard);
      this.scoreboard = scoreboard;
  endfunction
endclass

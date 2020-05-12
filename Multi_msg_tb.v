module Multi_msg_tb;

  reg rst_n, clk;
  reg last_data, data_valid;
  reg [ 7:0] data;
  integer err;
  
  wire checksum_valid;
  wire [31:0] checksum;

  adler32 DUT (
    .rst_n( rst_n ),
    .clock( clk ),
    .data_valid( data_valid ),
    .data( data ),
    .last_data( last_data ),
    .checksum_valid( checksum_valid ),
    .checksum( checksum )
  );

  always #5 clk = ~clk;

  // initialize the clock and then
  // perform the reset
  initial
  begin
        rst_n = 0;
        clk   = 0;
    #20 rst_n = 1;
  end

  initial
  begin
  
    $monitor( $time, ":  checksum presently %08h", checksum );
    err = 0;

    // on simulation startup
    data_valid = 0;
    last_data  = 0;
    data       = 0;

    #160
    data_valid = 1;
    data       = 8'd72;    // H
    #10
    data_valid = 0;
    data       = 8'h63;    // random

    #60
    data_valid = 1;
    data       = 8'd101;   // e
    #10
    data_valid = 0;
    data       = 8'h65;    // random

    #60
    data_valid = 1;
    data       = 8'd108;   // l
    #20
    data_valid = 0;
    data       = 8'hed;    // random

    #60
    data_valid = 1;
    last_data  = 1;
    data       = 8'd111;   // o
    #10
    data_valid = 0;
    last_data  = 0;
    data       = 8'hc6;    // random

    wait ( checksum_valid == 1 );
    @( posedge clk )
      if( checksum == 32'h058c01f5 )
        $display( "First Checksum Matches" );
      else begin
        err = 1;
        $display( "First Checksum Failed" );
      end

    wait ( checksum_valid == 0 );
    @( negedge clk );

    #80
    data_valid = 1;
    data       = 8'd87;    // W
    #10
    data_valid = 0;
    data       = 8'ha5;    // random

    #110
    data_valid = 1;
    data       = 8'd111;   // o
    #10
    data_valid = 0;
    data       = 8'h5a;    // random

    #40
    data_valid = 1;
    data       = 8'd114;   // r
    #10
    data       = 8'd108;   // l
    #10
    data_valid = 0;
    data       = 8'h3c;    // random

    #90
    data_valid = 1;
    last_data  = 1;
    data       = 8'd100;   // d
    #10
    data_valid = 0;
    last_data  = 0;
    data       = 8'h55;    // random

    wait ( checksum_valid == 1 );
    @( posedge clk )
      if( checksum == 32'h06060209 )
        $display( "Second Checksum Matches" );
      else begin
        err = 1;
        $display( "Second Checksum Failed" );
      end

    #50
    if( err > 0 )
      $display( "One or more messages failed" );
    else
      $display( "All messages passed" );

    $stop;

  end

endmodule

module hello_str_tb;

  // the checksum for this testbench is
  // held as a parameter; the data are
  // loaded into an array below
  parameter CKSUM = 32'h058c01f5;

  // the size of the memory is held as
  // a parameter to make it easier to
  // try out different messages
  parameter MEMSZ = 5;

  reg rst_n, clk;
  wire [ 7:0] data;
  wire last_data, data_valid;
  
  wire checksum_valid;
  wire [31:0] checksum;

  wire lfsr_xor;
  wire [1:16] lfsr_in;
  reg  [1:16] lfsr;

  // this idx_cnt is the number of bits in
  // a counter that increments on each
  // data_valid; it should be made large
  // enough to send all of the data
  reg  [ 3:0] idx_cnt;

  reg   [7:0] memory [MEMSZ-1:0];

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

  // initialize the memory
  initial
  begin

    memory[0] = 8'd72;    // H
    memory[1] = 8'd101;   // e
    memory[2] = 8'd108;   // l
    memory[3] = 8'd108;   // l
    memory[4] = 8'd111;   // o

  end

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
    wait ( last_data && data_valid ) #100 $stop;
  end

  // self checking portion
  always @( posedge clk )
  begin
    if( checksum_valid ) begin
      if( checksum == CKSUM )
        $display( "CHECKSUMS MATCH: PASS" );
      else
        $display( "CHECKSUMS DON'T MATCH [%h] != solution [%h]",
          checksum, CKSUM );
    end
  end

  always @( posedge clk )
    if( !rst_n )
      idx_cnt = 0;
    else
      if( data_valid )
        idx_cnt = idx_cnt + 1;

  assign data_valid = ( lfsr[1:4] == 4'b0110 );
  assign data = data_valid ? memory[idx_cnt] : lfsr[3:10];
  assign last_data = ( data_valid & ( idx_cnt == (MEMSZ-1) ) );

  assign lfsr_xor = ^{ lfsr[16], lfsr[14], lfsr[13], lfsr[11] };
  assign lfsr_in  = { lfsr_xor, lfsr[1:15] };
  always @( posedge clk )
    if( !rst_n )
      lfsr = 16'h0001;
    else
      lfsr = lfsr_in;

endmodule

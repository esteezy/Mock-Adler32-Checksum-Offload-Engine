module hello_offset_tb;

  // the checksum for this testbench is
  // held as a parameter; the data are
  // loaded into an array below
  parameter CKSUM = 32'h058c01f5;

  // the size of the memory is held as
  // a parameter to make it easier to
  // try out different messages
  parameter MEMSZ = 5;

  reg rst_n, clk;
  reg last_data, data_valid;
  reg [ 7:0] data;
  
  wire checksum_valid;
  wire [31:0] checksum;

  reg   [7:0] memory [MEMSZ-1:0];
  integer delay, i, zero;

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

    data       = 0;
    data_valid = 0;
    last_data  = 0;

    // wait until the reset has released
    wait ( rst_n == 1 );

    // now wait until the rising edge following
    // the de-assertion of reset
    @( posedge clk );

    // wait at least 10 clock cycles and then
    // a random number before the first data
    // valid assertion
    delay = 10 + {$random} % 5;
    repeat ( delay ) @( posedge clk );

    // offset a half period
    #5;

    // repeat asserting data_valid for a clock
    // cycle and then waiting a random number
    // of clock cycles until all the data are
    // provided
    for( i=0;  i<MEMSZ; i=i+1 ) begin

      data_valid = 1;
      last_data  = ( i == MEMSZ-1 ) ? 1 : 0;
      data       = memory[i];

      #10
          last_data    = 0;

          // decide 3/4 of the time to keep the
          // data flowing from one cycle to the
          // next; only 1/4 of the time use a
          // delay
          zero = ({$random} % 4) > 2;
          if( zero )
            delay = 0;
          else
            delay        = {$random} % 10;

          // check the delay and wait that many
          // clock cycles before moving on to the
          // next byte of data
          if( delay !=0 ) begin
            data       = {$random} % 256;
            data_valid = 0;

            // delay for a number of rising edges
            // and then offset a half period
            repeat ( delay ) @( posedge clk );
            #5;
          end

    end

    #50 $stop;
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

endmodule

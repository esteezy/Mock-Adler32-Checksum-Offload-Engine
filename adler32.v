//alder 32
//Project 2 ECE310
//Evan Mason

module adler32(
    input rst_n, clock, data_valid,
    input [7:0] data,
    input last_data,
    output reg checksum_valid,
    output reg [31:0] checksum
);

reg [15:0] A;
reg [15:0] B;

//main procedural block - clocked
always @ (posedge clock)
begin
	//top-level constraints
	if(!rst_n || checksum_valid)
	begin
		A = 1;
		B = 0;
	end

	//process valid input datum
	if(data_valid)
	begin
		//last data of message
		if(last_data)
		begin
			checksum_valid = 1;
		end
		
		//accumulator
		A = A + data;
		B = B + A;
		if(A > 65521)
		begin
			A = A % 65535;
		end
		if(B > 65521)
		begin
			B = B % 65535;
		end

	end

	else
	begin
		checksum_valid = 0;
	end
	
	//concatenate 
	checksum[31:0] = {B, A};

end


endmodule

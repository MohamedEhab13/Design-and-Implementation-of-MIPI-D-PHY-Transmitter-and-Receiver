//=============================================================================
// File       : counter.v
// Author     : Mohamed Ehab
// Date       : April 18, 2025
// Description: 
//    Parameterizable synchronous counter module.
//    
//    This module counts up from 0 until it reaches (max_count - 1), then resets
//    to 0 on the next clock cycle. It asserts a `done` signal when the count
//    reaches (max_count - 1).
//
//==============================================================================

module counter (                           
	input               clock    ,         
	input               reset    ,         
	input               en,                
    input        [4:0]  max_count,         
	output              done     ,        
    output reg   [4:0]  count              
);
  

// Count untill max_count is reached 
	always@(posedge clock) begin           
		if((reset) | (count==max_count-1)) 
			count <= 0;                    
		else if(en)                        
			count <= count+1;             
	end

	assign done = (count==max_count-1);    

endmodule                                  
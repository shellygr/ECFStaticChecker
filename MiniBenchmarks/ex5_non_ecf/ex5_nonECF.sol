pragma solidity ^0.5.0;

contract Example_5_nonECF {
	
	// it is not ECF: we can not move the callbacks outside of the execution (only from one call point to the other)_
    
    uint x;
    uint y;
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
        x = 0;
        y = 0;
		
		//call 1
		msg.sender.send(0);
        
        x = x + 1;
        y = y + 1;
        
        //call 2
        msg.sender.send(0);

        x = x * 5;
        y = y * 5;
		lock = 0;
	}
		
    function ecf_cb_invariant() public {
        require (lock == 1);
    }
	
    function f1() public {
        x = x + 1;
    }

    function f2() public {
        y = y + 1;
    }


}
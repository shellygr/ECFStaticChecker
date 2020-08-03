pragma solidity ^0.5.0;

contract Example_6_ECF {
	
	// it is ECF: f1 and f2 left move for all the callbacks
    
    uint x;
    uint y;
	
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
		
        x = x + 1;
        y = y + 1;
		
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
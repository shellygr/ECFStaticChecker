pragma solidity ^0.5.0;

contract Example_6_nonECF {
	
	// it is not ECF: f1 belong to MRight(c_1), f2 to MLeft(c_2) but they do not commute
    
    uint x;
    uint y;
    uint z;
	
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
		
        x = 0;
        y = y + 1;
		
		//call 1
		msg.sender.send(0);
        
        x = x + 1;
        y = y + 1;
        
        //call 2
        msg.sender.send(0);

        x = x + 1;
        y = y * 5;
		
		lock = 0;
	}
	
	function ecf_cb_invariant() public {
        require (lock == 1);
    }
	
    function f1() public {
        x = x + 1;
        z = 0;
    }

    function f2() public {
        y = y + 1;
        z = 1;
    }


}
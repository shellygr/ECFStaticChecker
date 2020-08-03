pragma solidity ^0.5.0;

contract Example_1_nonECF {
	
	//f1 and f2 don't commute so the contract is not ECF
    
    uint x;
    uint y;
    uint z;
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
		y = y * 5;
		
		//call
		msg.sender.send(1);

		x = x * 5;
		lock = 0;
	}
	
    function f1() public {
        // commutes with the suffix
    	y = y + 2;
    	z = 1;
    }

    function f2() public {
    	// commutes with the prefix
    	x = x + 2;
    	z = 0;
    }
	
	function ecf_cb_invariant() public {
        require (lock == 1);
    }
}

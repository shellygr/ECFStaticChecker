pragma solidity ^0.5.0;

contract Example_2_ECF {
	
	//f1 and f2 commute so the contract is ECF
    
    uint x;
    uint y;
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
		if (x == 1){

			//call()
			msg.sender.send(0);
			
			y = y + 2;
		}
		lock = 0;
	}
	
	function ecf_cb_invariant() public {
        require (lock == 1);
    }
	
    function f1() public {
        // commutes with the suffix
    	x = 0;
    }

    function f2() public {
        // commutes with the prefix
        y = 0;
    	
    }
}
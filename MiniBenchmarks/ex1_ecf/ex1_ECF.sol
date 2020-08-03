pragma solidity ^0.5.0;

contract Example_1_ECF {
	
	//f1 and f2 commute so the contract is ECF
    
    uint x;
    uint y;
	
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock=1;
		y = y * 5;
		
		//call()
        msg.sender.send(0);

		x = x * 5;
		lock = 0;
	}
	
	function ecf_cb_invariant() public {
        require (lock == 1);
    }
	
    function f1() public {
        // commutes with the suffix
    	y = y + 2;
    }

    function f2() public {
    	// commutes with the prefix
    	x = x + 2;
    }
}

/*
		pref_main		( f1 ; main ; f2 ) 		pref_suff 

		but main can't really do something in a callback. need the callback invariant lock == 1
*/
pragma solidity ^0.5.0;

contract Example_3_ECF {
	
	// f1 and f2 commute so the contract is ECF
    
    uint x;
    uint y;
    uint z;
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
        uint aux = x;
        
		
		//call
		msg.sender.send(0) ;

        z = z + 1;
		y = aux;
		lock = 0;
	}
    
    function ecf_cb_invariant() public {
        require (lock == 1);
    }
    
    function f1() public {
        // only commutes with the suffix
        x = 5;
    }

    function f2() public {
        // only commutes with the prefix
        z = 0;
        y = 0;
    }

}
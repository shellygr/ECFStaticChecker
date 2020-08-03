pragma solidity ^0.5.0;

contract Example_4_ECF {
	
	// f1 commutes or projects with the left-segment so the contract is ECF
    
    uint x;
    uint y;
	
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
        x = x * 5;
		
		//call
		msg.sender.send(0);

        if (y >= 0){
            // this trace commutes with f1
            x = x + 1;
        }
        else{
            // this trace projects with f1
            x = 0 ;
        }
		lock = 0;
	}
	
	function ecf_cb_invariant() public {
        require (lock == 1);
    }
	
    function f1() public {
        // only commutes with the suffix
        x = x + 1;
    }


}
pragma solidity ^0.5.0;

contract Example_2_nonECF {
	
	//f1 and f2 commute so the contract is ECF
    
    uint x;
    uint y;
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
		if (x == 1){

			//call()
			msg.sender.send(1);
			
			x = x + 2;
		}
		lock = 0;
	}
	
	function ecf_cb_invariant() public {
        require (lock == 1);
    }
    
    function f1() public {
        // does not commute with the left or right segment
    	x = 0;
    }
}
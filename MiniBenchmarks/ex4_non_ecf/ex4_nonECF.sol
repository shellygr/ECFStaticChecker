pragma solidity ^0.5.0;

contract Example_4_nonECF {
	
	// f1 does not left or right move so the contract is not ECF
    
    uint x;
    uint y;
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
        x = x * 5;
		
		//call
		msg.sender.send(1);

        if (x % 2 == 0){
            x = x + 1;
        }
        else{
            x = 0 ;
        }
		lock = 0;
	}
	
    function ecf_cb_invariant() public {
        require (lock == 1);
    }
	
    function f1() public {
        // does not move with the prefix or suffix 

        x = x + 1;
    }


}
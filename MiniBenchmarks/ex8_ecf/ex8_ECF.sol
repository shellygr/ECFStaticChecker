pragma solidity ^0.5.0;

contract Example_8_ECF {
	
	// it is ECF: c1 and c2 are not reachable one from the other
    // Then, it does not matter that f1 belongs to MRight(c_1) \cap MLeft(c_2)
    
    uint x;
    uint z;
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;

        if (z > 10){
            x = 0;
            //call 1
		    msg.sender.send(0);

            x = x + 1;

        }
        else{
            x = x + 1;

            //call 2
		    msg.sender.send(0);

            x = x * 5;
        
        }
		
		lock = 0;
	}
	
	function ecf_cb_invariant() public {
        require (lock == 1);
    }
	
    function f1() public {
        x = x + 1;
    }

}
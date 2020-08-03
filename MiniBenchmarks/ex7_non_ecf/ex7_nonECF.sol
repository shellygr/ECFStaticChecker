pragma solidity ^0.5.0;

contract Example_7_nonECF {
	
	// it is not ECF: f3 belongs to MRight(c_1) because it does not commute with f1 and f1 to MLeft(c_2) (it does not commute with f2)

    // example of bad execution: including the callbacks in any of the two nodes f1; f3 ; f2 
    
    uint x;
    uint y;
    uint z;
    uint z1;
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
        z = z + 1;
    }

    function f2() public {
        y = y + 1;
        z1 = z1 + 1;
    }

    function f3() public {
        z1 = z1 * 5;
        z = z * 5;
    }

}
pragma solidity ^0.5.0;

contract Example_3_nonECF {
	
    
    uint x;
    uint y;
    uint z;
	uint lock;
	
	function main() public {
		require (lock == 0);
		lock = 1;
        uint aux = x;
        
		
		//call
		msg.sender.send(0);

        z = 1;
		y = aux;
		lock = 0;
	}
	
	function ecf_cb_invariant() public {
        require (lock == 1);
    }
		
    function f1() public {
        // does not commute with the prefix or suffix --> local variable aux
        z = 0;
        x = 5;
    }

}

// in a way it is ecf. main ; f1; main is giving (z=1,y=5,x=5) the same as  main { f1 }
// the approach of local variable dependency checking fails when we copy from storage to memory. without quantifiers we can't reason about it precisely.

// if the prefix choice includes the continuation then how f1 commutes with aux=x;z=1;y=aux ??? with cb we get {y=*,z=0,x=5} without it {y=5,z=0,x=5}
// so same thing! prefix should continue as if cb was not called
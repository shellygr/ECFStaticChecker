pragma solidity ^0.5.0;

contract Bank {

    mapping (address => uint) public shares;
	uint _guardCounter = 0;
	
	modifier nonReentrant() {
		if (_guardCounter == 0) {
			_guardCounter += 1;		
			_;
			_guardCounter -= 1;
			require(_guardCounter == 0);
		} else {
			_guardCounter += 1;
			require(_guardCounter != 0); /* checking it's not an overflow */
		}
    }
	
	function deposit() public payable  nonReentrant  {
		shares[msg.sender] += msg.value;
	}
	
    function withdraw() public  nonReentrant { // should be non-ECF because we don't assume the invariant, unless we include reverts of the suffix as a condition that validates cb;suffix right move checks
		uint256 orig_balance = address(this).balance;
		uint256 orig_shares = shares[msg.sender];
        if (orig_shares > 0 && orig_balance >= orig_shares) {
            if (!msg.sender.send(orig_shares)) { // msg.sender.call.value(orig_shares).gas(...)
				revert();
			}

			shares[msg.sender] = 0;
        }
		
    }
	
	function withdraw_with_inv_assumed() public nonReentrant { // should be ECF
		require(_guardCounter == 0);
		withdraw();
	}
}

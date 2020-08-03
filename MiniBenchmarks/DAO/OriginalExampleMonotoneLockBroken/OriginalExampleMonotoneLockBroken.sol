pragma solidity ^0.5.0;

contract Bank {

    mapping (address => uint) public shares;
	uint _guardCounter = 0;
	
	modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "re-entered");
    }
	
	function deposit() public payable { /* if deposit is not marked as nonReentrant, then it could execute as callback and affect the withdrawer, if it is also caller of the callback. */
		shares[msg.sender] += msg.value;
	}
	
    function withdraw() public nonReentrant {
		uint256 orig_balance = address(this).balance;
		uint256 orig_shares = shares[msg.sender];
        if (orig_shares > 0 && orig_balance >= orig_shares) {
            if (!msg.sender.send(orig_shares)) { // msg.sender.call.value(orig_shares).gas(...)
				revert();
			}

			shares[msg.sender] = 0;
        }
		
    }
}

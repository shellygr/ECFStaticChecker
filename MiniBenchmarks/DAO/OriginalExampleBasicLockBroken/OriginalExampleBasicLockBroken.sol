pragma solidity ^0.5.0;

contract Bank {

    mapping (address => uint) public shares;
	bool lock = false;
	
	function deposit() public payable {
		shares[msg.sender] += msg.value;
	}
	
    function withdraw() public {
		require (!lock);

		uint256 orig_balance = address(this).balance;
		uint256 orig_shares = shares[msg.sender];
        if (orig_shares > 0 && orig_balance >= orig_shares) {
			lock = true;
            if (!msg.sender.send(orig_shares)) { // msg.sender.call.value(orig_shares).gas(...)
				revert();
			}
			lock = false;

			shares[msg.sender] = 0;
        }
		
    }
}

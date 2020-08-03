pragma solidity ^0.5.0;

contract Bank {

    mapping (address => uint) public shares;

	function deposit() public payable {
		require(address(this) != msg.sender);
		require(shares[msg.sender]+msg.value>=msg.value);
		shares[msg.sender] += msg.value;
	}
	
    function withdraw() public {
		uint256 orig_balance = address(this).balance;
		uint256 orig_shares = shares[msg.sender];
        if (orig_shares > 0 && orig_balance >= orig_shares) {
			shares[msg.sender] = 0;
            if (!msg.sender.send(orig_shares)) { // msg.sender.call.value(orig_shares).gas(...)
				revert();
			}

        }
		
    }
}

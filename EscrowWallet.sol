pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract EscrowWallet is Ownable {
	using SafeMath for uint256;
	
	GeneralContract settings;

	constructor (address _generalContractAddress) public {		
		require(_generalContractAddress != address(0));

		settings = GeneralContract(_generalContractAddress);
		transactionID = 0;
	}

	// Token fallback required for ERC20Standard standard
	function tokenFallback(address _from, uint256 _value, bytes _data) public {
		address _tokenAddress = settings.getSettingAddress('TokenContract');
		require(msg.sender == _tokenAddress);
	}

	// Transfer function of the escrow wallet
	function transfer(address _to, uint256 _amount) public returns (bool){
		// To make sure the function is only called from the app contract or by the owner
		address _transactionContractAddress = settings.getSettingAddress('TransactionContract');
		require((msg.sender == _transactionContractAddress) || (msg.sender == contractOwner));
		address _tokenAddress = settings.getSettingAddress('TokenContract');
		ERC20Standard _tokenContract = ERC20Standard(_tokenAddress);
		require(_tokenContract.transfer(_to, _amount));
		return true;
	}

	// Returns the escrow wallet balance
	function balance() public view returns (uint256) {
		address _tokenAddress = settings.getSettingAddress('TokenContract');
		ERC20Standard _tokenContract = ERC20Standard(_tokenAddress);
		return _tokenContract.balanceOf(this);
	}

	// Destroying the wallet and returns the contents to the owner
	function destroyWallet(address _owner) public ownerOnly {
		address _tokenAddress = settings.getSettingAddress('TokenContract');
		ERC20Standard _tokenContract = ERC20Standard(_tokenAddress);
		require(_tokenContract.balanceOf(this) <= 0);

		selfdestruct(_owner);
	}
}
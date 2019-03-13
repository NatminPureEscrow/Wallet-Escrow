pragma solidity ^0.4.22;

import "./GeneralContract.sol";

contract EscrowWallet is Ownable {
	using SafeMath for uint256;
	
	GeneralContract settings;

	constructor (address _generalContractAddress) public {		
		require(_generalContractAddress != address(0));

		settings = GeneralContract(_generalContractAddress);
	}

	// Token fallback required for ERC223 standard
	function tokenFallback(address _from, uint256 _value, bytes _data) public {
		_from;
		_value;
		_data;
	}

	// Transfer function of the escrow wallet
	function transfer(
		string _ticker, 
		address _to, 
		uint256 _amount) public ownerOnly returns (bool) {	

		address _tokenAddress = settings.getSettingAddress(_ticker);
		ERC20Standard _tokenContract = ERC20Standard(_tokenAddress);
		require(_tokenContract.transfer(_to, _amount));

		return true;
	}

	function setGeneralContract(address _newGeneralContractAddress) public ownerOnly {
		settings = GeneralContract(_newGeneralContractAddress);
	}

	// Returns the escrow wallet balance
	function balance(string _ticker) public view returns (uint256) {
		address _tokenAddress = settings.getSettingAddress(_ticker);
		ERC20Standard _tokenContract = ERC20Standard(_tokenAddress);
		return _tokenContract.balanceOf(this);
	}
}
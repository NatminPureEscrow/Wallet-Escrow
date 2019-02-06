pragma solidity ^0.4.22;

import "./Ownable.sol";

//ERC20 Standard interface specification
contract ERC20Standard {
    function balanceOf(address _user) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


// This contact sets the list of general settings used by all contracts 
contract GeneralContract is Ownable {
	using SafeMath for uint256;

	struct SettingDetail {
		address settingAddress;
		string settingDescription;		
	}

	mapping(string => SettingDetail) internal settings;

    constructor () public {
		contractOwner = msg.sender;
	} 
	
	// Update a specific setting
	function setSetting(string _name, address _address, string _description) public ownerOnly {
		settings[_name].settingAddress = _address;
		settings[_name].settingDescription = _description;
	}

	// Returns the specific setting's address
	function getSettingAddress(string _name) public view returns (address) {
		return settings[_name].settingAddress;
	}

	// Returns the specific setting's description 
	function getSettingDescription(string _name) public view returns (string) {
		return settings[_name].settingDescription;
	}
}
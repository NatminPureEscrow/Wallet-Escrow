pragma solidity ^0.4.22;

import "./Ownable.sol";

contract ERC223 {

	// ERC20 standard function
    function transfer(address _to, uint256 _value) public returns (bool success);
    
    // ERC223 Standard functions
}

contract NatminApp is Ownable {

	// Natmin transaction interface	
	function updateTransactionBuyerPaid(uint256 _transID) public ;
	function getTransactionAmount(uint256 _transID) public view returns (uint256);
    function getTransactionBuyerPaid(uint256 _transID) public view  returns (bool);
    function getTransactionSeller(uint256 _transID) public view returns (address);
    function getSellerAmount(uint256 _transID) public view returns (uint256);
    function getTransactionBuyer(uint256 _transID) public view returns (address);
}

contract EscrowWallet is Ownable {
	using SafeMath for uint256;
	
	string 	private walletPassword;
	uint256 private	transactionID;

	address public  tokenContractAddress; // Wallet currency/token address
	address public  appContractAddress;
	address public	systemWalletAddress;
	uint256 public  balance;

	NatminApp public  appContract;
	ERC223 	public tokenContract;

	constructor (
		string _walletPassword,
		address _appContractAddress,
		address _tokenContractAddress,
		address _systemWalletAddress) public {		

		require(bytes(_walletPassword).length > 0);
		require(_appContractAddress != address(0));
		require(_tokenContractAddress != address(0));
		require(_systemWalletAddress != address(0));

		walletPassword = _walletPassword;
		appContractAddress = _appContractAddress;
		tokenContractAddress = _tokenContractAddress; 
		systemWalletAddress = _systemWalletAddress;
		appContract  = NatminApp(_appContractAddress);
		tokenContract = ERC223(_tokenContractAddress);
		balance = 0;
		transactionID = 0;
	}

	// Token fallback required for ERC223 standard
	function tokenFallback(address _from, uint256 _value, bytes _data) public {
		require(tokenContractAddress == msg.sender); // Only allows tokens from the agreed wallet currency
		balance = balance.add(_value);
		uint256 _transacionAmount = appContract.getTransactionAmount(transactionID);
		bool _buyerPaid = appContract.getTransactionBuyerPaid(transactionID);
		
		// Check if transaction is already marked as paid and  
		// Will stop receiving tokens once transaction is paid
		require(_buyerPaid != true); 
		if(balance >= _transacionAmount) {
			appContract.updateTransactionBuyerPaid(transactionID); // Mark transaction as paid
		}
	}

	function updateTransactionID(uint256 _transID) public returns (bool) {
		require(appContractAddress == msg.sender); // Can only be called from the app contract
		require(transactionID == 0); // Requires the transaction ID to be 0, can only be updated once
		require(_transID != 0);
		transactionID = _transID;
		return true;
	}

	// Checks the status of the transaction and pays the seller the required tokens
	function transferTransactionAmounts(string _password) public returns (bool) {
		// To make sure the function is only called from the app contract
		require(appContractAddress == msg.sender);
		require(keccak256(walletPassword) == keccak256(_password));		
		 
		uint256 _tokenAmount = appContract.getTransactionAmount(transactionID);
		uint256 _sellerAmount = appContract.getSellerAmount(transactionID);
		address _sellerAddress = appContract.getTransactionSeller(transactionID);
		uint256 _feeAmount = _tokenAmount.sub(_sellerAmount);
		tokenContract.transfer(_sellerAddress,_sellerAmount);
		tokenContract.transfer(systemWalletAddress,_feeAmount);

		return true;
	}

	function getTransactionID() public view returns (uint256) {
		return transactionID;
	}

	// Destroying the wallet and returns the contents to the owner
	function destroyWallet(address _owner) public ownerOnly {
		selfdestruct(_owner);
	}
}
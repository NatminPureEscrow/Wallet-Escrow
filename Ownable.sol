pragma solidity ^0.4.22;

//Math operations with safety checks that throw on error

library SafeMath {

    //multiply
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    //divide
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    //subtract
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    //addition
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public contractOwner;

    event TransferredOwnership(address indexed _previousOwner, address indexed _newOwner);

    constructor() public {        
        contractOwner = msg.sender;
    }

    modifier ownerOnly() {
        require(msg.sender == contractOwner);
        _;
    }

    function transferOwnership(address _newOwner) internal ownerOnly {
        require(_newOwner != address(0));
        contractOwner = _newOwner;

        emit TransferredOwnership(contractOwner, _newOwner);
    }

}
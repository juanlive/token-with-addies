pragma solidity ^0.4.19;

/*********************************************************************************
 *********************************************************************************
 *
 * Name of the project: Token with Addies
 * Author: Juan Livingston 
 *
 *********************************************************************************
 ********************************************************************************/

 /* New ERC20 contract interface */

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// The Token

contract TokenWithAddies {

    // Token public variables
    string public name;
    string public symbol;
    uint8 public decimals; 
    string public version = 'v1';
    uint256 public totalSupply;
    uint public price;
    bool locked;

    address rootAddress;
    address Owner;
    uint multiplier; // For 0 decimals

    mapping(string => uint256) balances;
    mapping(string => mapping(address => uint256)) allowed;
    mapping(string => address) addies;
    mapping(address => bool) received;


    event Transfer(string indexed from, string indexed to, uint256 value);
    event Approval(string indexed owner, address indexed spender, uint256 value);
    event AssignedAddy(string indexed addy, address indexed assignee);

    // Modifiers

    modifier onlyOwner() {
        if ( msg.sender != rootAddress && msg.sender != Owner ) revert();
        _;
    }

    modifier onlyRoot() {
        if ( msg.sender != rootAddress ) revert();
        _;
    }

    modifier isUnlocked() {
    //	if ( locked && msg.sender != rootAddress && msg.sender != Owner ) revert();
		_;    	
    }

    modifier isUnfreezed(address _to) {
    //	if ( freezed[msg.sender] || freezed[_to] ) revert();
    	_;
    }


    // Safe math
    function safeAdd(uint x, uint y) internal returns (uint z) {
        require((z = x + y) >= x);
    }
    function safeSub(uint x, uint y) internal returns (uint z) {
        require((z = x - y) <= x);
    }


    // Token constructor
    function TokenWithAddies() {        
        locked = false;
        name = 'Token With Addies'; 
        symbol = 'TWA'; 
        decimals = 18; 
        multiplier = 10 ** uint(decimals);
        totalSupply = 10000000 * multiplier; // 10,000,000 tokens
        rootAddress = msg.sender;        
        Owner = msg.sender;
        addies["a"] = msg.sender;
        balances["a"] = totalSupply; 
    }


    // Only root function

    function changeRoot(address _newrootAddress) onlyRoot returns(bool){
        rootAddress = _newrootAddress;
        return true;
    }

    // Only owner functions

    // To send ERC20 tokens sent accidentally
    function sendToken(address _token,address _to , uint _value) onlyOwner returns(bool) {
        ERC20Basic Token = ERC20Basic(_token);
        return(Token.transfer(_to, _value));
    }

    function changeOwner(address _newOwner) onlyOwner returns(bool) {
        Owner = _newOwner;
        return true;
    }
       
    function unlock() onlyOwner returns(bool) {
        locked = false;
        return true;
    }

    function lock() onlyOwner returns(bool) {
        locked = true;
        return true;
    }


    function assignAddy(string _addy) public {
        require (addies[_addy] == 0);
        addies[_addy] = msg.sender;
        // Pay 100 tokens to the address for unique time
        if (received[msg.sender]==false) {
                if (internalTransfer("a",_addy,100*multiplier)) received[msg.sender] = true;
             }
        //
        AssignedAddy(_addy, msg.sender);
    }

    // Public getters

    function isLocked() constant returns(bool) {
        return locked;
    }

    function checkAddy(string _addy) constant returns(address){
        return addies[_addy];
    }

    // Standard function transfer
    function transfer(string _from, string _to, uint _value) isUnlocked returns (bool success) {
        require(addies[_from] == msg.sender);
        return internalTransfer(_from,_to,_value);
    }


    function secureTransfer(string _from,string _to,address _addTo,uint _value) isUnlocked returns(bool success) {
        require(addies[_from]==msg.sender);
        require(addies[_to]==_addTo || addies[_to]==0);
        if(addies[_to]==0) {
            addies[_to]=_addTo;
            AssignedAddy(_to, _addTo);
            }
        return internalTransfer(_from,_to,_value);
    }

    function transferFrom(string _from, string _to, uint256 _value) public returns(bool) {
    	if ( _value > allowed[_from][msg.sender] ) return false; // Check allowance
        allowed[_from][msg.sender] -= _value;
        return internalTransfer(_from,_to,_value);
    }


    function balanceOf(string _owner) constant returns(uint256 balance) {
        return balances[_owner];
    }


    function approve(string _addy , address _spender, uint _value) returns(bool) {
        require(addies[_addy] == msg.sender);
        allowed[_addy][_spender] = _value;
        Approval(_addy, _spender, _value);
        return true;
    }


    function allowance(string _owner, address _spender) constant returns(uint256) {
        return allowed[_owner][_spender];
    }

    // internal

    function internalTransfer(string _from, string _to, uint _value) private returns (bool success) {
        if (balances[_from] < _value) return false;
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(_from,_to,_value);
        return true;
    }
}

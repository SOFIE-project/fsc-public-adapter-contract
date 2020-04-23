pragma solidity ^0.5.0;

import "./InterledgerReceiverInterface.sol";

contract AbstractSofieFSC {
     function registerSessionSignatures(string memory boxId, string memory sessionId, bytes32[8] memory signatures) public;
}

contract SofieFSCAdapter is InterledgerReceiverInterface {
    address payable owner;
    address sofieContract;
    mapping(address => uint) users;

    event LogContractSet(address base, uint timestamp);
    event LogUserRegistered(address user, uint timestamp);
    event LogUserRemoved(address user, uint timestamp);
    
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }
    
    function kill() external onlyOwner {
        selfdestruct(owner);
    }

    /**
     * @dev Function that upserts the address of the Sofie FSC public smart contract.
     * @param base The smart contract address
     */
    function setContractBase(address base) public onlyOwner {
        sofieContract = base;
        emit LogContractSet(base, now);
    }

    function registerUser(address user) public onlyOwner {
        users[user] = now;
        emit LogUserRegistered(user, now);
    }
    
    function removeUser(address user) public onlyOwner {
        delete users[user];
        emit LogUserRemoved(user, now);
    }
    
    function interledgerReceive(uint256 nonce, bytes memory data) public {
        require(
            msg.sender == owner || users[msg.sender] > 0,
            "Only contract owner or registered users can call this function"
        );

        if( sofieContract == address(0)) {
            // Contract address not set, decline interledger transaction
            emit InterledgerEventRejected(nonce);
        } else {
            // Decode the interledger payload data
            (string memory boxId, string memory sessionId, bytes32[8] memory signatures) = 
                abi.decode(data, (string, string, bytes32[8]));
            
            // Call the Sofie FSC contract
            AbstractSofieFSC sc = AbstractSofieFSC(sofieContract);
            sc.registerSessionSignatures(boxId, sessionId, signatures);
            
            // Accept interledger transaction
            emit InterledgerEventAccepted(nonce);
        }
    }
    
    
}
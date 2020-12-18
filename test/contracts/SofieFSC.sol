pragma solidity ^0.5.0;

contract SofieFSC {
    address payable owner;
    mapping(address => uint) users;
    mapping(string => mapping(string => bytes32[8])) boxSessionSignatures;

    event LogBoxSessionSignatures(string boxId, string sessionId, bytes32 hash, uint timestamp);
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

    modifier onlyUsers() {
        require(
            users[msg.sender] > 0,
            "Only registered users can call this function"
        );
        _;
    }

    modifier onlyOwnerOrUsers() {
        require(
            msg.sender == owner || users[msg.sender] > 0,
            "Only contract owner or registered users can call this function"
        );
        _;
    }

    function kill() external onlyOwner {
        selfdestruct(owner);
    }

    function registerUser(address user) public onlyOwner {
        users[user] = now;
        emit LogUserRegistered(user, now);
    }

    function removeUser(address user) public onlyOwner {
        delete users[user];
        emit LogUserRemoved(user, now);
    }

    function registerSessionSignatures(string memory boxId, string memory sessionId, bytes32[8] memory signatures) public onlyOwnerOrUsers {
        bytes32 hash = keccak256(
                abi.encodePacked(boxId, sessionId, signatures)
            );

        boxSessionSignatures[boxId][sessionId] = signatures;
        emit LogBoxSessionSignatures(boxId, sessionId, hash, now);
    }

    function getSessionSignatures(string memory boxId, string memory sessionId) public view returns(bytes32[8] memory, bytes32) {
        bytes32[8] storage signatures = boxSessionSignatures[boxId][sessionId];
        bytes32 hash = keccak256(
                abi.encodePacked(boxId, sessionId, signatures)
            );
        return (signatures, hash);
    }
}

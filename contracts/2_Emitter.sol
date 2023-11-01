// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventEmitter {

    address public owner;

    // Events
    event OracleRequest(address indexed user, bytes32 indexed requestId, string dataType, uint256 amount);
    event CustomEvent(address indexed user, bytes32 indexed eventId, string eventData);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to emit an event for an oracle request
    function emitOracleRequest(bytes32 requestId, string memory dataType, uint256 amount) external {
        emit OracleRequest(msg.sender, requestId, dataType, amount);
    }

    // Function to emit custom events (for future expansion or other use cases)
    function emitCustomEvent(bytes32 eventId, string memory eventData) external onlyOwner {
        emit CustomEvent(msg.sender, eventId, eventData);
    }
}

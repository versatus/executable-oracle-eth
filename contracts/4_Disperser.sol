// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEscrow {
    function releaseFunds(address user, address tokenAddress, uint256 amount) external;
    function refundFunds(address user, address tokenAddress, uint256 amount) external;
}

contract Disperser {

    IEscrow private escrowInstance;
    address private ingestor;

    modifier onlyIngestor() {
        require(msg.sender == ingestor, "Only Ingestor can call this");
        _;
    }

    constructor(address _escrowAddress) {
        escrowInstance = IEscrow(_escrowAddress);
        ingestor = msg.sender;  // Assumes the Ingestor deploys the Disperser
    }

    function release(address user, address tokenAddress, uint256 amount) external onlyIngestor {
        escrowInstance.releaseFunds(user, tokenAddress, amount);
    }

    function refund(address user, address tokenAddress, uint256 amount) external onlyIngestor {
        escrowInstance.refundFunds(user, tokenAddress, amount);
    }

    function updateIngestor(address newIngestor) external onlyIngestor {
        ingestor = newIngestor;
    }
}

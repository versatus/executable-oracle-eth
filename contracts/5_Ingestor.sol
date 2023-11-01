// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IDisperser {
    function refund(address user, address tokenAddress, uint256 amount) external;
    function release(address user, address tokenAddress, uint256 amount) external;
}

contract Ingestor {

    address public owner;
    IDisperser private disperserInstance;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _disperserAddress) {
        owner = msg.sender;
        disperserInstance = IDisperser(_disperserAddress);
    }
    
    function processData(address user, address tokenAddress, uint256 amount, bool isRefund) external onlyOwner {
        if(isRefund) {
            disperserInstance.refund(user, tokenAddress, amount);
        } else {
            disperserInstance.release(user, tokenAddress, amount);
        }
    }
}

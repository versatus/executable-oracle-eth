// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenAgnosticEscrow {

    address public owner;

    // Mapping of user => token address => amount
    mapping(address => mapping(address => uint256)) public deposits;

    event Deposited(address indexed user, address indexed tokenAddress, uint256 amount);
    event Released(address indexed user, address indexed tokenAddress, uint256 amount);
    event Refunded(address indexed user, address indexed tokenAddress, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // To deposit ETH
    function depositETH() external payable {
        deposits[msg.sender][address(0)] += msg.value;  // address(0) represents ETH
        emit Deposited(msg.sender, address(0), msg.value);
    }

    // To deposit ERC-20 tokens
    function depositToken(address tokenAddress, uint256 amount) external {
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        deposits[msg.sender][tokenAddress] += amount;
        emit Deposited(msg.sender, tokenAddress, amount);
    }

    // Placeholder functions for releasing and refunding funds, to be expanded upon
    function releaseFunds(address user, address tokenAddress, uint256 amount) external onlyOwner {
        require(deposits[user][tokenAddress] >= amount, "Insufficient funds");
        deposits[user][tokenAddress] -= amount;

        if(tokenAddress == address(0)) { // If ETH
            payable(user).transfer(amount);
        } else { // If ERC-20
            require(IERC20(tokenAddress).transfer(user, amount), "Transfer failed");
        }
        emit Released(user, tokenAddress, amount);
    }

    function refundFunds(address user, address tokenAddress, uint256 amount) external onlyOwner {
        require(deposits[user][tokenAddress] >= amount, "Insufficient funds");
        deposits[user][tokenAddress] -= amount;

        if(tokenAddress == address(0)) { // If ETH
            payable(user).transfer(amount);
        } else { // If ERC-20
            require(IERC20(tokenAddress).transfer(user, amount), "Transfer failed");
        }
        emit Refunded(user, tokenAddress, amount);
    }
}


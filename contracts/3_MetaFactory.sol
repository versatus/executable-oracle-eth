// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Factory {
    function createERC20(string memory name, string memory symbol, uint256 initialSupply) external returns (address);
}

interface IERC721Factory {
    function createERC721(string memory name, string memory symbol) external returns (address);
}

// TODO: Add interfaces for other types of factories
contract MetaFactory {

    address public owner;
    mapping(string => address) public factories;  // Mapping of type to factory address

    event FactoryDeployed(bytes32 indexed factoryType, address indexed factoryAddress);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deployERC20Factory(address _erc20FactoryAddress) external onlyOwner {
        factories["ERC20"] = _erc20FactoryAddress;
        emit FactoryDeployed("ERC20", _erc20FactoryAddress);
    }

    function deployERC721Factory(address _erc721FactoryAddress) external onlyOwner {
        factories["ERC721"] = _erc721FactoryAddress;
        emit FactoryDeployed("ERC721", _erc721FactoryAddress);
    }

    // TODO: Add functions for deploying other factory types

    function createToken(string memory factoryType, string memory name, string memory symbol, uint256 initialSupply) external returns (address) {
        require(factories[factoryType] != address(0), "Factory type not available");

        if (keccak256(bytes(factoryType)) == keccak256(bytes("ERC20"))) {
            return IERC20Factory(factories[factoryType]).createERC20(name, symbol, initialSupply);
        } else if (keccak256(bytes(factoryType)) == keccak256(bytes("ERC721"))) {
            return IERC721Factory(factories[factoryType]).createERC721(name, symbol);
        }

        // TODO: Handle other types...

        revert("Invalid type");
    }
}


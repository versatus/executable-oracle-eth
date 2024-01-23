pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { ExecutableOracle } from "../src/1_ExecutableOracle.sol";
import { console2 } from "forge-std/src/console2.sol";

contract ExecutableOracleOwnerTest is PRBTest {
  ExecutableOracle internal executableOracle;

  function setUp() public {
    executableOracle = new ExecutableOracle();
  }

  function testOnlyOwnerCanWithdrawETH() external {
    // Arrange
    address nonOwner = address(0x123);
    uint256 withdrawAmount = 1 ether;
    vm.deal(address(executableOracle), withdrawAmount);
    vm.startPrank(nonOwner);

    // Act & Assert
    vm.expectRevert("Not the owner");
    executableOracle.withdrawETH(payable(nonOwner), withdrawAmount);

    vm.stopPrank();
  }

  function testOnlyOwnerCanReleaseERC20() external {
    // Arrange
    address nonOwner = address(0x123);
    address tokenAddress = address(0x456);
    address to = address(this);
    uint256 amount = 1000;
    vm.startPrank(nonOwner);

    // Act & Assert
    vm.expectRevert("Not the owner");
    executableOracle.releaseERC20(tokenAddress, to, amount);

    vm.stopPrank();
  }

  function testOnlyOwnerCanReleaseERC721() external {
    // Arrange
    address nonOwner = address(0x123);
    address tokenAddress = address(0x456);
    address to = address(this);
    uint256 tokenId = 1;
    vm.startPrank(nonOwner);

    // Act & Assert
    vm.expectRevert("Not the owner");
    executableOracle.releaseERC721(tokenAddress, to, tokenId);

    vm.stopPrank();
  }

  function testOnlyOwnerCanSettleBlobIndex() external {
    // Arrange
    address nonOwner = address(0x123);
    address[] memory accounts = new address[](1);
    accounts[0] = address(this);
    ExecutableOracle.BlobIndex memory blobIndex = ExecutableOracle.BlobIndex({
      batchHeaderHash: bytes32(0),
      blobIndex: uint128(0)
    });
    vm.startPrank(nonOwner);

    // Act & Assert
    vm.expectRevert("Not the owner");
    executableOracle.settleBlobIndex(accounts, blobIndex);

    vm.stopPrank();
  }
}

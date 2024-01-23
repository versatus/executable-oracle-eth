pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { ExecutableOracle } from "../src/1_ExecutableOracle.sol";
import { console2 } from "forge-std/src/console2.sol";

contract ExecutableOracleBridgeTest is PRBTest {
    ExecutableOracle internal executableOracle;

    function setUp() public {
        executableOracle = new ExecutableOracle();
    }

    function testReceive() external {
        // Arrange
        uint256 sendAmount = 1 ether;
        vm.deal(address(executableOracle), sendAmount);

        // Act
        payable(address(executableOracle)).send(sendAmount);

        // Assert
        uint256 balance = address(executableOracle).balance;
        console2.log("Received Balance: ", balance);
        assertEq(balance, sendAmount, "Balance should match the sent amount");
    }
}

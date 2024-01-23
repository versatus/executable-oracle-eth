pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { ExecutableOracle } from "../src/1_ExecutableOracle.sol";
import { IERC20 } from "../src/1_ExecutableOracle.sol";

/**
 * @dev This is a test contract for the ExecutableOracle contract.
 */
// Functions to test
// getERC20Balance
// storeERC20
// releaseERC20
contract ExecutableOracleTest is PRBTest, StdCheats {
    ExecutableOracle internal executableOracle;
    IERC20 internal erc20Token;

    function setUp() public virtual {
        executableOracle = new ExecutableOracle();
    }

    function testStoreAndGetERC20Balance() external {
        console2.log("Hello World");
    }
}

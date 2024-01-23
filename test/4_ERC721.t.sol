pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { ExecutableOracle } from "../src/1_ExecutableOracle.sol";
import { IERC721 } from "../src/1_ExecutableOracle.sol";

contract ExecutableOracleTest is PRBTest, StdCheats {
    ExecutableOracle internal executableOracle;
    IERC721 internal erc721Token;

    function setUp() public virtual {
        executableOracle = new ExecutableOracle();
        // MockERC721 mockERC721Token = new MockERC721("MockToken", "MTK", 18);
        // erc721Token = IERC721(address(mockERC721Token));
    }

    function testStoreAndGetERC721Holdings() external {
        console2.log("Hello World");
    }
}

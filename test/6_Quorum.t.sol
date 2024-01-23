pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
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

    // function testQuorumVoting() external {
    //     // Arrange
    //     address[] memory members = new address[](3);
    //     members[0] = address(0x1);
    //     members[1] = address(0x2);
    //     members[2] = address(0x3);
    //     bytes32 testBlobIndexBatchHeaderHash = keccak256("testBlobIndexBatchHeaderHash");
    //     uint128 testBlobIndex = 1;
    //     ExecutableOracle.BlobIndex memory blobIndex =
    //         ExecutableOracle.BlobIndex({ batchHeaderHash: testBlobIndexBatchHeaderHash, blobIndex: testBlobIndex });

    //     // Act
    //     for (uint256 i = 0; i < members.length; i++) {
    //         executableOracle.voteOnBlobIndex(members[i], true, blobIndex);
    //     }
    //     executableOracle.settleBlobIndex(members, blobIndex);

    //     // Assert
    //     for (uint256 i = 0; i < members.length; i++) {
    //         (bytes32 batchHeaderHash, uint128 blobIndexResult) = executableOracle.getBlobIndex(members[i]);
    //         assertEq(batchHeaderHash, testBlobIndexBatchHeaderHash, "Batch header hash should match the settled
    // value");
    //         assertEq(blobIndexResult, testBlobIndex, "Blob index should match the settled value");
    //     }
    // }
}

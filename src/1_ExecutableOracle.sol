// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
}

contract ExecutableOracle {
    address public owner;
    uint256 private bridgeCounter;
    uint256 private settlementCounter;

    struct Quorum {
        mapping(address => bool) quorumMembers;
        // mapping(string => mapping(address member => bool vote)) votes;
        mapping(string => mapping(address => bool)) votes;
        mapping(string => mapping(bool => uint256)) voteCount;
        bool isActive;
        uint256 memberCount;
    }

    struct BlobIndex {
        bytes32 batchHeaderHash;
        uint128 blobIndex;
    }

    mapping(address => BlobIndex) internal pendingBlobIndices;
    mapping(address => BlobIndex) public blobIndices;
    mapping(address => Quorum) public quorums;
    mapping(address => uint256) public ethBalance;
    // mapping(address user => mapping(address tokenAddress => uint256 balance)) ERC20Balance;
    mapping(address => mapping(address => uint256)) ERC20Balance;
    // mapping(address user => mapping(address tokenAddress => uint256[])) ERC721Holdings;
    mapping(address => mapping(address => uint256[])) ERC721Holdings;

    event BlobIndexSettled(address[] indexed accounts, bytes32 batchHeaderHash, uint128 blobIndex, uint256 blobEventId);
    //  TODO(asmith) add a VerifiedBridgelsIn event
    //  TODO(asmith) add a
    event Bridge(
        address indexed user,
        address indexed tokenAddress,
        uint256 amount,
        uint256 tokenId,
        string tokenType,
        uint256 bridgeEventId
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    //    function storeETH(bytes32 seed, bytes32 r, bytes32 s, uint v) external payable {
    //        ethBalance[msg.sender] += msg.value;
    //        emit BridgeVerified(msg.sender, address(0), msg.value, 0, "ETH", seed, r, s, v);
    //    }

    receive() external payable {
        ethBalance[msg.sender] += msg.value;
        bridgeCounter += 1;
        emit Bridge(msg.sender, address(0), msg.value, 0, "ETH", bridgeCounter);
    }

    function getEthBalance(address user) external view returns (uint256) {
        return ethBalance[user];
    }

    function getERC20Balance(address tokenAddress, address user) external view returns (uint256) {
        return ERC20Balance[tokenAddress][user];
    }

    function getERC721Holdings(address tokenAddress, address user) external view returns (uint256[] memory) {
        return ERC721Holdings[user][tokenAddress];
    }

    function storeERC20(address tokenAddress, uint256 amount) public {
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        ERC20Balance[msg.sender][tokenAddress] += amount;
        bridgeCounter += 1;
        emit Bridge(msg.sender, tokenAddress, amount, 0, "ERC-20", bridgeCounter);
    }

    function storeERC721(address tokenAddress, uint256 tokenId) public {
        IERC721(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId);
        require(!ERC721AlreadyStored(tokenAddress, msg.sender, tokenId), "NFT already stored");
        ERC721Holdings[msg.sender][tokenAddress].push(tokenId);
        bridgeCounter += 1;
        emit Bridge(msg.sender, tokenAddress, 0, tokenId, "ERC-721", bridgeCounter);
    }

    function ERC721AlreadyStored(address tokenAddress, address user, uint256 tokenId) public view returns (bool) {
        uint256[] memory nfts = ERC721Holdings[user][tokenAddress];
        for (uint256 i = 0; i < nfts.length; i++) {
            if (tokenId == nfts[i]) {
                return true;
            }
        }
        return false;
    }

    function releaseERC20(address tokenAddress, address to, uint256 amount) public onlyOwner {
        require(ERC20Balance[to][tokenAddress] >= amount, "Insufficient balance");
        require(IERC20(tokenAddress).transfer(to, amount), "Transfer failed");
        ERC20Balance[to][tokenAddress] -= amount;
    }

    function releaseERC721(address tokenAddress, address to, uint256 tokenId) public onlyOwner {
        require(ERC721AlreadyStored(tokenAddress, to, tokenId), "NFT not stored");
        IERC721(tokenAddress).safeTransferFrom(address(this), to, tokenId);
        uint256 NFTIndex = getNFTIndex(tokenAddress, to, tokenId);
        ERC721Holdings[to][tokenAddress][NFTIndex] =
            ERC721Holdings[to][tokenAddress][ERC721Holdings[to][tokenAddress].length - 1];
        ERC721Holdings[to][tokenAddress].pop();
    }

    function getNFTIndex(address tokenAddress, address user, uint256 tokenId) internal view returns (uint256) {
        require(ERC721AlreadyStored(tokenAddress, user, tokenId), "NFT not stored");
        uint256[] memory nfts = ERC721Holdings[user][tokenAddress];
        for (uint256 i = 0; i < nfts.length; i++) {
            if (tokenId == nfts[i]) {
                return i;
            }
        }
        return 0;
    }

    function withdrawETH(address payable to, uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        require(amount <= ethBalance[to], "Insufficient balance");
        to.transfer(amount);
    }

    function voteOnBlobIndex(address user, bool vote, BlobIndex calldata blobIndex) external {
        //TODO: Implement QuorumVoting
    }

    function settleBlobIndex(address[] calldata accounts, BlobIndex calldata blobIndex) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blobIndices[accounts[i]] = blobIndex;
        }
        settlementCounter += 1;
        emit BlobIndexSettled(accounts, blobIndex.batchHeaderHash, blobIndex.blobIndex, settlementCounter);
    }

    function getBlobIndex(address user) external view returns (bytes32 batchHeaderHash, uint128 blobIndex) {
        return (blobIndices[user].batchHeaderHash, blobIndices[user].blobIndex);
    }
}

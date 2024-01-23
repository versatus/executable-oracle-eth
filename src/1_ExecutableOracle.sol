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
        mapping(string => mapping(address member => bool vote)) votes;
        mapping(string => mapping(bool vote => uint256 count)) voteCount;
        bool isActive;
        uint256 memberCount;
    }

    struct BlobIndex {
        bytes32 batchHeaderHash;
        uint128 blobIndex;
    }

    mapping(address account => BlobIndex index) internal pendingBlobIndices;
    mapping(address account => BlobIndex index) public blobIndices;
    mapping(address account => Quorum quorum) public quorums;
    mapping(address account => uint256 balance) public ethBalance;
    mapping(address account => mapping(address tokenAddress => uint256 balance)) public erc20Balance;
    mapping(address account => mapping(address tokenAddress => uint256[] holdings)) public erc721Holdings;

    event BlobIndexSettled(address[] indexed accounts, bytes32 batchHeaderHash, uint128 blobIndex, uint256 blobEventId);

    event Bridge(
        address indexed user,
        address indexed tokenAddress,
        uint256 amount,
        uint256 tokenId,
        string tokenType,
        uint256 bridgeEventId
    );

    event BridgeVerified(
        address indexed user,
        address indexed tokenAddress,
        uint256 amount,
        uint256 tokenId,
        string tokenType,
        bytes32 seed,
        bytes32 r,
        bytes32 s,
        uint256 v
    );

    error NotOwner();
    error TransferFailed();
    error InsufficientBalance();
    error NFTAlreadyStored();
    error NFTNotStored();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    receive() external payable {
        ethBalance[msg.sender] += msg.value;
        bridgeCounter += 1;
        emit Bridge(msg.sender, address(0), msg.value, 0, "ETH", bridgeCounter);
    }

    function storeETH(bytes32 seed, bytes32 r, bytes32 s, uint256 v) external payable {
        ethBalance[msg.sender] += msg.value;
        emit BridgeVerified(msg.sender, address(0), msg.value, 0, "ETH", seed, r, s, v);
    }

    function getEthBalance(address user) external view returns (uint256) {
        return ethBalance[user];
    }

    function getERC20Balance(address tokenAddress, address user) external view returns (uint256) {
        return erc20Balance[tokenAddress][user];
    }

    function getERC721Holdings(address tokenAddress, address user) external view returns (uint256[] memory) {
        return erc721Holdings[user][tokenAddress];
    }

    function storeERC20(address tokenAddress, uint256 amount) public {
        if (!IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
        erc20Balance[msg.sender][tokenAddress] += amount;
        bridgeCounter += 1;
        emit Bridge(msg.sender, tokenAddress, amount, 0, "ERC-20", bridgeCounter);
    }

    function storeERC721(address tokenAddress, uint256 tokenId) public {
        IERC721(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId);
        if (ERC721AlreadyStored(tokenAddress, msg.sender, tokenId)) revert NFTAlreadyStored();
        erc721Holdings[msg.sender][tokenAddress].push(tokenId);
        bridgeCounter += 1;
        emit Bridge(msg.sender, tokenAddress, 0, tokenId, "ERC-721", bridgeCounter);
    }

    function ERC721AlreadyStored(address tokenAddress, address user, uint256 tokenId) public view returns (bool) {
        uint256[] memory nfts = erc721Holdings[user][tokenAddress];
        for (uint256 i = 0; i < nfts.length; i++) {
            if (tokenId == nfts[i]) {
                return true;
            }
        }
        return false;
    }

    function releaseERC20(address tokenAddress, address to, uint256 amount) public onlyOwner {
        if (erc20Balance[to][tokenAddress] < amount) revert InsufficientBalance();
        erc20Balance[to][tokenAddress] -= amount;
        if (!IERC20(tokenAddress).transfer(to, amount)) revert TransferFailed();
    }

    function releaseERC721(address tokenAddress, address to, uint256 tokenId) public onlyOwner {
        if (!ERC721AlreadyStored(tokenAddress, to, tokenId)) revert NFTNotStored();
        IERC721(tokenAddress).safeTransferFrom(address(this), to, tokenId);
        uint256 nftIndex = getNftIndex(tokenAddress, to, tokenId);
        erc721Holdings[to][tokenAddress][nftIndex] =
            erc721Holdings[to][tokenAddress][erc721Holdings[to][tokenAddress].length - 1];
        erc721Holdings[to][tokenAddress].pop();
    }

    function getNftIndex(address tokenAddress, address user, uint256 tokenId) internal view returns (uint256) {
        if (!ERC721AlreadyStored(tokenAddress, user, tokenId)) revert NFTNotStored();
        uint256[] memory nfts = erc721Holdings[user][tokenAddress];
        for (uint256 i = 0; i < nfts.length; i++) {
            if (tokenId == nfts[i]) {
                return i;
            }
        }
        revert NFTNotStored();
    }

    function withdrawETH(address payable to, uint256 amount) public onlyOwner {
        if (amount > address(this).balance || amount > ethBalance[to]) revert InsufficientBalance();
        ethBalance[to] -= amount;
        to.transfer(amount);
    }

    function voteOnBlobIndex(address user, bool vote, BlobIndex calldata blobIndex) external {
        // TODO: Implement QuorumVoting
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

const TokenAgnosticEscrow = artifacts.require("TokenAgnosticEscrow");
const Disperser = artifacts.require("Disperser");
const Ingestor = artifacts.require("Ingestor");
const MetaFactory = artifacts.require("MetaFactory");
const ERC20Factory = artifacts.require("ERC20Factory");
const MockERC20 = artifacts.require("MockERC20");

contract("Executable Oracle System", accounts => {
    let escrow, disperser, ingestor, metaFactory, erc20Factory;
    const owner = accounts[0];
    const user = accounts[1];

    before(async () => {
        escrow = await TokenAgnosticEscrow.new();
        disperser = await Disperser.new(escrow.address);
        ingestor = await Ingestor.new(disperser.address);
        metaFactory = await MetaFactory.new();
        erc20Factory = await ERC20Factory.new();
    });

    it("should deposit ETH into the escrow", async () => {
        await escrow.depositETH({ from: user, value: web3.utils.toWei("1", "ether") });
        const balance = await web3.eth.getBalance(escrow.address);
        assert.equal(balance, web3.utils.toWei("1", "ether"));
    });

    // Add similar tests for ERC-20 deposits once you have an ERC-20 mock

    it("should emit an oracle request", async () => {
        // Assuming you have a function called `emitOracleRequest` in the Emitter contract
        const result = await ingestor.processData(user, "0x0", web3.utils.toWei("0.5", "ether"), false, { from: owner });
        assert.equal(result.logs[0].event, "OracleRequest");
        // Check other event attributes as needed
    });

    it("should release funds from escrow", async () => {
        const initialBalance = await web3.eth.getBalance(user);
        await ingestor.processData(user, "0x0", web3.utils.toWei("0.5", "ether"), false, { from: owner });
        const finalBalance = await web3.eth.getBalance(user);
        assert.isTrue(new web3.utils.BN(finalBalance).gt(new web3.utils.BN(initialBalance)));
    });

    it("should refund funds back to the depositor", async () => {
        const initialBalance = await web3.eth.getBalance(user);
        await ingestor.processData(user, "0x0", web3.utils.toWei("0.5", "ether"), true, { from: owner });
        const finalBalance = await web3.eth.getBalance(user);
        assert.isTrue(new web3.utils.BN(finalBalance).gt(new web3.utils.BN(initialBalance)));
    });

    it("should deploy ERC20Factory through MetaFactory", async () => {
        await metaFactory.deployERC20Factory(erc20Factory.address, { from: owner });
        const deployedAddress = await metaFactory.factories("ERC20");
        assert.equal(deployedAddress, erc20Factory.address);
    });

    it("should deploy a new ERC20 token using ERC20Factory", async () => {
        const result = await erc20Factory.createERC20("Test Token", "TST", web3.utils.toWei("1000", "ether"), { from: owner });
        const event = result.logs[0];
        const newTokenAddress = event.args.tokenAddress;
        const newToken = await MockERC20.at(newTokenAddress);

        const name = await newToken.name();
        const symbol = await newToken.symbol();
        const balance = await newToken.balanceOf(owner);

        assert.equal(name, "Test Token");
        assert.equal(symbol, "TST");
        assert.equal(balance.toString(), web3.utils.toWei("1000", "ether"));
    });

    it("should not allow non-owner to process data in Ingestor", async () => {
        try {
            await ingestor.processData(user, "0x0", web3.utils.toWei("0.5", "ether"), true, { from: user });
            assert.fail("Expected revert not received");
        } catch (error) {
            assert.isTrue(error.message.includes("Not the contract owner"), "Expected 'Not the contract owner' but got " + error.message);
        }
    });
});


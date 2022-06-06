const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  let contract;

  before(async () => {
    const DynamicNftFactory = await ethers.getContractFactory("DynamicNft");
    contract = await DynamicNftFactory.deploy();
    await contract.deployed();
  });

  it("Should mint the ticket", async function () {
    const tx = await contract.mintTiket("My secret", 1000);
    await tx.wait();

    const tx2 = await contract.mintTiket("My secret3", 10003);
    await tx2.wait();

    const tx3 = await contract.mintTiket("My secret3", 10003);
    await tx3.wait();

    const tikets = await contract.getAllTikets();

    console.log(tikets);

    expect(tikets.length).to.equal(1);
    // expect(await greeter.greet()).to.equal("Hello, world!");
    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
    // // wait until the transaction is mined
    // await setGreetingTx.wait();
    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });

  it("Should what?", async () => {
    let tikets = await contract.getAllTikets();
    const [owner, addr1] = await ethers.getSigners();

    expect(await contract.connect(owner).myBalance()).to.equal(1);
    expect(await contract.connect(addr1).myBalance()).to.equal(0);

    const tx = await contract.connect(addr1).buyTiket(0);
    await tx.wait();

    tikets = await contract.getAllTikets();
    console.log(tikets);

    expect(await contract.connect(owner).myBalance()).to.equal(0);
    expect(await contract.connect(addr1).myBalance()).to.equal(1);

    expect(tikets.length).to.equal(1);
  });
});

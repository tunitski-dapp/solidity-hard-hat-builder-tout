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
    const [owner, addr1] = await ethers.getSigners();
    const tx = await contract.mintTiket("My secret", 1000);
    await tx.wait();

    const tx2 = await contract.mintTiket("My secret2", 10002);
    await tx2.wait();

    const tx3 = await contract.mintTiket("My secret3", 10003);
    await tx3.wait();

    const tikets = await contract.getAllTikets();

    expect(tikets.length).to.equal(3);
  });

  async function getSome(owner) {
    const myBalance = await contract.connect(owner).myBalance();
    console.log(`Why? ${owner}`);
    for (let index = 0; index < myBalance; index++) {
      console.log(index);
      const tiket = await contract.connect(owner).getMyTiketByIndex(index);
      console.log(tiket);
    }
  }

  it("Should what?", async () => {
    let tikets = await contract.getAllTikets();
    const [owner, addr1] = await ethers.getSigners();

    await getSome(owner);
    await getSome(addr1);

    expect(await contract.connect(owner).myBalance()).to.equal(3);
    expect(await contract.connect(addr1).myBalance()).to.equal(0);

    const tx = await contract.connect(addr1).buyTiket(1);
    await tx.wait();

    tikets = await contract.getAllTikets();

    expect(await contract.connect(owner).myBalance()).to.equal(2);
    expect(await contract.connect(addr1).myBalance()).to.equal(1);

    await getSome(owner);
    await getSome(addr1);
  });
});

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Ticketing collection", function () {
  let contract;

  const eventName = "Cool event!";
  const ticketAmount = 100;
  const setsOnRow = 25;
  const startPrice = Math.pow(10, 15);

  before(async () => {
    const TicketsCollection = await ethers.getContractFactory(
      "TicketsCollection"
    );
    contract = await TicketsCollection.deploy(
      eventName,
      ticketAmount,
      setsOnRow,
      startPrice
    );
    await contract.deployed();
  });

  it("after deploy contract should create tickets", async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    let balance = await contract.balanceOf(owner.address);
    expect(balance).equal(ticketAmount);

    balance = await contract.balanceOf(addr1.address);
    expect(balance).equal(0);

    balance = await contract.balanceOf(addr2.address);
    expect(balance).equal(0);
  });

  it("should can buy some ticket", async () => {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const ticketIdForBuy = 99;

    const accountOwnerBalanceBefore = await owner.getBalance();
    const accountAddr1BalanceBefore = await addr1.getBalance();

    const tx = await contract
      .connect(addr1)
      .buyTicket(ticketIdForBuy, { value: startPrice });
    await tx.wait();

    const accountOwnerBalanceAfter = await owner.getBalance();
    expect(accountOwnerBalanceAfter).to.equal(
      accountOwnerBalanceBefore.add(startPrice)
    );

    const accountAddr1BalanceAfter = await addr1.getBalance();
    expect(Number(accountAddr1BalanceAfter)).lessThanOrEqual(
      Number(accountAddr1BalanceBefore.sub(startPrice))
    );

    let balance = await contract.balanceOf(owner.address);
    expect(balance).equal(ticketAmount - 1);

    balance = await contract.balanceOf(addr1.address);
    expect(balance).equal(1);

    balance = await contract.balanceOf(addr2.address);
    expect(balance).equal(0);

    const ticketOwner = await contract.ownerOf(ticketIdForBuy);
    expect(ticketOwner).to.equal(addr1.address);

    const ticketDetails = await contract.getTicketDetails(ticketIdForBuy);
  });

  //   it("Should mint the ticket", async function () {
  //     const [owner, addr1] = await ethers.getSigners();
  //     const tx = await contract.mintTiket("My secret", 1000);
  //     await tx.wait();

  //     const tx2 = await contract.mintTiket("My secret2", 10002);
  //     await tx2.wait();

  //     const tx3 = await contract.mintTiket("My secret3", 10003);
  //     await tx3.wait();

  //     const tikets = await contract.getAllTikets();

  //     expect(tikets.length).to.equal(3);
  //   });

  //   async function getSome(owner) {
  //     const myBalance = await contract.connect(owner).myBalance();
  //     console.log(`Why? ${owner}`);
  //     for (let index = 0; index < myBalance; index++) {
  //       console.log(index);
  //       const tiket = await contract.connect(owner).getMyTiketByIndex(index);
  //       console.log(tiket);
  //     }
  //   }

  //   it("Should what?", async () => {
  //     let tikets = await contract.getAllTikets();
  //     const [owner, addr1] = await ethers.getSigners();

  //     await getSome(owner);
  //     await getSome(addr1);

  //     expect(await contract.connect(owner).myBalance()).to.equal(3);
  //     expect(await contract.connect(addr1).myBalance()).to.equal(0);

  //     const tx = await contract.connect(addr1).buyTiket(1);
  //     await tx.wait();

  //     tikets = await contract.getAllTikets();

  //     expect(await contract.connect(owner).myBalance()).to.equal(2);
  //     expect(await contract.connect(addr1).myBalance()).to.equal(1);

  //     await getSome(owner);
  //     await getSome(addr1);
  //   });
});

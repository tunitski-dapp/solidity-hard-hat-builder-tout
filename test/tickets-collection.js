// const { expect, use } = require("chai");
// const { BigNumber } = require("ethers");
// const { ethers } = require("hardhat");
// // const { solidity } = require("ethereum-waffle");

// // use(solidity);

// describe("Ticketing collection", function () {
//   let contract;

//   const eventName = "Cool event!";
//   const ticketAmount = 100;
//   const setsOnRow = 25;
//   const startPrice = Math.pow(10, 15);

//   before(async () => {
//     // VerifyTiketUsage

//     // const VerifyTicketUsageLibrary = await ethers.getContractFactory(
//     //   "VerifyTiketUsage"
//     // );

//     // const lib = await VerifyTicketUsageLibrary.deploy();
//     // await lib.deployed();

//     const TicketsCollection = await ethers.getContractFactory(
//       "TicketsCollection"
//       //  { libraries: { VerifyTiketUsage: lib.address } }
//     );
//     contract = await TicketsCollection.deploy(
//       eventName,
//       ticketAmount,
//       setsOnRow,
//       startPrice
//     );
//     await contract.deployed();
//   });

//   it("after deploy contract should create tickets", async () => {
//     const [owner, addr1, addr2] = await ethers.getSigners();

//     let balance = await contract.balanceOf(owner.address);
//     expect(balance).equal(ticketAmount);

//     balance = await contract.balanceOf(addr1.address);
//     expect(balance).equal(0);

//     balance = await contract.balanceOf(addr2.address);
//     expect(balance).equal(0);
//   });

//   it("should can buy some ticket", async () => {
//     const [owner, addr1, addr2] = await ethers.getSigners();

//     const ticketIdForBuy = 99;

//     const accountOwnerBalanceBefore = await owner.getBalance();
//     const accountAddr1BalanceBefore = await addr1.getBalance();

//     const tx = await contract
//       .connect(addr1)
//       .buyTicket(ticketIdForBuy, { value: startPrice });
//     await tx.wait();

//     const accountOwnerBalanceAfter = await owner.getBalance();
//     expect(accountOwnerBalanceAfter).to.equal(
//       accountOwnerBalanceBefore.add(startPrice)
//     );

//     const accountAddr1BalanceAfter = await addr1.getBalance();
//     expect(Number(accountAddr1BalanceAfter)).lessThanOrEqual(
//       Number(accountAddr1BalanceBefore.sub(startPrice))
//     );

//     let balance = await contract.balanceOf(owner.address);
//     expect(balance).equal(ticketAmount - 1);

//     balance = await contract.balanceOf(addr1.address);
//     expect(balance).equal(1);

//     balance = await contract.balanceOf(addr2.address);
//     expect(balance).equal(0);

//     const ticketOwner = await contract.ownerOf(ticketIdForBuy);
//     expect(ticketOwner).to.equal(addr1.address);

//     const ticketDetails = await contract.getTicketDetails(ticketIdForBuy);

//     expect(ticketDetails.row).equal(BigNumber.from(4));
//     expect(ticketDetails.seet).equal(BigNumber.from(25));
//   });

//   it("should use ticket correctly", async () => {
//     const [owner, addr1, addr2] = await ethers.getSigners();

//     const ticketIdForUse = 29;

//     const wrongMessage = await owner.signMessage("wrongMessage");

//     const correctHash = await contract
//       .connect(owner)
//       .getMessageHashForToken(ticketIdForUse);

//     const wrongHashTicketId = await contract
//       .connect(owner)
//       .getMessageHashForToken(ticketIdForUse + 1);

//     const correctSignMessage = await owner.signMessage(
//       ethers.utils.arrayify(correctHash)
//     );

//     const wrongTicketIdSignMessage = await owner.signMessage(
//       ethers.utils.arrayify(wrongHashTicketId)
//     );

//     // getMessageHashForToken
//     await expect(
//       contract
//         .connect(addr1)
//         .useTicket(ticketIdForUse, ethers.utils.arrayify(wrongMessage))
//     ).to.be.revertedWith("Wrong signature!");

//     await expect(
//       contract
//         .connect(addr1)
//         .useTicket(
//           ticketIdForUse,
//           ethers.utils.arrayify(wrongTicketIdSignMessage)
//         )
//     ).to.be.revertedWith("Wrong signature!");

//     await contract
//       .connect(addr1)
//       .useTicket(ticketIdForUse, ethers.utils.arrayify(correctSignMessage));

//     const ticketDetails = await contract.getTicketDetails(ticketIdForUse);

//     expect(ticketDetails.enable).equals(false);

//     await expect(
//       contract
//         .connect(addr1)
//         .useTicket(ticketIdForUse, ethers.utils.arrayify(correctSignMessage))
//     ).to.be.revertedWith("This signature was use before!");
//   });
// });

const main = async () => {
  const eventTicketingFactory = await hre.ethers.getContractFactory(
    "EventTicketing"
  );
  const eventTicketingContract = await eventTicketingFactory.deploy();

  await eventTicketingContract.deployed();

  console.log(`Contract address: ${eventTicketingContract.address}`);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();

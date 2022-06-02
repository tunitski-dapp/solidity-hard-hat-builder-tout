const main = async () => {
  const [deployer, randomPerson] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();

  console.log("Deploying contracts with account: ", deployer.address);
  console.log("Account balance: ", accountBalance.toString());

  const waveContractFactory = await hre.ethers.getContractFactory(
    "MessagesPortal"
  );
  const waveContract = await waveContractFactory.deploy({
    // value: hre.ethers.utils.parseEther("1"),
  });
  await waveContract.deployed();

  console.log("Contract address:", waveContract.address);

  // const waveTxn2 = await waveContract
  //   .connect(randomPerson)
  //   .byeMoreMessages({ value: hre.ethers.utils.parseEther("0.2") });
  // await waveTxn2.wait();

  // const waveTxn4 = await waveContract.connect(randomPerson).getUserProfile();
};

const runMain = async () => {
  try {
    await main();
    process.exit(0); // exit Node process without error
  } catch (error) {
    console.log(error);
    process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
  }
  // Read more about Node exit ('process.exit(num)') status codes here: https://stackoverflow.com/a/47163396/7974948
};

runMain();

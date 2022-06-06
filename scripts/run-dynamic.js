const main = async () => {
  const [deployer, random] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();

  console.log("Deploying contracts with account: ", deployer.address);
  console.log("Account balance: ", accountBalance.toString());

  const waveContractFactory = await hre.ethers.getContractFactory("DynamicNft");
  const waveContract = await waveContractFactory.deploy({
    // value: hre.ethers.utils.parseEther("0.1"),
  });
  await waveContract.deployed();

  console.log("Contract addy:", waveContract.address);

  let tiket1 = 1;

  let txn1 = await waveContract.buyTiket(tiket1);
  await txn1.wait();

  const allTiket = await waveContract.getTikets();
  console.log(allTiket);

  let tx2 = await waveContract.shareTiket(random.address, tiket1);
  await tx2.wait();

  let tx3 = await waveContract.connect(random).useTiket(tiket1);
  await tx3.wait();

  const allTiket2 = await waveContract.connect(deployer).getTikets();
  console.log(allTiket2);

  const allTiket3 = await waveContract.connect(deployer).getTiket(tiket1);
  console.log(allTiket3);

  // let contractBalance = await hre.ethers.provider.getBalance(
  //   waveContract.address
  // );
  // console.log(
  //   "Contract balance:",
  //   hre.ethers.utils.formatEther(contractBalance)
  // );

  // /*
  //  * Send Wave
  //  */
  // let waveTxn = await waveContract.wave("My first message!");
  // await waveTxn.wait();

  // const waveTxn3 = await waveContract.wave("This is wave #2");
  // await waveTxn3.wait();

  // const waveTxn2 = await waveContract.wave("This is wave #3");
  // await waveTxn2.wait();

  // /*
  //  * Get Contract balance to see what happened!
  //  */
  // contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  // console.log(
  //   "Contract balance:",
  //   hre.ethers.utils.formatEther(contractBalance)
  // );

  // let allWaves = await waveContract.getAllWaves();
  // console.log(allWaves);
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

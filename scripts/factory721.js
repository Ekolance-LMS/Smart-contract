// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
 
  const [admin, student] = await hre.ethers.getSigners();

  // get contract instance
  const EkoTokenFactory = await hre.ethers.getContractFactory("EKO721Factory");
  const ekoTokenFactory = await EkoTokenFactory.deploy();
  // deploy contract
  await ekoTokenFactory.deployed();
  console.log("Ekotoken deployed at", ekoTokenFactory.address);

  //create new NFT
  await ekoTokenFactory.connect(admin).NewEkolanceNFT("EkoNFT", "EK");
  console.log("created NFT");
  
  // check balance of student before mint
  await ekoTokenFactory.connect(admin).getBalanceOf(student.address);

  // mint to student
  await ekoTokenFactory.connect(admin).mintNFT(student.address, "ipfs/ipfs");
  const uri = await ekoTokenFactory.connect(admin).gettoken_uri(0);
  console.log(uri);

  // check balance of student after mint
  await ekoTokenFactory.connect(student).getBalanceOf(student.address);

}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

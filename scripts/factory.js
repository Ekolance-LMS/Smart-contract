// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // get and deploy factory
  //console log deployed
  // creat and mint token. check total supply
  // console log totalsupply and balance of reciever
  // create and mint nft. check balance of recieved address
  // console log totalsupply and balance of reciever
  // burn tokens. check balance of owner and total supply
  // console log totalsupply and balance of reciever

  // get signers admin, tutor, student1, student2
  const [admin, tutor, student1, student2] = await hre.ethers.getSigners();

  // get contract instance
  const EkoTokenFactory = await hre.ethers.getContractFactory("FactoryERC20");
  const ekoTokenFactory = await EkoTokenFactory.deploy();
  // deploy contract
  await ekoTokenFactory.deployed();
  console.log("Ekotoken deployed at", ekoTokenFactory.address);

  //create new token
  await ekoTokenFactory.connect(admin). CreateNewToken("EkoScore", "EKS");
  // set roles
  await ekoTokenFactory.connect(admin).getRoleAdmin();
  // grant tutor role to mint token
  await ekoTokenFactory.connect(admin).grantRole(role_tutor(), tutor.address);

   // check total supply
   await ekoTokenFactory.connect(admin).totalSupply();

   // check balance of student before mint
   await ekoTokenFactory.connect(student1).tokenBalanceOf(student1.address);

  // mint token to student
  await ekoTokenFactory.connect(tutor).mint(student1.address, 100);
  // check balance of student after mint
  await ekoTokenFactory.connect(student1).tokenBalanceOf(student1.address);
  // check total supply
  await ekoTokenFactory.connect(admin).totalSupply();

     // check balance of student2
     await ekoTokenFactory.connect(student2).tokenBalanceOf(student2.address);
  // transfer token from student1 to student2
  await ekoTokenFactory.connect(student1).transfer(student2.address, 20);

   // check balance of student2 
   await ekoTokenFactory.connect(student2).tokenBalanceOf(student2.address);

   // burn some tokens
   await ekoTokenFactory.connect(student2).burn(10);

    // check balance of student2 after burnt
    await ekoTokenFactory.connect(student2).tokenBalanceOf(student2.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

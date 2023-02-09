
const { expect } = require('chai')

// HELPER: get function selectors from a contract
function getSelectors (contract) {
  // get the function signatures from the ABI of the contract:
  const signatures = Object.keys(contract.interface.functions)
  // convert from signature to selector:
  const selectors = signatures.reduce((acc, val) => {
    acc.push(contract.interface.getSighash(val))
    return acc
  }, [])
  return selectors
}

describe('Create a Simple Diamond Contract', async function () {
  let diamond
  let cutDiamond
  let receipt
  let tutor
  let student
  let student2

  /* Before each test - run this setup */
  before(async function () {

    [admin, tutor, student, student2] = await ethers.getSigners();

    // deploy simple Diamond
    const Diamond = await ethers.getContractFactory('Diamond')
    diamond = await Diamond.deploy(admin.address)
    await diamond.deployed()

    console.log('Diamond deployed:', diamond.address)
  })

  /*================================================================*/
  /***************               NFT FACET               ************/
  /*================================================================*/

  it('should add the NFT facet', async () => {
    // we need to link the NFTFacet to its Library function first:
    // const NFTLib = await ethers.getContractFactory('LibNFT')
    // const nftlib = await NFTLib.deploy()
    // await nftlib.deployed()
    // console.log("Deployedd NFT Library")

    // const NFTFacet = await ethers.getContractFactory('EKO721', {
    //   libraries: {
    //     LibNFT: nftlib.address,
    //   }}
    // )
    const NFTlib = await ethers.getContractFactory("EKO721")
    const nftFacet = await NFTlib.deploy("NAME", "FC")
    await nftFacet.deployed()
    console.log("NFT deployed with library dependencies at", nftFacet.address)
    // now we have the NFT Facet deployed with its library dependency

    // get all the function selectors covered by this facet - we need that during the cut below:
    console.log("getting selectors........")
    let selectors = getSelectors(nftFacet)

    // now make the diamond cut (register the facet) - cut the NFT Facet onto the diamond:
    cutDiamond = await diamond.diamondCut(
      {
        facetAddress: nftFacet.address, // the nft facet is deployed here
        functionSelectors: selectors // these are the selectors of this facet (the functions that are supported)
      }, { gasLimit: 800000 }
    )
    receipt = await cutDiamond.wait()
    if (!receipt.status) {
      throw Error(`Diamond upgrade failed: ${cutDiamond.hash}`)
    }
    console.log("NFT faucet cut into diamond")
  })

  // Now test general behavior and expect that the NFT and ERC20 features work
  it('should mint the nft as to student address', async () => {
    const nftFacet = await ethers.getContractAt('EKO721', diamond.address)

    await expect(nftFacet.ownerOf(0)).to.be.revertedWith("ERC721: invalid token ID")
    await expect(nftFacet.ownerOf(1)).to.be.revertedWith("ERC721: invalid token ID")
    expect(await nftFacet.balanceOf(student.address)).to.equal(0)

    console.log("Minting to student address")
    cutDiamond = await nftFacet.mintNFT(student.address, "IPFS/IPFS")
    await cutDiamond.wait()
    console.log("Minted to", student.address)
    console.log()

    // confirm that tutor got the NFT
    console.log("Confirming NFT is minted.....")
    expect(await nftFacet.balanceOf(student.address)).to.equal(1)
    await expect(nftFacet.ownerOf(1)).to.be.revertedWith("ERC721: invalid token ID")
    expect(await nftFacet.ownerOf(0)).to.equal(student.address)
    console.log("Minted to studenet address succesfully")
    console.log()

    // cutDiamond = await nftFacet.connect(tutor).transfer(student.address, 1)
    // await cutDiamond.wait()
    console.log("Checking balance of student")
    expect(await nftFacet.balanceOf(tutor.address)).to.equal(0)
    expect(await nftFacet.balanceOf(student.address)).to.equal(1)
    console.log("checked.....")

   

    // mint more
    cutDiamond = await nftFacet.mintNFT(tutor.address,"ipfs/ipfs")
    await cutDiamond.wait()
    cutDiamond = await nftFacet.mintNFT(student2.address, "ipfs/ipfs2")
    await cutDiamond.wait()
    // cutDiamond = await nftFacet.mint(student.address, 2)
    // await cutDiamond.wait()

    // make sure balances and ownership are correct
    expect(await nftFacet.balanceOf(tutor.address)).to.equal(1)
    expect(await nftFacet.balanceOf(student2.address)).to.equal(1)
    
    expect(await nftFacet.ownerOf(0)).to.equal(student.address)
    expect(await nftFacet.ownerOf(1)).to.equal(tutor.address)
    expect(await nftFacet.ownerOf(2)).to.equal(student2.address)
  })

  /*================================================================*/
  /***************             ERC20 FACET               ************/
  /*================================================================*/

  it('should add the ERC20 facet', async () => {
    //we need to link the EKO20 to its Library function first:
    console.log()
    console.log("Deploy library contract......")
    const ERC20lib = await ethers.getContractFactory('LibEKO20')
    const erc20lib = await ERC20lib.deploy()
    await erc20lib.deployed()
    console.log("Deployed library contract succesfully at", erc20lib.address)

    //const EKO20 = await ethers.getContractFactory('EKO20')
    console.log("Linking token contract with library......")
    const EKO20 = await ethers.getContractFactory("EKO20", {
      libraries: {
        LibEKO20: erc20lib.address
      },
    })
    console.log("Link successfull. deploying contract.......")
    const eko20 = await EKO20.deploy("NAME", "NM")
    //console.log(eko20)
    await eko20.deployed()
    //console.log(await eko20.connect(admin).TokenSummary())
    console.log("Deployed EKO20 successful at address", eko20.address)
    // now we have the NFT Facet deployed with its library dependency

    console.log("Adding EKO20 faucet to Diamond.....")
    // get all the function selectors covered by this facet - we need that during the cut below:
    const selectors = getSelectors(eko20)

    console.log("making Diamond cut........")
    // now make the diamond cut (register the facet) - cut the ERC20 Facet onto the diamond:
    cutDiamond = await diamond.diamondCut(
      {
        facetAddress: eko20.address, // the token facet is deployed here
        functionSelectors:selectors // these are the selectors of this facet (the functions that are supported)
      }, { gasLimit: 800000 }
    )
    receipt = await cutDiamond.wait()
    if (!receipt.status) {
      throw Error(`Diamond upgrade failed: ${cutDiamond.hash}`)
    }
    console.log("successfully added EKO20faucet")
  })
  

  it('should add ERC20 Token functionality: mint, transfer and burn token', async () => {
    //grant roleto tutor
    // tutor mint to student
    // student burn some tokens
    console.log("Deploy library contract......")
    const eRc20lib = await ethers.getContractFactory('LibEKO20')
    const lib20 = await eRc20lib.deploy()
    await lib20.deployed()
    console.log("Deployed library contract succesfully")

    const Eko20 = await ethers.getContractFactory("EKO20", {
      libraries: {
        LibEKO20: lib20.address
      },
    })

    // redeploy
    
    const dep_eko = await Eko20.deploy("name", "sym")
    await dep_eko.deployed("name", "sym")
    console.log("*********", dep_eko.address)
    console.log(await dep_eko.connect(admin).TokenSummary())

    console.log("Adding token functionalities....")
    // note how the facets are sitting at the same address (aka part of the same diamond)
    //const nftFacet = await ethers.getContractAt('NFTFacet', diamond.address)
    
    console.log("Deploy library contract......")
    const ERC20lib = await ethers.getContractFactory('LibEKO20')
    const erc20lib = await ERC20lib.deploy()
    await erc20lib.deployed()
    console.log("Deployed library contract succesfully")

     //const EKO20 = await ethers.getContractFactory('EKO20')
    console.log("Linking token factory contract with library......")
    const EkoFactory = await ethers.getContractFactory("EKO20TokenFactory", {
      libraries: {
        LibEKO20: erc20lib.address
      },
    })
     console.log("Link successfull. deploying factory contract.......")
     const eko_fac = await EkoFactory.deploy()
     
     await eko_fac.deployed()
     //console.log(await eko_fac.connect(admin).TokenSummary())
     //console.log(eko_fac)
     console.log("Deployed factry successful at address", eko_fac.address)
     console.log()

     const selectors = getSelectors(eko_fac)

     console.log("making Diamond cut........")
     // now make the diamond cut (register the facet) - cut the ERC20 Facet onto the diamond:
     cutDiamond = await diamond.diamondCut(
       {
         facetAddress: eko_fac.address, // the token facet is deployed here
         functionSelectors: selectors // these are the selectors of this facet (the functions that are supported)
       }, { gasLimit: 800000 }
     )
     receipt = await cutDiamond.wait()
     if (!receipt.status) {
       throw Error(`Diamond upgrade failed: ${cutDiamond.hash}`)
     }
     console.log("successfully added EKO20Fac faucet")


    const nEKO20 = await ethers.getContractAt("EKO20", diamond.address)
    const nEKO20F = await ethers.getContractAt('EKO20TokenFactory', diamond.address)

    console.log(`get token faucet from diamond ${nEKO20.address, diamond.address}`)
    console.log(`get tokenFactory faucet from diamond ${nEKO20F.address, diamond.address}`)

    console.log(`Eko20: ${nEKO20.address}, dia: ${diamond.address}  EKOFac: ${nEKO20F.address}`)
    console.log("Redone")
    

    // giveadmin role to admin
    cutDiamond = await nEKO20F.connect(admin).createNewToken("EKolance", 'Ek')
    //console.log(cutDiamond)
    cutDiamond = await nEKO20F.connect(admin).getTokenAddress(0)
    console.log("Token factry contratcs: address[0]", cutDiamond)
    cutDiamond = await nEKO20.connect(admin).TokenSummary()
    console.log(cutDiamond)
    
    cutDiamond = await nEKO20.connect(admin).hasRole('0x0000000000000000000000000000000000000000000000000000000000000000', admin.address)
    console.log(cutDiamond)
    cutDiamond = await nEKO20.getRoleAdmin('0x0000000000000000000000000000000000000000000000000000000000000000')
    console.log(admin.address)
    console.log("done")
    cutDiamond = await nEKO20.connect(admin).hasRole('0x0000000000000000000000000000000000000000000000000000000000000000', admin.address)
    console.log(cutDiamond)
    console.log("...Granting role to tutor")
    // cutDiamond = await EKO20.connect(admin.address).grantAdmin_role(admin.address)
    // console.log("done")
    
    // console.log(`${admin.address} is now Admin`)
    
    // //grant role to tutor
    // cutDiamond = await EKO20.grantTutor_role(tutor.address)
    // console.log("done tutor")
    // await cutDiamond.wait()
    // console.log(`tutor role granted to ${tutor.address}`)

    // grant role to student
    // cutDiamond = await nEKO20.connect(admin).grantStudent_role(student.address)
    // await cutDiamond.wait()
    // console.log(cutDiamond)
    // console.log(`Student role granted to ${student.address}`)

    // tutor mint token to student
    cutDiamond = await  nEKO20.connect(admin).mintToken(student.address, 500)
    await cutDiamond.wait()

    //check balance of tutor,student and the total supply
    expect(await EKO20._balanceOf(tutor.address)).to.equal(0)
    expect(await EKO20._balanceOf(student.address)).to.equal(500)
    expect(await EKO20.getTotalSuppy()).to.equal(500)

    // student burn some tokens
    cutDiamond = await EKO20.connect(student).burnToken(100)
    await cutDiamond.wait()
    // check student balance and totalsupply
    expect(await EKO20._balanceOf(student)).to.equal(400)
    expect(await EKO20.getTotalSuppy()).to.equal(400)

    // transfer token to another student
    cutDiamond = await EKO20.connect(student.address)._transfer(student2.address, 50)
    await cutDiamond.wait()

    expect(await EKO20._balanceOf(student.address)).to.equal(350) 
    expect(await EKO20._balanceOf(student2.address)).to.equal(50)
    expect(await EKO20.getTotalSuppy()).to.equal(400)

    // tutor does not have any tokens, and can therefore not transfer anything
    await expect(EKO20.connect(tutor)._transfer(student.address, 20)).to.be.revertedWith("ERC20: transfer amount exceeds balance");

    // student cannot mint token
    await expect(EKO20.connect(student.address).mintToken(student2.address, 20)).to.be.revertedWith("ERC20: Only tutor can mint token");



    // next, use the 20 tokens to mint an NFT
    // expect(await nftFacet.balanceOf(student.address)).to.equal(2) // from previous test calls
    // await expect(nftFacet.ownerOf(4)).to.be.revertedWith("ERC721: invalid token ID") // nobody owns id 4 yet

    // cutDiamond = await nftFacet.connect(student).mintWithERC20(4) // mint ID 4 (not minted yet)
    // await cutDiamond.wait()

    // expect(await nftFacet.balanceOf(student.address)).to.equal(3) // student owns one more
    // expect(await nftFacet.ownerOf(4)).to.equal(student.address) // and specifically owns id 4 just minted

    // // he had to pay 20 tokens for it:
    // expect(await EKO20._balanceOf(tutor.address)).to.equal(0)
    // expect(await EKO20._balanceOf(student.address)).to.equal(0)
    // expect(await EKO20._balanceOf(nftFacet.address)).to.equal(20) // the nft facet got the funds    

    // // now try tutor
    // cutDiamond = await EKO20.erc20mint(tutor.address, 10) // mint less than needed
    // await cutDiamond.wait()
    // expect(await EKO20._balanceOf(tutor.address)).to.equal(10)

    // await expect(nftFacet.connect(tutor).mintWithERC20(6)).to.be.revertedWith("ERC20: transfer amount exceeds balance") // mint ID 6 (not minted yet)
    
    // // give her some more tokens
    // cutDiamond = await EKO20.erc20mint(tutor.address, 100) // mint less than needed
    // await cutDiamond.wait()
    // expect(await EKO20._balanceOf(tutor.address)).to.equal(110)

    // await expect(nftFacet.ownerOf(6)).to.be.revertedWith("ERC721: invalid token ID") // nobody owns id 6 yet

    // cutDiamond = await nftFacet.connect(tutor).mintWithERC20(6) // mint ID 4 (not minted yet)
    // await cutDiamond.wait()

    // expect(await nftFacet.ownerOf(6)).to.equal(tutor.address)

    // expect(await EKO20._balanceOf(student.address)).to.equal(0)
    // expect(await EKO20._balanceOf(tutor.address)).to.equal(90)
    // expect(await EKO20._balanceOf(nftFacet.address)).to.equal(40)
  })
})

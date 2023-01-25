// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721 {
    // Events
    event NewNFT(address token, uint256 tokenId);
    event minted(address mintedTo, uint256 mintNumber);
   

    // Properties
    address admin;

    // get total number of minted tokens of a particlar nft and thier address
    // get address of all minted NFT
    // ensure only 1 nft per address

    // 
    mapping(uint256 => mapping(address => bool)) nftMinted;
    
    
    // mapping struct to tokenid of a minted nft 
    mapping(uint256 => NFT) public tokens;

    uint private mintCount; //get count of minted nfts


    // Struct
    struct NFT {
        address admin;
        uint256 tokenId;
        string name;
        string symbol;
        string uri;
        bool approved;
    }

    //Constructor
    constructor() {
        admin = msg.sender;
    }

    
    // token id can be any codename for nft. like  a  course-code could be the tokenId for the course-nft
    function createNFT(uint256 _tokenId, string memory _name, string memory _symbol, string memory _uri) public {
        require(msg.sender == admin, "Only the admin can create new NFTs.");
        require(tokens[_tokenId].approved == false, "NFT already exists.");

        // Create a new instance of the NFT struct
        tokens[_tokenId] = NFT({
            admin: msg.sender,
            tokenId: _tokenId,
            name: _name,
            symbol: _symbol,
            uri: _uri,
            approved: true
        });
        // Emit the NewNFT event
        emit NewNFT(address(this), _tokenId);
    }

    function mintNFT(address to, uint256 tokenId) public {
        require(msg.sender == admin, "Only the admin can mint NFTs.");
        require(tokens[tokenId].approved == true, "NFT does not exist."); // check if nft has been created
        require(!nftMinted[tokenId][to], "Already NFT holder");  // check if student already have specified nft
        // Mint the NFT to the specified address
        tokens[tokenId].admin = to;   // mint nf tos tudent address 
        mintCount++;

        nftMinted[tokenId][to] = true;  // only one nft per student
        emit minted(to, mintCount);
    }

    function totalMintedNFT() public view returns (uint TotalMints) {
        return mintCount;
    }
    
    // anyone can check if student has specified nft
    // tokenId is the program/bootcamp course code
    function isNFTHolder (uint256 tokenId, address NFTHolder) public view returns (bool){
        return (nftMinted[tokenId][NFTHolder]);
    }

    // check if nft tokenId exist
    function NFTExists(uint256 tokenId) public view returns (bool) {
        return tokens[tokenId].approved;
    }
}
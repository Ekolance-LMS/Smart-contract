// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import { LibNFT } from  "../libraries/LibEKO721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";



contract EKO721 is ERC721URIStorage {
    
    event NFTMinted(uint256 indexed newItemId, address indexed to);

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        LibNFT.setNFT(name, symbol);
        LibNFT.setAdmin(msg.sender);
    }

    modifier onlyAdmin() {
        require(msg.sender == LibNFT.getAdmin(), "Only admin can mint NFT");
        _;
    }

    function mintNFT(address student, string memory URI) external  returns (uint256) {
        require(balanceOf(student) == 0, "already Minted");
        LibNFT.Storage storage ds = LibNFT.getStorage();
        uint256 tokenId = ds._tokenId;
       
        uint256 newItemId = tokenId;
        _mint(student, newItemId);
        _setTokenURI(newItemId, URI);

        emit NFTMinted(newItemId, student);
        ds._tokenId++;
        return newItemId;
    }

}

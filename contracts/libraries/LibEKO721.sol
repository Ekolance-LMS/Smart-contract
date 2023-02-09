/// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


library LibNFT {
   
    bytes32 constant NFT_STORAGE_POSITION = keccak256("facet.nft.diamond.storage");
    bytes32 constant NFT_FACTORY_STORAGE_POSITION = keccak256("facet.nftFac.diamond.storage");

    /**
     * @notice NFT storage for the NFT facet
     */
    struct Storage {
        string name;
        string symbol;
        //uint256 TotalMinted;
        uint256 _tokenId;
        address admin;
    }

    struct FactoryStorage {
        address[] NFTAddresses;
    }
    
    // access nft storage via:
    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = NFT_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function getFactoryStorage() internal pure returns (FactoryStorage storage dsf) {
        bytes32 position = NFT_FACTORY_STORAGE_POSITION;
        assembly {
            dsf.slot := position
        }
    }
    
    function setNFT(string memory name, string memory symbol) internal {
        Storage storage ds = getStorage();
        ds.name = name;
        ds.symbol = symbol;
    }

     function setAdmin(address _admin) internal {
        Storage storage ds = getStorage();
        ds.admin = _admin;
    }

    function getAdmin() internal view returns (address){
        Storage storage ds = getStorage();
        return ds.admin;
    }
}
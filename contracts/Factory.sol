// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./ERC20.sol";
import "./ERC721.sol";

contract Factory {
    event EkolanceTokenCreated(address tokenAddress);
    event EkolanceERC721Created(address tokenAddress);

    function deployNewEkolanceToken(
        string calldata name,
        string calldata symbol
    ) public returns (address) {
        EkolanceToken t = new EkolanceToken(
            name,
            symbol
        );
        emit EkolanceTokenCreated(address(t));

        return address(t);
    }

    function deployNewEkolanceERC721(
        string memory name,
        string memory symbol
    ) public returns (address) {
        EkolanceERC721 t = new EkolanceERC721(name, symbol);
        emit EkolanceERC721Created(address(t));

        return address(t);
    }
}

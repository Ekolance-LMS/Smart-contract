/// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibEKO20 {
    
    // each facet gets their own struct to store state into
    bytes32 constant ERC20_STORAGE_POSITION = keccak256("facet.erc20.diamond.storage");
    
    /**
     * @notice ERC20 storage for the ERC20 facet
     */
    struct Storage {
        string name;
        string symbol;
        uint256 _totalSupply;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
    }
    
    // access erc20 storage via:
    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = ERC20_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function addERC(string memory name, string memory symbol) internal {
        Storage storage ds = getStorage();
        ds.name = name;
        ds.symbol = symbol;
    }
    

    function tokenSummary() internal view returns (string memory, string memory, uint256){
       // getTokenAddress();
        Storage storage ds = getStorage();
        return (ds.name, ds.symbol, ds._totalSupply);
    }

   
    function burn(uint256 amount) internal {
        Storage storage ds = getStorage();
        require(ds._balances[msg.sender] >= amount, "Insufficient tokens");
        ds._balances[msg.sender] -= amount;
        ds._totalSupply -= amount;
        //emit event
    }

    function mint(address to, uint256 amount) public {
        Storage storage ds = getStorage();
        ds._balances[to] += amount;
        ds._totalSupply += amount;
    }

    function balanceOf(address account) public view returns (uint256){
        Storage storage ds = getStorage();
        return ds._balances[account];
    }

    function transfer(address to, uint256 amount) public {
        Storage storage ds = getStorage();
        require(ds._balances[msg.sender] >= amount && amount > 0, "Insufficient funds");
        ds._balances[msg.sender] -= amount;
        ds._balances[to] += amount;
    }

    function totalSupply() public view returns (uint256) {
        Storage storage ds = getStorage();
        return ds._totalSupply;
    }
}
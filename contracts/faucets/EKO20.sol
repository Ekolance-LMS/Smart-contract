// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import { LibEKO20 } from "../libraries/LibEKO20.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract EKO20 is AccessControl {
  
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 internal constant TUTOR_ROLE = keccak256("TUTOR_ROLE");
    bytes32 internal constant STUDENT_ROLE = keccak256("STUDENT_ROLE");

    constructor(string memory _name, string memory _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
         _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(TUTOR_ROLE, msg.sender);
        LibEKO20.addERC(_name, _symbol);    
    }

    // grant admin role
    function grantAdmin_role(address newAdmin) external onlyRole(DEFAULT_ADMIN_ROLE){
        _grantRole(ADMIN_ROLE, newAdmin);
    }

    
    // grant tutor role to mint
    function grantTutor_role(address tutor) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(TUTOR_ROLE, tutor);
    }

    //grant student role to burn token
    function grantStudent_role(address student) external onlyRole(ADMIN_ROLE){
        _grantRole(STUDENT_ROLE, student);
    }

    // mint token to student. only TUTOR role can mint token
    function mintToken(address to, uint256 amount) external onlyRole(TUTOR_ROLE) {
        LibEKO20.mint(to, amount);
    }

    // burn token. only STUDENT role can burn token
    function burnToken(uint256 amount) external onlyRole(STUDENT_ROLE) {
        //LibEKO20.getTokenAddress(tokenIdx);
        LibEKO20.burn(amount);
    }


    // get token summary
    function TokenSummary() external view returns (string memory name, string memory symbol, uint256 totalSupply){
        //LibEKO20.getTokenAddress(tokenIdx);
        return LibEKO20.tokenSummary();
    }

    // get balance. msg.sender 
    function getbalance() public view returns (uint) {
        //EKO20 Token = EKO20(tokenIdx);
        //LibEKO20.getTokenAddress(tokenIdx);
        return LibEKO20.balanceOf(msg.sender);
    }

    // check balance of any address
    function _balanceOf(address acct) public view returns (uint256 balance){
        //EKO20 Token = EKO20(tokenIdx);
        //LibEKO20.getTokenAddress(tokenIdx);
        return LibEKO20.balanceOf(acct);
    }

    // transfer token to any address
    function _transfer(address to, uint256 amount) public {
        //EKO20 Token = EKO20(tokenIdx);
        //LibEKO20.getTokenAddress(tokenIdx);
        LibEKO20.transfer(to, amount);
    }

    // get total supply of tokens
    function getTotalSuppy() public view returns (uint256 TotalSupply){
        //EKO20 Token = EKO20(tokenIdx);
        //LibEKO20.getTokenAddress(tokenIdx);
        return LibEKO20.totalSupply();
    }
}

contract EKO20TokenFactory {
    address[] tokens;

    function createNewToken(string memory name, string memory symbol) public returns (address){
        EKO20 token = new EKO20(name, symbol);
        token;
        tokens.push(address(token));
        return address(token);
    }
    
    function getTokenAddress(uint256 idx) external view returns (address){
        return tokens[idx];
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./EKO20.sol";
import "./EKO721.sol";


contract FactoryERC20 {
    
    EkolanceToken public EkoToken;
    address[] public tokenAddress;
    //uint256 idx;
    event EkolanceTokenCreated(address tokenAddress);
    event TokenMinted(address to, uint256 amount);
    event TokenTransfer(address from, address to, uint256 amount);
    event TokenBurnt(address owner, uint256 amount);

    function CreateNewToken(
        string calldata name,
        string calldata symbol
    ) public returns (address) {
        EkolanceToken t = new EkolanceToken(
            name,
            symbol
        );
        EkoToken = t;
        //EkoToken.push(t);
        tokenAddress.push(address(t));
        emit EkolanceTokenCreated(address(t));
        return address(t);
    }

    // idx could use token symbols as unique identifier
    function mint(address to, uint256 amount) public {
        EkoToken.mint(to, amount);
        emit TokenMinted(to, amount);
    }

    function transfer(address to, uint256 amount) public {
        EkoToken.transfer(to, amount);
        emit TokenTransfer(msg.sender, to, amount);
    }

    function tokenBalanceOf(address account) public view {
        EkoToken.balanceOf(account);
    }

    function grantRole(bytes32 role, address account) public {
        EkoToken.grantRole(role, account);
    }

    function cancelRole(bytes32 role, address account) public {
        EkoToken.revokeRole(role, account);
    }

    function approveTutor(address tutor, uint256 amount) public {
        EkoToken.approve(tutor, amount);
    }

    function totalSupply() public view {
        EkoToken.getTotal_supply();
    }
    // get roles
    // get admin role
    // get balance, total supply, burn
    function getRoles(bytes calldata roles) public view returns(bytes32){
        return EkoToken.getRoleBytes(roles);
    }

    function getRoleAdmin() public view {
        EkoToken.getRoleAdmin(role_admin());
    }
    
    function role_tutor() public pure returns (bytes32){
        return keccak256("TUTOR_ROLE");
    }
    function role_admin() public pure returns (bytes32){
        return keccak256("0x00");
    }
    function role_student() public pure returns (bytes32){
        return keccak256("STUDENT_ROLE");
    }

    function getTokencontract() public view returns (address[] memory){
    return tokenAddress;
    }

    function burnToken(uint256 amount) public {
        //account = msg.sender;
        EkoToken.burn(amount);
        emit TokenBurnt(msg.sender, amount);
    }
}

contract EKO721Factory {
    EkolanceNFT public NFT;
    event EkolanceNFTCreated(address tokenAddress);
    event Minted(address to, uint256 tokenId);

    address[] public NFTAddresses; //get address by index
    uint256 tokenId;

    function NewEkolanceNFT(
        string calldata name,
        string calldata symbol
    ) public returns (address) {
        EkolanceNFT nft = new EkolanceNFT(name, symbol);
        NFT = nft;
        NFTAddresses.push(address(nft));
        emit EkolanceNFTCreated(address(nft));
        return address(nft);
    }

    function mintNFT(address to, string memory uri) public {
        // one NFT per address
        if (getBalanceOf(to) > 1) revert("NFT already minted");
        uint256 token_Id = tokenId;
        NFT.safeMint(to, token_Id, uri);
        emit Minted(to, token_Id);
        tokenId++;
    }

    function gettoken_uri(uint256 token_Id) public view returns (string memory) {
        return NFT.tokenURI(token_Id);
    }
    function getBalanceOf(address holder) public view returns (uint256){
        return NFT.balanceOf(holder);
    }

    function getTokencontract() public view returns (address[] memory){
    return NFTAddresses;
    }
}
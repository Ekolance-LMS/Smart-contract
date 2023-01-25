// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ERC20Token {
    // The address that will own this contract i.e msg.sender
    address public admin;
    string name;
    string symbol;

    // The total supply of the token
    uint256 private totalSupply;

    // The mapping that stores the balance of each address
    mapping(address => uint256) private balanceOf;

    // The mapping that stores the allowance of tokens for each tutor
    mapping(address => mapping(address => uint256)) private allowance;

    // mapping to check that a tutor is approved to mint
    mapping(address => bool) private minters;

    // The event that is emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    // event emitted when token is created
    event newTokenCreated(address indexed admin, string name, string symbol);

    // The event that is emitted when the allowance of tokens for a tutor is set or updated
    event Approval(address indexed tokenadmin, address indexed tutor, uint256 tokens);

    // event when token is minted to student
    event mint(address tutor, address student, uint amount);

    // event for burnt tokens
    event burntTokens(address indexed student, uint256);


    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin has priviledge");
        _;
    }

    constructor()  {
        admin = msg.sender;
    }
    
    function createERC20Token(string memory _name, string memory _symbol) public onlyAdmin() {
        name = _name;
        symbol = _symbol;
        emit newTokenCreated(admin, name, symbol);
    }

    // Returns the total supply of the token
    function ERC20GetTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    // Returns the balance of the specified address
    function ERC20GetBalanceOf(address tokenadmin) public view returns (uint256 available_token_balance) {
        return balanceOf[tokenadmin];
    }

    function ERC20GetTokenSummary() public view returns (string memory _name, string memory _symbol, uint256 _totalSupply) {
        return (name, symbol,totalSupply);
    }

    
    // Approves the specified tutor allowance for number of tokens it can mint
    function ERC20Approve_tutor(address tutor, uint256 tokenAmount) public onlyAdmin() {
        require(tutor != address(0), "caannot approve to the zero address");
        //require(tokens <= balanceOf[msg.sender], "ERC20: approve exceed balance");

        // To change the approval of an tutor, you first have to reset their allowance
        // to zero before setting it to the new value
        allowance[msg.sender][tutor] = 0;

        // Set the allowance
        allowance[msg.sender][tutor] = tokenAmount;
        authorizeMint(tutor);

        // Emit the Approval event
        emit Approval(msg.sender, tutor, tokenAmount);
    }

    // Transfers the specified tokens from the msg.sender balance to the specified address
    function ERC20Transfer(address to, uint256 tokens) public {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokens <= balanceOf[msg.sender], "ERC20: transfer exceed balance");

        // Subtract the tokens from the sender's balance
        balanceOf[msg.sender] -= tokens;

        // Add the tokens to the recipient's balance
        balanceOf[to] += tokens;

        // Emit the Transfer event
        emit Transfer(msg.sender, to, tokens);
    }


    // allows tutor to mint token
    function authorizeMint(address minter) private onlyAdmin() {
        //require(msg.sender == admin, "Only admin can add minters.");
        minters[minter] = true;
    }

    
    // Allows an approved tutor to mint tokens to student address
    function ERC20mintToken(address student, uint256 tokens) public {
        require(minters[msg.sender], "Not authorized t mint");
        require(tokens <= allowance[msg.sender][msg.sender], "amount to mint > allowed limit.");
        balanceOf[student] += tokens;
        totalSupply += tokens;
        allowance[msg.sender][msg.sender] -= tokens;
        emit mint(msg.sender, student, tokens);

    }

    function ERC20Burntoken (address student, uint256 token) public {
        if (msg.sender != student){ // address input is require to avoid accidental burning of token
            revert ("Not owner of token");
        }
        require(token <= balanceOf[student], "Insufficient token balance");
        balanceOf[student] -= token;
        totalSupply -= token;
        emit burntTokens(student,token);
    }
}
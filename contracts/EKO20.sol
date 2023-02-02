// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
//import "./IERC20.sol";
contract EkolanceToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant TUTOR_ROLE = keccak256("TUTOR_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    //bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");

    // struct RoleData {
    //     mapping(address => bool) members;
    //     bytes32 adminRole;
    // }
    mapping(address => uint256) public _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    mapping(bytes32 => RoleData) private _roles;

    //bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // string name;
    // string symbol;


    constructor(string memory name, string memory symbol)  ERC20(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TUTOR_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(TUTOR_ROLE) {
        // if  (to == address(0)) revert("Cannot mint toaddress zero");
        _mint(to, amount);
        _balances[to] += amount;
        _totalSupply += amount;
    }

     /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    // function transfer(address to, uint256 amount) public virtual override returns (bool) {
    //     address owner = _msgSender();
    //     _transfer(owner, to, amount);
    //     return true;
    // }

    function transfer(address to, uint256 amount) public virtual override returns (bool){
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        _totalSupply += amount;
         return true;
    }

    function getRoleBytes(bytes memory role) public pure returns (bytes32){
        return keccak256(role);
    }
     /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     * Requirements:
     *              the caller must have ``role``'s admin role.
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(role, account);
    }

    function getTotal_supply() public pure returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev Revokes `role` from `account`.
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     * Requirements:
     *              the caller must have ``role``'s admin role.
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }
    
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
    *@dev Only student can burn token
    *@param account - address of student. must have student_role access
    *@param amount - amount of tokens to burn
    */
    function _burn(address account, uint256 amount) internal virtual override onlyRole(STUDENT_ROLE) {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
}
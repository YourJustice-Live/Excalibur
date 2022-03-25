//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 
// import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// import "./Rules.sol";
// import "./CommonYJ.sol";
import "../interfaces/IERC1155GUID.sol";



/**
 * @title ERC1155 + Global Unique Identifier for each Token ID
 * @dev use GUID as Role or any other meaningful index
 * V1: 
 */
abstract contract ERC1155GUID is IERC1155GUID, ERC1155 {

    //--- Storage
    // using Strings for uint256;

    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIds; //Track Last Token ID

    // Contract name
    // string public name;
    // Contract symbol
    // string public symbol;
    
    mapping(string => uint256) internal _roles;     //NFTs as Roles


    //--- Modifiers

    modifier roleExists(string calldata role) {
        require(_roleExists(role), "INEXISTENT_ROLE");
        _;
    }

    //--- Functions

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) ERC1155(uri_) {
        /*
        //Set Default Roles
        _roleCreate("admin");
        _roleCreate("member");
        _roleCreate("judge");
        */
    }

    //** Role Functions

    /* [TBD] - would need to track role IDs
    /// Create a new Role
    function roleCreate(string calldata role) public {
        require(!_roleExists(role), "ROLE_EXISTS");
        _roleCreate(role);
    }
    */

    /// Check if account is assigned to role
    function roleHas(address account, string calldata role) public view override returns (bool) {
        return (balanceOf(account, _roleToId(role)) > 0);
    }

    /// Create New Role
    function _roleCreate(string memory role) internal {
        // require(!_roleExists(role), "ROLE_EXISTS");
        // require(_roles[role] == 0, "ROLE_EXISTS");
        require(_roles[role] == 0, string(abi.encodePacked(role, " role already exists ")));
        //Assign Token ID
        _tokenIds.increment(); //Start with 1
        uint256 tokenId = _tokenIds.current();
        //Map Role to Token ID
        _roles[role] = tokenId;
        //Event
        emit RoleCreated(tokenId, role);
    }


    /// Check if Role Exists
    function _roleExists(string calldata role) internal view returns (bool) {
        return (_roles[role] != 0);
    }
    
    /// Assign a role in current jurisdiction
    function _roleAssign(address account, string calldata role) internal roleExists(role) {
        uint256 tokenId = _roles[role];
        //Mint Role Token
        _mint(account, tokenId, 1, "");
    }
    
    /// Unassign a Role in current jurisdiction
    function _roleRemove(address account, string calldata role) internal roleExists(role) {
        uint256 tokenId = _roles[role];
        //Validate
        require(balanceOf(account, tokenId) > 0, "NOT_IN_ROLE");
        //Burn Role Token
        _burn(account, tokenId, 1);
    }

    /// Translate Role to Token ID
    function _roleToId(string calldata role) internal view roleExists(role) returns(uint256) {
        return _roles[role];
    }

    /**
    * @dev Hook that is called before any token transfer. This includes minting and burning, as well as batched variants.
    *  - Max of Single Token for each account
    
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        if (to != address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                //Validate - Max of 1 Per Account
                require(balanceOf(_msgSender(), id) == 0, "ALREADY_ASSIGNED_TO_ROLE");
                require(amount == 1, "ONE_TOKEN_MAX");
            }
        }
    }
    */

    

}
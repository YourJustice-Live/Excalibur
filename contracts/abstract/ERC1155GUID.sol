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
 * @title ERC1155 + meaningfurl Global Unique Identifiers for each Token ID
 * @dev use GUID as Role or any other meaningful index
 * V1: 
 * [TODO] Change Role to GUID
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
    
    // mapping(string => uint256) internal _GUID;     //NFTs as Roles
    mapping(bytes32 => uint256) internal _GUID;     //NFTs as Roles


    //--- Modifiers

    modifier GUIDExists(bytes32 guid) {
        require(_GUIDExists(guid), "INEXISTENT_GUID");
        _;
    }

    //--- Functions

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) ERC1155(uri_) {
        
    }

    //** GUID/Role Functions

    /// Check if account is assigned to role
    function GUIDExist(address account, bytes32 guid) public view override returns (bool) {
        return (balanceOf(account, _GUIDToId(guid)) > 0);
    }

    /// Create New Role
    function _GUIDMake(bytes32 guid) internal returns (uint256) {
        // require(!_GUIDExists(guid), "ROLE_EXISTS");
        // require(_GUID[guid] == 0, "ROLE_EXISTS");
        require(_GUID[guid] == 0, string(abi.encodePacked(guid, " GUID already exists")));
        //Assign Token ID
        _tokenIds.increment(); //Start with 1
        uint256 tokenId = _tokenIds.current();
        //Map Role to Token ID
        _GUID[guid] = tokenId;
        //Event
        emit GUIDCreated(tokenId, guid);
        //Return Token ID
        return tokenId;
    }

    /// Check if Role Exists
    function _GUIDExists(bytes32 guid) internal view returns (bool) {
        return (_GUID[guid] != 0);
    }
    
    /// Assign a role in current jurisdiction
    function _GUIDAssign(address account, bytes32 guid) internal GUIDExists(guid) {
        uint256 tokenId = _GUID[guid];
        //Mint Role Token
        _mint(account, tokenId, 1, "");
    }
    
    /// Unassign a Role in current jurisdiction
    function _GUIDRemove(address account, bytes32 guid) internal GUIDExists(guid) {
        uint256 tokenId = _GUID[guid];
        //Validate
        require(balanceOf(account, tokenId) > 0, "NOT_IN_ROLE");
        //Burn Role Token
        _burn(account, tokenId, 1);
    }

    /// Translate Role to Token ID
    function _GUIDToId(bytes32 guid) internal view GUIDExists(guid) returns(uint256) {
        return _GUID[guid];
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
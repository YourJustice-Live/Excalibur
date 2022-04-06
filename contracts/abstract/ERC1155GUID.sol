//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 
// import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IERC1155GUID.sol";

/**
 * @title 2D ERC1155 -- Members + Groups (Meaningful Global Unique Identifiers for each Token ID)
 * @dev use GUID as Role or any other meaningful index
 */
abstract contract ERC1155GUID is IERC1155GUID, ERC1155 {

    //--- Storage

    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIds; //Track Last Token ID

    mapping(bytes32 => uint256) internal _GUID;     //NFTs as Roles

    //--- Modifiers

    /// Check if GUID Exists
    modifier GUIDExists(bytes32 guid) {
        require(_GUIDExists(guid), "INEXISTENT_GUID");
        _;
    }

    //--- Functions

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155GUID).interfaceId || super.supportsInterface(interfaceId);
    }

    //** GUID/Role Functions

    /// Check if account is assigned to role
    function GUIDHas(address account, bytes32 guid) public view override returns (bool) {
        return (balanceOf(account, _GUIDToId(guid)) > 0);
    }

    /// Create New Role
    function _GUIDMake(bytes32 guid) internal returns (uint256) {
        // require(!_GUIDExists(guid), "ROLE_EXISTS");
        // require(_GUID[guid] == 0, "ROLE_EXISTS");
        // require(_GUID[guid] == 0, string(abi.encodePacked(guid, " GUID already exists")));
        require(_GUIDExists(guid) == false, string(abi.encodePacked(guid, " GUID already exists")));
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
        uint256 tokenId = _GUIDToId(guid);  //_GUID[guid];
        //Mint Role Token       //TODO: Support Various Amounts
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
    // function _GUIDToId(bytes32 guid) internal view returns(uint256) {
        return _GUID[guid];
    }

}
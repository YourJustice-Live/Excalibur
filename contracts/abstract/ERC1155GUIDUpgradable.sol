
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "../interfaces/IERC1155GUID.sol";

/**
 * @title 2D ERC1155 -- Members + Groups (Meaningful Global Unique Identifiers for each Token ID)
 * @dev use GUID as Role or any other meaningful index
 * V1: 
 * [TODO] Change Role to GUID
 */
abstract contract ERC1155GUIDUpgradable is IERC1155GUID, ERC1155Upgradeable {
// abstract contract ERC1155GUIDUpgradable is IERC1155GUID {

    //--- Storage
    // using Strings for uint256;

    // using Counters for Counters.Counter;
    // Counters.Counter internal _tokenIds; //Track Last Token ID
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter internal _tokenIds; //Track Last Token ID
    

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
    function __ERC1155GUIDUpgradable_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

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
    // function _GUIDToId(bytes32 guid) internal view returns(uint256) {
        return _GUID[guid];
    }

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "../abstract/ERC1155TrackerUpgradable.sol";
import "../interfaces/IERC1155GUIDTracker.sol";
import "../libraries/AddressArray.sol";

/**
 * @title 2D ERC1155Tracker -- Members + Groups (Meaningful Global Unique Identifiers for each Token ID)
 * @dev use GUID as a meaningful index
 */
abstract contract ERC1155GUIDTrackerUp is 
        IERC1155GUIDTracker, 
        ERC1155TrackerUpgradable {

    //--- Storage
    // using Strings for uint256;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter internal _tokenIds; //Track Last Token ID
    using AddressArray for address[];
    
    mapping(bytes32 => uint256) internal _GUID; //NFTs as GUID

    //Token Metadata URI
    mapping(uint256 => string) internal _tokenURIs; //Token Metadata URI

    //--- Modifiers

    modifier GUIDExists(bytes32 guid) {
        require(_GUIDExists(guid), "INEXISTENT_GUID");
        _;
    }

    //--- Functions

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155GUIDTracker).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /// Check if Soul Token is assigned to GUID
    function GUIDHasByToken(uint256 soulToken, bytes32 guid) public view override returns (bool) {
        return (balanceOfToken(soulToken, _GUIDToId(guid)) > 0);
    }

    /// Check if account is assigned to GUID
    function GUIDHas(address account, bytes32 guid) public view override returns (bool) {
        return (balanceOf(account, _GUIDToId(guid)) > 0);
    }

    /// Create New GUID
    function _GUIDMake(bytes32 guid) internal returns (uint256) {
        require(_GUIDExists(guid) == false, string(abi.encodePacked(guid, " GUID already exists")));
        //Assign Token ID
        _tokenIds.increment(); //Start with 1
        uint256 tokenId = _tokenIds.current();
        //Map GUID to Token ID
        _GUID[guid] = tokenId;
        //Event
        emit GUIDCreated(tokenId, guid);
        //Return Token ID
        return tokenId;
    }

    /// Check if GUID Exists
    // function GUIDExists(bytes32 guid) internal view returns (bool) {
    //     return (_GUID[guid] != 0);
    // }

    /// Check if GUID Exists
    function _GUIDExists(bytes32 guid) internal view returns (bool) {
        return (_GUID[guid] != 0);
    }

    /// Assign Token
    function _GUIDAssign(address account, bytes32 guid, uint256 amount) internal GUIDExists(guid) returns (uint256) {
        uint256 tokenId = _GUIDToId(guid);  //_GUID[guid];
        //Mint Token
        _mint(account, tokenId, amount, "");
        //Retrun New Token ID
        return tokenId;
    }
    
    /// Assign Token
    function _GUIDAssignToToken(uint256 soulToken, bytes32 guid, uint256 amount) internal GUIDExists(guid) returns (uint256) {
        uint256 tokenId = _GUIDToId(guid);  //_GUID[guid];
        //Mint Token
        _mintForToken(soulToken, tokenId, amount, "");
        //Retrun New Token ID
        return tokenId;
    }

    /// Unassign Token
    function _GUIDRemove(address account, bytes32 guid, uint256 amount) internal GUIDExists(guid) returns (uint256) {
        uint256 tokenId = _GUID[guid];
        //Validate
        require(balanceOf(account, tokenId) > 0, "NOT_ASSIGNED");
        //Burn Token
        _burn(account, tokenId, amount);
        //Retrun New Token ID
        return tokenId;
    }

    /// Unassign Token
    function _GUIDRemoveFromToken(uint256 soulToken, bytes32 guid, uint256 amount) internal GUIDExists(guid) returns (uint256) {
        uint256 tokenId = _GUID[guid];
        //Validate
        // require(balanceOf(account, tokenId) > 0, "NOT_ASSIGNED");
        //Burn Token
        _burnForToken(soulToken, tokenId, amount);
        //Retrun New Token ID
        return tokenId;
    }

    /// Translate GUID to Token ID
    function _GUIDToId(bytes32 guid) internal view GUIDExists(guid) returns(uint256) {
        return _GUID[guid];
    }

    /// Set Token's Metadata URI
    function _setGUIDURI(bytes32 guid, string memory _tokenURI) internal virtual GUIDExists(guid) {
        uint256 tokenId = _GUIDToId(guid);
        _tokenURIs[tokenId] = _tokenURI;
        //URI Changed Event
        emit GUIDURIChange(_tokenURI, guid);
    }

    /// Get Metadata URI by GUID
    function GUIDURI(bytes32 guid) public view override returns(string memory) {
        return _tokenURIs[_GUIDToId(guid)];
    }

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "../interfaces/IERC1155GUID.sol";
import "../libraries/AddressArray.sol";

/**
 * @title 2D ERC1155 -- Members + Groups (Meaningful Global Unique Identifiers for each Token ID)
 * @dev use GUID as a meaningful index
 */
abstract contract ERC1155GUIDUpgradable is IERC1155GUID, ERC1155Upgradeable {

    //--- Storage
    // using Strings for uint256;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter internal _tokenIds; //Track Last Token ID
    using AddressArray for address[];
    mapping(uint256 => address[]) internal _uniqueMembers; //Index Unique Members by Role
    mapping(bytes32 => uint256) internal _GUID; //NFTs as GUID

    //Token Metadata URI
    mapping(uint256 => string) internal _tokenURIs; //Token Metadata URI

    //--- Modifiers

    modifier GUIDExists(bytes32 guid) {
        require(_GUIDExists(guid), "INEXISTENT_GUID");
        _;
    }

    //--- Functions

    /// Unique Members Count (w/Token)
    function uniqueMembers(uint256 id) public view returns (address[] memory) {
        return _uniqueMembers[id];
    }

    /// Unique Members Count (w/Token)
    function uniqueMembersCount(uint256 id) public view returns (uint256) {
        return uniqueMembers(id).length;
    }

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
    function _GUIDExists(bytes32 guid) internal view returns (bool) {
        return (_GUID[guid] != 0);
    }

    /// Assign Token
    function _GUIDAssign(address account, bytes32 guid) internal GUIDExists(guid) returns (uint256) {
        uint256 tokenId = _GUIDToId(guid);  //_GUID[guid];
        //Mint Token
        _mint(account, tokenId, 1, "");
        //Retrun New Token ID
        return tokenId;
    }
    
    /// Unassign Token
    function _GUIDRemove(address account, bytes32 guid) internal GUIDExists(guid) returns (uint256) {
        uint256 tokenId = _GUID[guid];
        //Validate
        require(balanceOf(account, tokenId) > 0, "NOT_ASSIGNED");
        //Burn Token
        _burn(account, tokenId, 1);
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

    /// Track Unique Tokens
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        if (from == address(0)) {   //Mint
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                if(balanceOf(to, id) == 0){
                    _uniqueMembers[id].push(to);
                }
            }
        }
        if (to == address(0)) { //Burn
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                if(balanceOf(from, id) == amounts[i]){   //Burn All
                    _uniqueMembers[id].removeItem(from);
                }
            }
        }
    }

}

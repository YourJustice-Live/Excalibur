//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "../interfaces/IERC1155Roles.sol";
import "./ERC1155GUID.sol";

/**
 * @title Sub-Groups with Role NFTs
 * @dev ERC1155 using GUID as Role
 * To Extend Cases & Jutisdictions
 * - Hold Roles
 * - Assign Roles
 * ---- 
 * - [TODO] request + approve 
 * - [TODO] offer + accept
 * 
 * References: 
 *  Fractal DAO Access Control  https://github.com/fractal-framework/fractal-contracts/blob/93bc0e845a382673f3714e7df858e846d0f10b37/contracts/AccessControl.sol
 *  OZ Access Control  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol
 */
abstract contract ERC1155Roles is IERC1155Roles, ERC1155GUID {
    
    //--- Storage

    //--- Modifiers
    modifier roleExists(string memory role) {
        require(roleExist(role), "INEXISTENT_ROLE");
        _;
    }
    
    /// Validate that account hold one of the role in Array
    modifier onlyRole(string[] calldata roles) {
        bool hasRole;
        for (uint256 i = 0; i < roles.length; ++i) {
            if(roleHas(_msgSender(), roles[i])) hasRole = true;
        }
        require(hasRole, "ROLE:INVALID_PERMISSION");
        _;
    }

    //--- Functions

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155Roles).interfaceId || super.supportsInterface(interfaceId);
    }

    //** Role Functions

    /// Unique Members Addresses
    function uniqueRoleMembers(string memory role) public override view returns (address[] memory) {
        return uniqueMembers(_roleToId(role));
    }

    /// Unique Members Count (w/Token)
    function uniqueRoleMembersCount(string memory role) public override view returns (uint256) {
        return uniqueMembers(_roleToId(role)).length;
    }

    /// Check if Role Exists
    function roleExist(string memory role) public view override returns (bool) {
        return _GUIDExists(_stringToBytes32(role));
    }

    /// Check if account is assigned to role
    function roleHas(address account, string memory role) public view override returns (bool) {
        return GUIDHas(account, _stringToBytes32(role));
    }

    /// Assign Someone Else to a Role
    function _roleAssign(address account, string memory role) internal roleExists(role) {
        _GUIDAssign(account, _stringToBytes32(role));
    }

    /// Remove Someone Else from a Role
    function _roleRemove(address account, string memory role) internal roleExists(role) {
        _GUIDRemove(account, _stringToBytes32(role));
    }

    /// Translate Role to Token ID
    function _roleToId(string memory role) internal view roleExists(role) returns(uint256) {
        return _GUIDToId(_stringToBytes32(role));
    }

    /// Translate string Roles to GUID hashes
    function _stringToBytes32(string memory str) internal pure returns (bytes32){
        require(bytes(str).length <= 32, "String is too long. Max 32 chars");
        return keccak256(abi.encode(str));
    }

    /// Create a new Role
    function _roleCreate(string memory role) internal returns (uint256) {
        return _GUIDMake(_stringToBytes32(role));
    }

    /// Get Metadata URI by Role
    function roleURI(string calldata role) public view override roleExists(role) returns(string memory) {
        return _tokenURIs[_roleToId(role)];
    }

    /// Set Role's Metadata URI
    function _setRoleURI(string memory role, string memory _tokenURI) internal virtual roleExists(role) {
        uint256 tokenId = _roleToId(role);
        _tokenURIs[tokenId] = _tokenURI;
        //URI Changed Event
        emit RoleURIChange(_tokenURI, role);
    }

}
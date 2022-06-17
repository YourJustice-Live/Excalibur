//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
// import "@openzeppelin/contracts/utils/Context.sol";
import "../interfaces/IERC1155RolesTracker.sol";
import "./ERC1155GUIDTrackerUp.sol";

/**
 * @title Sub-Groups with Role NFTs
 * @dev ERC1155 using GUID as Role
 * To Extend Cases & Jutisdictions
 * - Create Roles
 * - Assign Roles
 * - Remove Roles
 * ---- 
 * - [TODO] request + approve 
 * - [TODO] offer + accept
 * 
 * References: 
 *  Fractal DAO Access Control  https://github.com/fractal-framework/fractal-contracts/blob/93bc0e845a382673f3714e7df858e846d0f10b37/contracts/AccessControl.sol
 *  OZ Access Control  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol
 */
abstract contract ERC1155RolesTrackerUp is 
        IERC1155RolesTracker, 
        ERC1155GUIDTrackerUp {
    
    //--- Storage

    //--- Modifiers
    modifier roleExists(string memory role) {
        require(roleExist(role), "INEXISTENT_ROLE");
        _;
    }
    
    /* CANCELLED
    /// [TEST] Validate that account hold one of the role in Array
    modifier onlyRoles(string[] calldata roles) {
        bool hasRole;
        for (uint256 i = 0; i < roles.length; ++i) {
            if(roleHas(_msgSender(), roles[i])) hasRole = true;
        }
        require(hasRole, "ROLE:INVALID_PERMISSION");
        _;
    }

    /// Validate that account hold one of the role in Array //Only works when the role is a parameter
    modifier onlyRole(string calldata role) {
        require(roleHas(_msgSender(), role), "ROLE:INVALID_PERMISSION");
        _;
    }
    */

    //--- Functions

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155RolesTracker).interfaceId || super.supportsInterface(interfaceId);
    }

    //** Role Functions

    /// Unique Members Count (w/Token)
    function uniqueRoleMembers(string memory role) public override view returns (uint256[] memory) {
        return uniqueMembers(_roleToId(role));
    }

    /// Unique Members Count (w/Token)
    function uniqueRoleMembersCount(string memory role) public override view returns (uint256) {
        // return uniqueMembers(_roleToId(role)).length;
        return uniqueMembersCount(_roleToId(role));
    }

    /// Check if Role Exists
    function roleExist(string memory role) public view override returns (bool) {
        return _GUIDExists(_stringToBytes32(role));
    }

    /// Check if Soul Token is assigned to role
    function roleHasByToken(uint256 soulToken, string memory role) public view override returns (bool) {
        return GUIDHasByToken(soulToken, _stringToBytes32(role));
    }

    /// Check if account is assigned to role
    function roleHas(address account, string memory role) public view override returns (bool) {
        return GUIDHas(account, _stringToBytes32(role));
    }

    /// [TEST] Has Any of These Roles
    function rolesHas(address account, string[] memory roles) public view returns (bool) {
        for (uint256 i = 0; i < roles.length; ++i) {
            if(roleHas(account, roles[i])){
                return true;
            } 
        }
        return false;
    }

    /// Assign Someone Else to a Role
    function _roleAssign(address account, string memory role, uint256 amount) internal roleExists(role) {
        //Validate Account Has Token
        require(_getExtTokenId(account) != 0, "ERC1155RolesTracker: account must own a token on source contract");
        //Assign
        _GUIDAssign(account, _stringToBytes32(role), amount);
        //TODO: Role Assigned Event?
    }
    
    /// Assign Tethered Token to a Role
    function _roleAssignToToken(uint256 ownerToken, string memory role, uint256 amount) internal roleExists(role) {
        //Assign
        _GUIDAssignToToken(ownerToken, _stringToBytes32(role), amount);
        //TODO: Role Assigned Event?
    }

    /// Remove Someone Else from a Role
    function _roleRemoveFromToken(uint256 ownerToken, string memory role, uint256 amount) internal roleExists(role) {
        _GUIDRemoveFromToken(ownerToken, _stringToBytes32(role), amount);
        //TODO: Role Removed Event?
    }

    /// Remove Someone Else from a Role
    function _roleRemove(address account, string memory role, uint256 amount) internal roleExists(role) {
        _GUIDRemove(account, _stringToBytes32(role), amount);
        //TODO: Role Removed Event?
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

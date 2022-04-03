//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./ERC1155GUID.sol";
import "../interfaces/IERC1155Roles.sol";


/**
 * @title Sub-Groups with Role NFTs
 * @dev ERC1155 using GUID as Role
 * To Extend Cases & Jutisdictions
 * - [TODO] Hold Roles
 * - [TODO] Assign Roles
 * ---- 
 * - [TODO] request + approve 
 * - [TODO] offer + accept
 * 
 * References: 
 *  Fractal DAO Access Control  https://github.com/fractal-framework/fractal-contracts/blob/93bc0e845a382673f3714e7df858e846d0f10b37/contracts/AccessControl.sol
 *  OZ Access Control  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol
 */
// abstract contract AccessControl is Context, IAccessControl, ERC165 {
// abstract contract ERC1155Roles is IERC1155Roles, ERC165, Context {
abstract contract ERC1155Roles is IERC1155Roles, ERC1155GUID {
    

    //--- Storage

    // Contract name
    // string public name;
    // Contract symbol
    // string public symbol;

    //--- Modifiers
    modifier roleExists(string memory role) {
        require(_GUIDExists(_stringToBytes32(role)), "INEXISTENT_ROLE");
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

    
    // constructor(string memory name_, string memory symbol_, string memory uri) ERC1155GUID(uri) {
    // constructor(string memory uri) ERC1155GUID(uri) {
        // name = name_;
        // symbol = symbol_;
    // }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155Roles).interfaceId || super.supportsInterface(interfaceId);
    }

    //** Role Functions

    /// Check if account is assigned to role
    function roleHas(address account, string memory role) public view override returns (bool) {
        // return ERC1155GUID.GUIDHas(account, _stringToBytes32(role));
        return GUIDHas(account, _stringToBytes32(role));
        // return (balanceOf(account, _roleToId(_stringToBytes32(role))) > 0);
    }

    /// Join a role in current jurisdiction
    // function join() external override {
    //     _GUIDAssign(_msgSender(), _stringToBytes32("member"));
    // }

    // /// Leave Role in current jurisdiction
    // function leave() external override {
    //     _GUIDRemove(_msgSender(), _stringToBytes32("member"));
    // }

    /// Assign Someone Else to a Role
    function _roleAssign(address account, string memory role) internal roleExists(role) {
        _GUIDAssign(account, _stringToBytes32(role));
        //TODO: Role Assigned Event?
    }


    /// Remove Someone Else from a Role
    function _roleRemove(address account, string memory role) internal roleExists(role) {
        _GUIDRemove(account, _stringToBytes32(role));
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






    /* SNIPPETS START */
    
    //--- Fractal DAO Access Control  https://github.com/fractal-framework/fractal-contracts/blob/93bc0e845a382673f3714e7df858e846d0f10b37/contracts/AccessControl.sol
    /*
    string public constant DAO_ROLE = "DAO_ROLE";
    
    mapping(string => RoleData) private _roles;
    mapping(address => mapping(bytes4 => string[])) private _actionsToRoles;
    

    //TODO: Validate that account hold one of the role in Array
    /// @notice Modifier that checks that an account has a specific role. Reverts
    /// with a standardized message including the required role.
    // modifier onlyRole(string memory role) {
    // modifier onlyRole(array roles) {
    //     _checkRole(role, msg.sender);
    //     _;
    // }
    */

    
    //--- OZ  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol

    /*
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }
    mapping(bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    */

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     * /
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }
    
    /**
     * @dev Returns `true` if `account` has been granted `role`.
     * /
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     * /
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

     /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     * /
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }



    /**
     * @dev See {IERC165-supportsInterface}.
     * /
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }


    //https://gist.github.com/axic/ce82bdd1763c04ef8138c2b905985dab
    library StringAsKey {
        function convert(string key) returns (bytes32 ret) {
            if (bytes(key).length > 32) {
            throw;
            }

            assembly {
            ret := mload(add(key, 32))
            }
        }
        }
    /* SNIPPETS END */


}

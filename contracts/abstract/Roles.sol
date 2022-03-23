//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../interfaces/IRoles.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title Role Controls
 * To Extend Cases
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
abstract contract Roles is IRoles, ERC165, Context {
    
    // struct Rule {
    //     string name;
    //     string uri;
    // }
    // mapping(uint256 => Rule) private _rules;

    constructor() {

    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IRoles).interfaceId || super.supportsInterface(interfaceId);
    }

    /* SNIPPETS START */
    
    //--- Fractal DAO Access Control  https://github.com/fractal-framework/fractal-contracts/blob/93bc0e845a382673f3714e7df858e846d0f10b37/contracts/AccessControl.sol
    /*
    string public constant DAO_ROLE = "DAO_ROLE";
    
    mapping(string => RoleData) private _roles;
    mapping(address => mapping(bytes4 => string[])) private _actionsToRoles;
    
    /// @notice Modifier that checks that an account has a specific role. Reverts
    /// with a standardized message including the required role.
    // modifier onlyRole(string memory role) {
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

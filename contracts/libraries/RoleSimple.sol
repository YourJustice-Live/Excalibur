// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity >=0.8.0 <0.9.0;

import "../libraries/DataTypes.sol";

/**
 * @title Simple Roles
 * @notice A standard library with role management functions
 */
library RoleSimple {


    //[TODO] Only elementary types, contract types or enums are allowed as mapping keys

    // Mapping from token ID to account balances
    mapping(string => mapping(DataTypes.NFT => bool)) private _assoc;
    // _assoc[role][nft] => bool

    function hasRole(string role, DataTypes.NFT nft) public view returns (bool) {
        return _assoc[role][nft];
    }
}

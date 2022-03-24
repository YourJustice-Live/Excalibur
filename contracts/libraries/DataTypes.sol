// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity >=0.8.0 <0.9.0;

/**
 * @title DataTypes
 * @notice A standard library of generally used data types
 */
library DataTypes {
    /// NFT Identifiers
    struct Entity {
        address hash;
        uint256 id;
        //uint256 chain;
    }
    /// Rating Domains
    enum Domain {
        Environment,
        Personal,
        Community,
        Professional
    }
    /// Rating Categories
    enum Rating {
        Negative,
        Positive
    }
}

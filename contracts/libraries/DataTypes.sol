// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity >=0.8.0 <0.9.0;

/**
 * @title DataTypes
 * @notice A standard library of generally used data types
 */
library DataTypes {
    /// NFT Identifiers
    struct NFT{
        address constract;
        uint256 id;
    }
    /// Rating Domains
    enum Domain {
        Personal,
        Community,
        Professional
    }
    /// Rating Categories
    enum Rating {
        Positive,
        Negative
    }
}

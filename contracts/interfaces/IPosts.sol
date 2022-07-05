// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "../libraries/DataTypes.sol";

interface IPosts {

    //--- Functions

    //--- Events

    /// General Post / Evidence, etc'
    event Post(address indexed account, uint256 tokenId, string entRole, string uri);

}

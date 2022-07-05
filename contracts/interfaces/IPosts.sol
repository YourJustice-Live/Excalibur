// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "../libraries/DataTypes.sol";

interface IPosts {

    //--- Functions

    //Add a new Post
    // function post(string calldata entRole, uint256 tokenId, string calldata uri_) external;

    //--- Events

    /// General Post / Evidence, etc'
    event Post(address indexed account, uint256 tokenId, string entRole, string uri);

}

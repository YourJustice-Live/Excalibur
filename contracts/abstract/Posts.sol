//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "../interfaces/IPosts.sol";

/**
 * @title Rules Contract 
 * @dev To Extend or Be Used by Jurisdictions
 * - Hold, Update, Delete & Serve Rules
 */
abstract contract Posts is IPosts {
    
    //--- Storage

    //Post Input Struct
    struct PostInput {
        uint256 tokenId;
        string entRole;
        string uri;
    }

    //--- Functions

    /// Add Post 
    /// @param origin  caller address
    /// @param tokenId  posting as entitiy SBT
    /// @param entRole  posting as entitiy in role (posting entity must be assigned to role)
    /// @param uri      post data uri
    // function post(uint256 token_id, string calldata uri) external override {     //Post by Token ID (May later use Entity GUID as Caller)
    // function post(string calldata entRole, string calldata postRole, string calldata uri) external override {        //Explicit postRole
    // function _post(address origin, string calldata entRole, string calldata uri) internal {
    function _post(address origin, uint256 tokenId, string calldata entRole, string calldata uri) internal {
        // emit Post(origin, entRole, uri);
        emit Post(origin, tokenId, entRole, uri);
    }
}

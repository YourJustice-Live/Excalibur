//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
// pragma experimental ABIEncoderV2;    //https://docs.soliditylang.org/en/v0.5.2/abi-spec.html?highlight=abiencoderv2

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
        string entRole;
        // string postRole;
        string uri;
    }

    //--- Functions

    /// Add Post 
    /// @param entRole  posting as entitiy in role (posting entity must be assigned to role)
    // function post(uint256 token_id, string calldata uri) external override {     //Post by Token ID (May later use Entity GUID as Caller)
    // function post(string calldata entRole, string calldata postRole, string calldata uri) external override {        //Explicit postRole
    function _post(address origin, string calldata entRole, string calldata uri) internal {
        emit Post(origin, entRole, uri);
    }

}

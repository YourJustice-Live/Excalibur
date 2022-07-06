//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";
import "../interfaces/IPosts.sol";

/**
 * @title Posts for Contracts 
 */
abstract contract Posts is IPosts {
    
    //--- Storage

    //--- Functions

    /// Add Post 
    /// @param origin  caller address
    /// @param tokenId  posting as entitiy SBT
    /// @param entRole  posting as entitiy in role (posting entity must be assigned to role)
    /// @param uri      post data uri
    function _post(address origin, uint256 tokenId, string calldata entRole, string calldata uri) internal {
        // emit Post(origin, entRole, uri);
        emit Post(origin, tokenId, entRole, uri);
    }
    
}

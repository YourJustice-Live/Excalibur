// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICase {
    
    //-- Functions

    /// Initialize
    function initialize(string memory name_, string memory symbol_, address hub ) external ;

    /// Assign Someone to a Role
    function roleAssign(address account, string calldata role) external;

    //--- Events

    /// Post
    event Post(address indexed account, string role, string uri);

}

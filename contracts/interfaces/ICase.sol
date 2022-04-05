// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../libraries/DataTypes.sol";

interface ICase {
    
    //-- Functions

    /// Initialize
    // function initialize(string memory name_, string memory symbol_, address hub) external ;
    // function initialize(string memory name_, string memory symbol_, address hub, DataTypes.RuleRef[] memory addRules) external ;
    function initialize(string memory name_, string memory symbol_, address hub, DataTypes.RuleRef[] memory addRules, DataTypes.InputRole[] memory assignRoles) external ;

    /// Assign Someone to a Role
    function roleAssign(address account, string calldata role) external;

    //--- Events

    /// Post
    // event Post(address indexed account, string role, string uri);
    event Post(address indexed account, string entRole, string postRole, string uri);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../libraries/DataTypes.sol";

interface IRules {
    
    //--- Events

    /// Rule Added
    event RuleAdded(uint256 indexed id, DataTypes.Rule rule);

    /// Rule Removed
    event RuleRemoved(uint256 indexed id);

    /// Rule Removed
    // RuleChanged(uint256 indexed id);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../libraries/DataTypes.sol";

interface IRules {
    
    /// Expose Action Repo Address
    function actionRepo() external view returns (address);

    ///Get Rule
    function ruleGet(uint256 id) external view returns (DataTypes.Rule memory);

    //--- Events

    /// Action Repository (HISTORY) Set
    event ActionRepoSet(address actionRepo);

    /// Rule Added
    event RuleAdded(uint256 indexed id, bytes32 about, string uri, bool negation);

    /// Rule Removed
    event RuleRemoved(uint256 indexed id);

    /// Rule Removed
    event RuleChanged(uint256 indexed id, bytes32 about, string uri, bool negation);

}

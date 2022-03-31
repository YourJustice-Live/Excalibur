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
    event Rule(uint256 indexed id, bytes32 about, string uri, bool negation);

    /// Rule Removed
    event RuleRemoved(uint256 indexed id);

    /// Rule's Effects
    event RuleEffects(uint256 indexed id, int8 environmental, int8 personal, int8 social, int8 professional);
}

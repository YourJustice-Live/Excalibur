// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IRules {
    
    /// Expose Action Repo Address
    // function actionRepo() external view returns (address);

    ///Get Rule
    function ruleGet(uint256 id) external view returns (DataTypes.Rule memory);

    /// Get Rule's Effects
    function effectsGet(uint256 id) external view returns (DataTypes.Effect[] memory);

    /// Get Rule's Confirmation Method
    function confirmationGet(uint256 id) external view returns (DataTypes.Confirmation memory);

    /// Update Confirmation Method for Action
    // function confirmationSet(uint256 id, DataTypes.Confirmation memory confirmation) external;

    //--
    
    /// Generate a Global Unique Identifier for a Rule
    // function ruleGUID(DataTypes.Rule memory rule) external pure returns (bytes32);


    /// Create New Rule
    function ruleAdd(DataTypes.Rule memory rule, DataTypes.Confirmation memory confirmation, DataTypes.Effect[] memory effects) external returns (uint256);

    /// Update Rule
    function ruleUpdate(uint256 id, DataTypes.Rule memory rule, DataTypes.Effect[] memory effects) external;
    
    /// Set Disable Status for Rule
    function ruleDisable(uint256 id, bool disabled) external;

    /// Update Rule's Confirmation Data
    function ruleConfirmationUpdate(uint256 id, DataTypes.Confirmation memory confirmation) external;
  
    //--- Events

    /// Action Repository (HISTORY) Set
    // event ActionRepoSet(address actionRepo);

    /// Rule Added or Changed
    event Rule(uint256 indexed id, bytes32 about, string affected, string uri, bool negation);

    /// Rule Disabled Status Changed
    event RuleDisabled(uint256 id, bool disabled);

    /// Rule Removed
    event RuleRemoved(uint256 indexed id);

    /// Rule's Effects
    // event RuleEffects(uint256 indexed id, int8 environmental, int8 personal, int8 social, int8 professional);
    /// Generic Role Effect
    event RuleEffect(uint256 indexed id, bool direction, uint8 value, string name);

    /// Action Confirmation Change
    event Confirmation(uint256 indexed id, string ruling, bool evidence, uint witness);

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "../interfaces/IRules.sol";
import "../interfaces/IActionRepo.sol";
import "../libraries/DataTypes.sol";

/**
 * @title Rules Contract 
 * @dev To Extend or Be Used by Games
 * - Hold, Update, Delete & Serve Rules
 * [TODO] Rules should not be changed passed a certain point. (Maybe after they were used in reactions / applied to Avatars)
 */
abstract contract Rules is IRules {
    
    //--- Storage

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _ruleIds;

    //Rule Data
    mapping(uint256 => DataTypes.Rule) internal _rules;
    
    //Additional Rule Data
    mapping(uint256 => DataTypes.Confirmation) internal _ruleConfirmation;
    mapping(uint256 => DataTypes.Effect[]) internal _effects;     //effects[id][] => {direction:true, value:5, name:'personal'}  // Generic, Iterable & Extendable/Flexible
    // mapping(uint256 => string) internal _uri;

    //--- Functions

    /// Generate a Global Unique Identifier for a Rule
    // function ruleGUID(DataTypes.Rule memory rule) public pure override returns (bytes32) {
        // return bytes32(keccak256(abi.encode(rule.about, rule.affected, rule.negation, rule.tool)));
        // return bytes32(keccak256(abi.encode(ruleId, gameId)));
    // }

    //-- Getters

    /// Get Rule
    function ruleGet(uint256 id) public view override returns (DataTypes.Rule memory) {
        return _rules[id];
    }

    /// Get Rule's Effects
    function effectsGet(uint256 id) public view override returns (DataTypes.Effect[] memory){
        return _effects[id];
    }
   
    /// Get Rule's Confirmation Method
    function confirmationGet(uint256 id) public view override returns (DataTypes.Confirmation memory){
        return _ruleConfirmation[id];
    }

    //-- Setters

    /// Add Rule
    function _ruleAdd(DataTypes.Rule memory rule, DataTypes.Effect[] memory effects) internal returns (uint256) {
        //Add New Rule
        _ruleIds.increment();
        uint256 id = _ruleIds.current();
        //Set
        _ruleSet(id, rule, effects);
        //Return
        return id;
    }

    /// Set Rule
    function _ruleSet(uint256 id, DataTypes.Rule memory rule, DataTypes.Effect[] memory effects) internal {
        //Set
        _rules[id] = rule;
        //Rule Updated Event
        emit Rule(id, rule.about, rule.affected, rule.uri, rule.negation);
        // emit RuleEffects(id, rule.effects.environmental, rule.effects.personal, rule.effects.social, rule.effects.professional);
        for (uint256 i = 0; i < effects.length; ++i) {
            _effects[id].push(effects[i]);
            //Effect Added Event
            emit RuleEffect(id, effects[i].direction, effects[i].value, effects[i].name);
        }
    }

    /// Update Rule
    function _ruleUpdate(uint256 id, DataTypes.Rule memory rule, DataTypes.Effect[] memory effects) internal {
        //Remove Current Effects
        delete _effects[id];
        //Update Rule
        _ruleSet(id, rule, effects);
    }
    
    /// Disable Rule
    function _ruleDisable(uint256 id, bool disabled) internal {
        _rules[id].disabled = disabled;
        //Event
        emit RuleDisabled(id, disabled);
    }
    
    /// Remove Rule
    function _ruleRemove(uint256 id) internal {
        delete _rules[id];
        //Event
        emit RuleRemoved(id);
    }

    //TODO: Separate Rule Effects Update from Rule Update

    /* REMOVED - This should probably be in the implementing Contract
    /// Update Confirmation Method for Action
    function confirmationSet(uint256 id, DataTypes.Confirmation memory confirmation) external override {
        //TODO: Validate Caller's Permissions
        _confirmationSet(id, confirmation);
    }
    */

    /// Set Action's Confirmation Object
    function _confirmationSet(uint256 id, DataTypes.Confirmation memory confirmation) internal {
        _ruleConfirmation[id] = confirmation;
        emit Confirmation(id, confirmation.ruling, confirmation.evidence, confirmation.witness);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IRules.sol";
import "../interfaces/IActionRepo.sol";
import "../libraries/DataTypes.sol";

/**
 * @title Rules Contract 
 * @dev To Extend or Be Used by Jurisdictions
 * - Hold, Update, Delete & Serve Rules
 * [TODO] Rules should not be changed passed a certain point. (Maybe after they were used/applied to Avatars)
 */
abstract contract Rules is IRules {
    
    //--- Storage

    using Counters for Counters.Counter;
    Counters.Counter private _ruleIds;
    //Action Repository Contract (HISTORY)
    // IActionRepo internal _actionRepo;
    // address private _actionRepo;

    //Rule Data
    mapping(uint256 => DataTypes.Rule) internal _rules;
    
    //Additional Rule Data
    mapping(uint256 => DataTypes.Confirmation) internal _ruleConfirmation;
    mapping(uint256 => DataTypes.Effect[]) internal _effects;     //effects[id][] => {direction:true, value:5, name:'personal'}  // Generic, Iterable & Extendable/Flexible
    // mapping(uint256 => string) internal _uri;

    //--- Functions
    
    /* CANCELLED
    /// Set Actions Contract
    function _setActionsContract(address actionRepo_) internal {
        // require(address(_actionRepo) == address(0), "HISTORY Contract Already Set");
        require(_actionRepo == address(0), "HISTORY Contract Already Set");
        //String Match - Validate Contract's Designation        //TODO: Maybe Look into Checking the Supported Interface
        require(keccak256(abi.encodePacked(IActionRepo(actionRepo_).symbol())) == keccak256(abi.encodePacked("HISTORY")), "Expecting HISTORY Contract");
        //Set
        // _actionRepo = IActionRepo(actionRepo_);
        _actionRepo = actionRepo_;
        //Event
        emit ActionRepoSet(actionRepo_);
    }
    
    /// Expose Action Repo Address
    function actionRepo() external view override returns (address) {
        // return address(_actionRepo);
        return _actionRepo;
    }
    */

    /// Get Rule
    function ruleGet(uint256 id) public view override returns (DataTypes.Rule memory) {
        return _rules[id];
    }

    /// Add Rule
    // function _ruleAdd(DataTypes.Rule memory rule) internal returns (uint256) {
    function _ruleAdd(DataTypes.Rule memory rule, DataTypes.Effect[] memory effects) internal returns (uint256) {
        //Add New Rule
        _ruleIds.increment();
        uint256 id = _ruleIds.current();
        //Set
        _ruleSet(id, rule, effects);
        //Return
        return id;
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


    /// Set Rule
    // function _ruleSet(uint256 id, DataTypes.Rule memory rule) internal {
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
    
    /// Get Rule's Confirmation Method
    function confirmationGet(uint256 id) public view override returns (DataTypes.Confirmation memory){
        return _ruleConfirmation[id];
    }

    /* REMOVED - This should probably be in the implementing Contract
    /// Update Confirmation Method for Action
    function confirmationSet(uint256 id, DataTypes.Confirmation memory confirmation) external override {
        //TODO: Validate Caller's Permissions
        _confirmationSet(id, confirmation);
    }
    */

    /// Get Rule's Effects
    function effectsGet(uint256 id) public view override returns (DataTypes.Effect[] memory){
        return _effects[id];
    }
   
    /// Set Action's Confirmation Object
    function _confirmationSet(uint256 id, DataTypes.Confirmation memory confirmation) internal {
        _ruleConfirmation[id] = confirmation;
        emit Confirmation(id, confirmation.ruling, confirmation.evidence, confirmation.witness);
    }

}

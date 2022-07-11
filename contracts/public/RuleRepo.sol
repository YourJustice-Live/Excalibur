//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/utils/Context.sol";
// import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "../libraries/DataTypes.sol";
import "../interfaces/IERC1155RolesTracker.sol";
import "../interfaces/IRulesRepo.sol";
import "../interfaces/IActionRepo.sol";
import "../interfaces/IProtocolEntity.sol";
import "../interfaces/IGameUp.sol";
import "../public/interfaces/IOpenRepo.sol";

/**
 * @title Rule Repository
 * @dev Contract as a Service -- Retains Rules for Other Contracts
 * To be used by a contract that implements IERC1155RolesTracker
 * Version 1.0
 * - Sender expected to be a protocol entity
 * - Sender expected to support getHub() & repoAddr()
 */
contract RuleRepo is IRules {

    //--- Storage

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _ruleIds;

    //Rule Data
    mapping(address => mapping(uint256 => DataTypes.Rule)) internal _rules;
    mapping(address => mapping(uint256 => DataTypes.Confirmation)) internal _ruleConfirmation;  //Rule Confirmations
    mapping(address => mapping(uint256 => DataTypes.Effect[])) internal _effects;  //Rule Efects (Reputation Changes)   //effects[id][] => {direction:true, value:5, name:'personal'}  // Generic, Iterable & Extendable/Flexible
    mapping(address => mapping(uint256 => bytes32[])) internal _reactions;  //Rule Reactions (Consequences) //action GUIDs   
    // mapping(address => mapping(uint256 => string) internal _uri;

    //--- Functions

    //** Protocol Functions
    
    //Use Self (Main Game)
    function game() internal view returns (IGame) {
        return IGame(address(msg.sender));
    }

    /// Hub Address
    function hubAddress() internal view returns (address) {
        return IProtocolEntity(msg.sender).getHub();
    }

    //Get Data Repo Address (From Hub)
    function repoAddr() public view returns (address) {
        return IProtocolEntity(msg.sender).repoAddr();
    }

    //Get Assoc Repo
    function repo() internal view returns (IOpenRepo) {
        return IOpenRepo(repoAddr());
    }

    //** Rule Management

    //-- Getters

    /// Get Rule
    function ruleGet(uint256 id) public view override returns (DataTypes.Rule memory) {
        return _rules[msg.sender][id];
    }

    /// Get Rule's Effects
    function effectsGet(uint256 id) public view override returns (DataTypes.Effect[] memory){
        return _effects[msg.sender][id];
    }

    /// Get Rule's Confirmation Method
    function confirmationGet(uint256 id) public view override returns (DataTypes.Confirmation memory){
        return _ruleConfirmation[msg.sender][id];
    }

    //-- Setters

    /// Create New Rule
    function ruleAdd(
        DataTypes.Rule memory rule, 
        DataTypes.Confirmation memory confirmation, 
        DataTypes.Effect[] memory effects
    ) public override returns (uint256) {
        //Validate Caller's Permissions
        require(IERC1155RolesTracker(msg.sender).roleHas(tx.origin, "admin"), "Admin Only");
        
        //Validate rule.about -- actionGUID Exists
        address actionRepo = repo().addressGetOf(hubAddress(), "history");

        IActionRepo(actionRepo).actionGet(rule.about);  //Revetrs if does not exist
        //Add Rule
        uint256 id = _ruleAdd(rule, effects);

        //Set Confirmations
        _confirmationSet(id, confirmation);
        return id;
    }

    /// Update Rule
    function ruleUpdate(
        uint256 id, 
        DataTypes.Rule memory rule, 
        DataTypes.Effect[] memory effects
    ) external override {
        //Validate Caller's Permissions
        require(IERC1155RolesTracker(msg.sender).roleHas(tx.origin, "admin"), "Admin Only");
        //Update Rule
        _ruleUpdate(id, rule, effects);
    }

    /// Set Disable Status for Rule
    function ruleDisable(uint256 id, bool disabled) external override {
         //Validate Caller's Permissions
        require(IERC1155RolesTracker(msg.sender).roleHas(tx.origin, "admin"), "Admin Only");
        //Disable Rule
        _ruleDisable(id, disabled);
    }

    /// Update Rule's Confirmation Data
    function ruleConfirmationUpdate(uint256 id, DataTypes.Confirmation memory confirmation) external override {
        //Validate Caller's Permissions
        require(IERC1155RolesTracker(msg.sender).roleHas(tx.origin, "admin"), "Admin Only");
        //Set Confirmations
        _confirmationSet(id, confirmation);
    }

    /*
    /// TODO: Update Rule's Effects
    function ruleEffectsUpdate(uint256 id, DataTypes.Effect[] memory effects) external override {
        //Validate Caller's Permissions
        require(IERC1155RolesTracker(msg.sender).roleHas(tx.origin, "admin"), "Admin Only");
        //Set Effects
        
    }
    */

    /// Generate a Global Unique Identifier for a Rule
    // function ruleGUID(DataTypes.Rule memory rule) public pure override returns (bytes32) {
        // return bytes32(keccak256(abi.encode(rule.about, rule.affected, rule.negation, rule.tool)));
        // return bytes32(keccak256(abi.encode(ruleId, gameId)));
    // }

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

    /// Disable Rule
    function _ruleDisable(uint256 id, bool disabled) internal {
        _rules[msg.sender][id].disabled = disabled;
        //Event
        emit RuleDisabled(msg.sender, id, disabled);
    }
    
    /// Remove Rule
    function _ruleRemove(uint256 id) internal {
        delete _rules[msg.sender][id];
        //Event
        emit RuleRemoved(msg.sender, id);
    }

    //TODO: Separate Rule Effects Update from Rule Update

    /// Set Rule
    function _ruleSet(uint256 id, DataTypes.Rule memory rule, DataTypes.Effect[] memory effects) internal {
        //Set
        _rules[msg.sender][id] = rule;
        //Rule Updated Event
        emit Rule(msg.sender, id, rule.about, rule.affected, rule.uri, rule.negation);

        // emit RuleEffects(msg.sender, id, rule.effects.environmental, rule.effects.personal, rule.effects.social, rule.effects.professional);
        for (uint256 i = 0; i < effects.length; ++i) {
            _effects[msg.sender][id].push(effects[i]);
            //Effect Added Event
            emit RuleEffect(msg.sender, id, effects[i].direction, effects[i].value, effects[i].name);
        }
    }

    /// Update Rule
    function _ruleUpdate(uint256 id, DataTypes.Rule memory rule, DataTypes.Effect[] memory effects) internal {
        //Remove Current Effects
        delete _effects[msg.sender][id];
        //Update Rule
        _ruleSet(id, rule, effects);
    }
    
    /* REMOVED - This should probably be in the implementing Contract
    /// Update Confirmation Method for Action
    function confirmationSet(uint256 id, DataTypes.Confirmation memory confirmation) external override {
        //TODO: Validate Caller's Permissions
        _confirmationSet(id, confirmation);
    }
    */

    /// Set Action's Confirmation Object
    function _confirmationSet(uint256 id, DataTypes.Confirmation memory confirmation) internal {
        //Save
        _ruleConfirmation[msg.sender][id] = confirmation;
        //Event
        emit Confirmation(msg.sender, id, confirmation.ruling, confirmation.evidence, confirmation.witness);
    }

    /// Set Action's Reaction ID
    function _reactionSet(uint256 id, bytes32 reaction) internal {
        //Save
        _reactions[msg.sender][id][0] = reaction;
        //Event
        emit Reaction(msg.sender, id, reaction);
    }
   
}

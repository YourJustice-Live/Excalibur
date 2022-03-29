//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;    //https://docs.soliditylang.org/en/v0.5.2/abi-spec.html?highlight=abiencoderv2

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../libraries/DataTypes.sol";
import "./Opinions.sol";
import "../interfaces/IRules.sol";
import "../interfaces/IActionRepo.sol";


/**
 * Rules Contract
 * To Extend or Be Used by Jurisdictions
 * - Hold & Serve Rules
 * - [TODO] Event: Rule Added / Removed / Updated (can rules be removed?)
 */
// abstract contract Rules is IRules, Opinions {
contract Rules is IRules, Opinions {
    
    //--- Storage

    using Counters for Counters.Counter;
    Counters.Counter private _ruleIds;


    mapping(uint256 => DataTypes.Rule) internal _rules;


    //--- Functions

    // constructor() { }

    /// Get Rule
    function ruleGet(uint256 id) public view returns (DataTypes.Rule memory) {
        return _rules[id];
    }

    /// Add Rule
    // function _ruleAdd(address actionRepo, bytes32 actionGUID, DataTypes.Rule memory rule) internal {
    function _ruleAdd(address actionRepo, DataTypes.Rule memory rule) internal {
        //String Match - Validate Contract's Designation        //TODO: Maybe Look into Checking the Supported Interface
        require(keccak256(abi.encodePacked(IActionRepo(actionRepo).symbol())) == keccak256(abi.encodePacked("HISTORY")), "Expecting HISTORY Contract");
        //Add New Rule
        _ruleIds.increment();
        uint256 id = _ruleIds.current();
        _rules[id] = rule;
        emit RuleAdded(id, rule);
    }

    /// Remove Rule
    function _ruleRemove(uint256 id) internal {
        delete _rules[id];
        emit RuleRemoved(id);
    }

}

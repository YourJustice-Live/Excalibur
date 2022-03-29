//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;    //https://docs.soliditylang.org/en/v0.5.2/abi-spec.html?highlight=abiencoderv2

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Opinions.sol";
import "../interfaces/IRules.sol";
import "../interfaces/IActionRepo.sol";


/**
 * Rules Contract
 * To Extend or Be Used by Jurisdictions
 * - [TODO] Hold & Serve Rules
 * - [TODO] Event: Rule Added / Removed / Updated (can rules be removed?)
 */
// abstract contract Rules is IRules, Opinions {
contract Rules is IRules, Opinions {
    
    //--- Storage

    using Counters for Counters.Counter;
    Counters.Counter private _ruleIds;

    // Rule Object
    struct Rule {
        // string name;
        // string uri;
        //eventId: 1, 
        // uint256 about;    //About What (Token URI +? Contract Address)
        bytes32 about;    //About What (Action's GUID)

        //text: "The founder of the project violated the contract, but this did not lead to the loss or freezing of funds for investors.", //Description For Humans
        // string text;
        // condition: "Investor funds were not frozen nor lost.",
        // string condition;  
        string uri;     //Test & Conditions
        
        // effect: { //Reputation Change
        //     profiessional:-2,
        //     social: -4
        // }
        // Effect[3] effects;
        Effects effects;
        bool negation;  //0 - Commision  1 - Omission
    }
    
    // Effect Object (Changes to Reputation By Type)
    struct Effects {
        int8 professional;
        int8 social;
        int8 personal;
        // Effect environment;
        // Effect personal;
        // Effect social;
        // Effect professional;
    }
    /* Maybe?
    // Effect Structure
    struct Effect {
        // value: 5
        int8 value;
        // Direction: -
        bool direction;
        // Confidence/Strictness: [?]
    }
    */

    mapping(uint256 => Rule) internal _rules;


    //--- Functions

    // constructor() { }

    /// Get Rule
    function ruleGet(uint256 id) public view returns (Rule memory) {
        return _rules[id];
    }

    /// Add Rule
    function ruleAdd(address actionRepo, bytes32 actionGUID, Rule memory rule) public {
        //TODO: Validate Caller's Permissions

        _ruleAdd(actionRepo, actionGUID, rule);
    }

    /// Add Rule
    function _ruleAdd(address actionRepo, bytes32 actionGUID, Rule memory rule) internal {
        //TODO: Verify Action ID
        // IActionRepo(actionRepo)


        _ruleIds.increment();
        uint256 newItemId = _ruleIds.current();
        _rules[newItemId] = rule;
    }

    /// Remove Rule
    function _ruleRemove(uint256 id) internal {
        delete _rules[id];
    }

}

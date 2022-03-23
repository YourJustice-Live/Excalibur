//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

/**
 * Rules Contract
 * To Extend or Be Used by Jurisdictions
 * - [TODO] Hold & Serve Rules
 * - [TODO] Event: Rule Added / Removed / Updated (can rules be removed?)
 */
abstract contract Rules {
    
    //--- Storage

    // Effect Object (Changes to Reputation By Type)
    struct Effect {
        uint8 professional;
        uint8 social;
        uint8 personal;
    }

    // Rule Object
    struct Rule {
        string name;
        string uri;
        //eventId: 1, 
        uint256 eventId;
        //text: "The founder of the project violated the contract, but this did not lead to the loss or freezing of funds for investors.", //Description For Humans
        string text;    
        // condition: "Investor funds were not frozen nor lost.",
        string condition;  
        // effect: { //Reputation Change
        //     profiessional:-2,
        //     social: -4
        // }
        Effect[3] effects;
    }
    
    mapping(uint256 => Rule) private _rules;

    //--- Events

    /// Rule Added
    //  RuleAdded()

    /// Rule Removed
    // RuleRemoved()


    //--- Functions

    // constructor() { }

    //Add Rule
    /// ruleAdd()

    //Remove Rule
    //ruleRemove()


}

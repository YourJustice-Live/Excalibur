//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../interfaces/IRules.sol";

/**
 * Rules Contract
 * To Extend or Be Used by Jurisdictions
 * - [TODO] Hold & Serve Rules
 * - [TODO] Event: Rule Added / Removed / Updated (can rules be removed?)
 */
abstract contract Rules is IRules {
    
    //--- Storage

    // Rule Object
    struct Rule {
        // string name;
        // string uri;
        //eventId: 1, 
        uint256 eventId;
        //text: "The founder of the project violated the contract, but this did not lead to the loss or freezing of funds for investors.", //Description For Humans
        string text;     // is this needed?
        // condition: "Investor funds were not frozen nor lost.",
        string condition;  
        string uri;
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
        // int8 professional;
        // int8 social;
        // int8 personal;
        Effect environment;
        Effect personal;
        Effect social;
        Effect professional;
    }
    // Effect Structure
    struct Effect {
        // value: 5
        int8 value;
        // Direction: -
        bool direction;
        // Confidence/Strictness: [?]
    }

    mapping(uint256 => Rule) private _rules;


    //--- Functions

    // constructor() { }

    /// Add Rule
    //ruleAdd()

    /// Remove Rule
    //ruleRemove()


}

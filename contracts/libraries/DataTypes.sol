// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.4;

/**
 * @title DataTypes
 * @notice A standard library of generally used data types
 */
library DataTypes {

    //---

    /// NFT Identifiers
    struct Entity {
        address account;
        uint256 id;
        uint256 chain;
    }
    /// Rating Domains
    enum Domain {
        Environment,
        Personal,
        Community,
        Professional
    }
    /* DEPRECAED - Using Boolean
    /// Rating Categories
    enum Rating {
        Negative,   //0
        Positive    //1
    }
    */

    //--- Cases
    //Case Lifecycle
    // - Draft
    // - Filed / Open -- Confirmation/Discussion (Evidence, Witnesses, etc’)
    //X - Waiting for additional evidence
    // - Pending - Awaiting verdict
    // - Decision/Verdict (Judge, Jury, vote, etc’)
    // - Action / Remedy - Reward / Punishment / Compensation
    // - [Appeal
    // - [Enforcement]
    // - Closed
    // - Cancelled (Denied)
    enum CaseStage {
        Draft,
        Open,
        Verdict,
        Action,
        Appeal,
        Enforcment,
        Closed,
        Cancelled
    }

    //--- Actions

    // Semantic Action Entity
    struct Action {
        // id: 1,
        // uint256 id;  //Outside

        // name: "Breach of contract",  //Title
        string name;
     
        // text: "The founder of the project must comply with the terms of the contract with investors",  //Text Description
        string text;

        // entities:{
        //     //Describe an event
        //     affected: "investor",  //Plaintiff Role (Filing the case)
        //     subject: "founder",     //Accused Role
        //     action: "breach",
        //     object: "contract",
        // },
        SVO entities;
        
        // confirmation:{ //Confirmation Methods [WIP]
        //     //judge: true,
        //     ruling: "judge"|"jury"|"democracy",  //Decision Maker
        //     evidence: true, //Require Evidence
        //     witness: 1,  //Minimal number of witnesses
        // },
        Confirmation confirmation;

        // requirements:{
        //     witness: "Blockchain Expert"
        // }
        // string requirements;
        string uri; //Additional Info
    }

    struct SVO {    //Action's Core (System Role Mapping) (Immutable)
        //     subject: "founder",     //Accused Role
        string subject;
        //     action: "breach",
        string verb;
        //     object: "contract",
        string object;
        string tool; //[TBD]
        //     //Describe an event
        //     affected: "investors",  //Plaintiff Role (Filing the case)
        // string affected;    //[PONDER] Doest this really belong here? Is that part of the unique combination, or should this be an array, or an eadge?      //MOVED TO Rule
    }

    //--- Rules
    
    // Rule Object
    struct Rule {
        // uint256 about;   //About What (Token URI +? Contract Address)
        bytes32 about;      //About What (Action's GUID)      //TODO: Maybe Call This 'action'? 
        string affected;    // affected: "investors",  //Plaintiff Role (Filing the case)
        bool negation;      //0 - Commision  1 - Omission

        //text: "The founder of the project violated the contract, but this did not lead to the loss or freezing of funds for investors.", //Description For Humans
        // string text;
        // condition: "Investor funds were not frozen nor lost.",
        string uri;     //Test & Conditions

        // string condition;  

        // Effect[3] effects;   //Bad, Would have to push all of them every time...
        // Effects effects;     //Bad, difficult to work with can can't be sequenced.
        // effect: { //Reputation Change
        //     profiessional:-2,
        //     social: -4
        // }
        // mapping(int256 => int8) effects;     //effects[3] => -5      //Generic, Simple & Iterable
        // mapping(string => int8) effects;     //effects[professional] => -5      //Generic, Simple & Backward Compatible
        // Effect[] effects;                       //effects[] => {direction:true, value:5, name:'personal'}  // Generic, Iterable & Extendable/Flexible   //Externalized -- Mapping Shouldn't be in a Struct
        // consequence:[{ func:'repAdd', param:5 }],    //TBD? - Generic Consequences 
    }
    
    /* DEPRECATED
    // Effect Object (Changes to Reputation By Type)
    struct Effects {
        int8 environmental;
        int8 personal;
        int8 social;
        int8 professional;
        // Effect environment;
        // Effect personal;
        // Effect social;
        // Effect professional;
    }
    */
    
    // Effect Structure
    struct Effect {
        string name;
        // value: 5
        uint8 value;
        // Direction: -
        bool direction;
        // Confidence/Strictness: [?]
    }
    
    //Rule Confirmation Method
    struct Confirmation {
        //     ruling: "judge"|"jury"|"democracy",  //Decision Maker
        string ruling;
        //     evidence: true, //Require Evidence
        bool evidence;
        //     witness: 1,  //Minimal number of witnesses
        uint witness;
    }

    //--- Case Data

    //Rule Reference
    struct RuleRef {
        address jurisdiction;
        uint256 ruleId;
        // string affected;        //Affected Role. E.g. "investor"     //In Rule
        // Entity affected;
    }
    
    //-- Inputs
    
    //Rule Input Struct (Same as RuleRef)
    // struct InputRule {
    //     address jurisdiction;
    //     uint256 ruleId;
    //     string affected;
    // }

    //Role Input Struct
    struct InputRole {
        address account;
        string role;
    }
    //Decision (Verdict) Input
    struct InputDecision {
        uint256 ruleId;
        bool decision;
    }

    //Role Name Input Struct
    // struct InputRoleMapping {
    //     string role;
    //     string name;
    // }

}



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
        Enforcement,
        Closed,
        Cancelled
    }

    //--- Actions

    // Semantic Action Entity
    struct Action {
        string name;    // Title: "Breach of contract",  
        string text;    // text: "The founder of the project must comply with the terms of the contract with investors",  //Text Description
        string uri;     //Additional Info
        SVO entities;
        // Confirmation confirmation;          //REMOVED - Confirmations a part of the Rule, Not action
    }

    struct SVO {    //Action's Core (System Role Mapping) (Immutable)
        string subject;
        string verb;
        string object;
        string tool; //[TBD]
        //     //Describe an event
        //     affected: "investors",  //Plaintiff Role (Filing the case)
        // string affected;    //[PONDER] Doest this really belong here? Is that part of the unique combination, or should this be an array, or an eadge?      //MOVED TO Rule
    }

    //--- Rules
    
    // Rule Object
    struct Rule {
        bytes32 about;      //About What (Action's GUID)      //TODO: Maybe Call This 'actionGUID'? 
        string affected;    // affected: "investors",  //Plaintiff Role (Filing the case)
        bool negation;      //0 - Commision  1 - Omission
        string uri;         //Test & Conditions
        bool disabled;      //1 - Rule Disabled
    }
    
    // Effect Structure
    struct Effect {
        string name;
        uint8 value;    // value: 5
        bool direction; // Direction: -
        // Confidence/Strictness: [?]
    }
    
    //Rule Confirmation Method
    struct Confirmation {
        string ruling;
        // ruling: "judge"|"jury"|"democracy",  //Decision Maker
        bool evidence;
        // evidence: true, //Require Evidence
        uint witness;
        // witness: 1,  //Minimal number of witnesses
    }

    //--- Case Data

    //Rule Reference
    struct RuleRef {
        address jurisdiction;
        uint256 ruleId;
    }
    
    //-- Function Inputs Structs

    //Role Input Struct
    struct InputRole {
        address account;
        string role;
    }

    //Role Input Struct (for Token)
    struct InputRoleToken {
        uint256 tokenId;
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



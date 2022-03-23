//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import {DataTypes} from './libraries/DataTypes.sol';
import "./interfaces/IActionRepo.sol";
// import "./libraries/DataTypes.sol";
// import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";

/**
 * @title ActionRepo Contract -- Event Repository
 */
contract ActionRepo is IActionRepo, CommonYJ{

    //--- Storage
    //Arbitrary Contract Role 
    string public constant override symbol = "YJ_EVT";

    // Contract name
    string public name;
    // Contract symbol
    // string public symbol;
    //Jurisdiction
    address private _jurisdiction;
    //Rule(s)

    // Semantic Event Object
    struct Evt {
        // id: 1,
        uint256 id;
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
    struct Confirmation {
        //     ruling: "judge"|"jury"|"democracy",  //Decision Maker
        string ruling;
        //     evidence: true, //Require Evidence
        bool evidence;
        //     witness: 1,  //Minimal number of witnesses
        uint witness;
    }
    struct SVO {
        //     subject: "founder",     //Accused Role
        string subject;
        //     action: "breach",
        string verb;
        //     object: "contract",
        string object;
        string tool; //[TBD]
        //     //Describe an event
        //     affected: "investor",  //Plaintiff Role (Filing the case)
        string affected;
    }
    // Event Storage     (Unique)
    mapping(bytes32 => Evt) private _events;


    //-- Playground

    function ruleHashTest() public pure returns (bytes32){
        SVO memory testSVO;
        testSVO.subject = "xxx";
        // return bytes(abi.encode(testSVO.subject, testSVO.verb, testSVO.object, testSVO.affected));
        return bytes32(keccak256(abi.encode(testSVO.subject, testSVO.verb, testSVO.object, testSVO.affected)));
        // return  bytes(abi.encode("aa","bb", "cc", "cc", "cc"));
        // return  bytes(abi.encodePacked("aa","bb", "cc", "cc", "cc"));

    }

    function name2() public view returns (string memory){
        return name;
    }


    //--- Functions
    constructor(address hub) CommonYJ(hub) {
        name = "YourJustice Event Repo";
        // symbol = "YJ_EVT";
    }

    /// Generate a Unique Hash for Event
    function ruleHash(SVO calldata svo) private pure returns (bytes32){
        return bytes32(keccak256(abi.encode(svo.subject, svo.verb, svo.object, svo.tool, svo.affected)));
    }

    /// Register New Event
    function eventAdd(SVO memory svo) external {

        //...

        // emit ActionAdded(bytes32 indexed id, svo.subject, svo.verb, svo.object, svo.tool, svo.affected);
    }

    /// 

}
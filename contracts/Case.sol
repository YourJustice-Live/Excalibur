//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import {DataTypes} from './libraries/DataTypes.sol';
import "./interfaces/ICase.sol";
import "./libraries/DataTypes.sol";
import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";

/**
 * Case Contract
 */
contract Case is ICase, CommonYJ{


    //-- Rule Reference (in a Case)
    // {
    // 	ruleId: 1, 
    // 	jurisdictionId: 1
    // }

    //--- Storage

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;
    //Jurisdiction
    address private _jurisdiction;

    //Stage (Case Lifecycle)
    DataTypes.CaseStage public stage;

    //Rule(s)


    //--- Events


    //--- Functions
    
    // constructor(address jurisdiction) {
    constructor(string memory name_, string memory symbol_, address hub, address jurisdiction) CommonYJ(hub){
        //TODO: Validate HUB's Role
        //TODO: Validate Jurisdiction's Role
        require(jurisdiction != address(0), "INVALID JURISDICTION");

        _jurisdiction = jurisdiction;
        name = name_;
        symbol = symbol_;
    }

    /// TODO: Add Post (Type:Comment, Evidence, Decleration, etc')
    
    /**
     * Post - Owner can Post
     */
    // function post(uint256 token_id, string calldata uri) public {
    function post(address account, string calldata uri) public {
        //Event
        // emit Post(uri, token_id);
        // emit Post(uri, account);
    }
}
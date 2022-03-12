//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import {DataTypes} from './libraries/DataTypes.sol';
import "./libraries/DataTypes.sol";
import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";

/**
 * Case Contract
 */
contract Case is CommonYJ{

    //--- Storage
    mapping(uint256 => address) private _jurisdictions; //Track all Jurisdiction contracts


    //--- Events


    //--- Functions
    
    constructor() {
    }

}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import {DataTypes} from './libraries/DataTypes.sol';
import "./libraries/DataTypes.sol";
import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";


/**
 * Jurisdiction Contract
 * - [TODO] Mint Member NFTs (id => role)
 * - [TODO] Rules...
 */
contract Jurisdiction is Rules, CommonYJ {
    
    constructor(address hub) CommonYJ(hub){

    }

    /// Create a new role
    // roleAdd(){}

    /// Assign a role to address/tracked-AvatarNFT
    // roleAssign(){}
}
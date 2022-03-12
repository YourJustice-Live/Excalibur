//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

/**
 * Rules Contract
 * To Extend or Be Used by Jurisdictions
 * - [TODO] Hold & Serve Rules
 */
abstract contract Rules {
    
    struct Rule {
        string name;
        string uri;
    }

    mapping(uint256 => Rule) private _rules;

    constructor() {

    }

}

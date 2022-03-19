//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";  //Track Token Supply & Check 

// import {DataTypes} from './libraries/DataTypes.sol';
import "./libraries/DataTypes.sol";
import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";

import "./Case.sol";


/**
 * Jurisdiction Contract
 * - Mints Member NFTs
 * - [TODO] Rules...
 * - [TODO] Deploys Cases
 */
contract Jurisdiction is Rules, CommonYJ, ERC1155 {
    
    mapping(string => uint256) private _roles;     //NFTs as Roles

    // mapping(uint256 => address) private _cases;      // Mapping for Case Contracts

    // mapping(uint256 => string) private _rulesURI;      // Mapping for Rule/Tile URIs



    /*** EVENTS ***/

    /*** MODIFIERS ***/

    modifier roleExists(string calldata role) {
        require(_roles[role] != 0, "INEXISTENT_ROLE");
        _;
    }

    /*** FUNCTIONS ***/

    // constructor(address hub) CommonYJ(hub) ERC1155(string memory uri_){
    constructor(address hub) CommonYJ(hub) ERC1155(""){
        //Set Default Roles
        _roles["member"] = 1;
        _roles["witness"] = 2;
        _roles["judge"] = 3;
    }

    //-- Case Functions

    /// Make a new Case
    // function caseMake(data) public returns (address) {

    // }


    //-- Membership Functions

    /// Check if Role Exists
    function exists(string calldata role) public view virtual returns (bool) {
        return (_roles[role] != 0);
        
    }

    /// Join a role in current Jurisdiction
    function join(string calldata role) external roleExists(role) {
        uint256 tokenId = _roles[role];
        //Validate - Max of 1 Per Account
        require(balanceOf(_msgSender(), tokenId) == 0, "ALREADY_IN_ROLE");
        //Mint Units of Existing Token
        _mint(_msgSender(), tokenId, 1, "");
        //TODO: Event
    }

    /// Leave Role in current Jurisdiction
    function leave(string calldata role) external roleExists(role) {
        uint256 tokenId = _roles[role];
        //Validate - Max of 1 Per Account
        require(balanceOf(_msgSender(), tokenId) > 0, "NOT_IN_ROLE");
        //Burn
        _burn(_msgSender(), tokenId, 1);
        //TODO: Event
    }


}
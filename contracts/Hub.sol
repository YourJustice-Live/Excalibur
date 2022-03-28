//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// import {DataTypes} from './libraries/DataTypes.sol';
import "./libraries/DataTypes.sol";
import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";
import "./interfaces/IConfig.sol";


/**
 * Case Contract
 * - [TODO] Hold Public Avatar NFT Contract Address
 */
// contract Hub is CommonYJ, Ownable{
contract Hub is Ownable {

    // Arbitrary contract designation signature
    string public constant role = "YJHub";
    // string public constant symbol = "YJHub"; //TODO: Use THis

    //--- Storage
    // address internal _CONFIG;    //Configuration Contract
    IConfig private _CONFIG;  //Configuration Contract       //Try This

    mapping(uint256 => address) private _jurisdictions; //Track all Jurisdiction contracts


    //--- Events
    //TODO: Owner 
    //TODO: Config changed

    //--- Functions

    constructor(address config){
        //Set Protocol's Config Address
        _setConfig(config);
    }
    
    /// @dev Returns the address of the current owner.
    function owner() public view override returns (address) {
        return _CONFIG.owner();
        // address configContract = getConfig();
        // return IConfig(configContract).owner();
    }

    /// Get Configurations Contract Address
    function getConfig() public view returns (address) {
        // return _CONFIG;
        return address(_CONFIG);
    }

    /// Expose Configurations Set for Current Owner
    function setConfig(address config) public onlyOwner {
        _setConfig(config);
    }

    /// Set Configurations Contract Address
    function _setConfig(address config) internal {
        //Validate Contract's Designation
        require(keccak256(abi.encodePacked(IConfig(config).symbol())) == keccak256(abi.encodePacked("YJConfig")), "Invalid Config Contract");
        //Set
        _CONFIG = IConfig(config);
    }

}
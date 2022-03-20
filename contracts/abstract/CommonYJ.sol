//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
// import "../interfaces/IConfig.sol";
import "../interfaces/IHub.sol";

/**
 * Common Protocol Functions
 */
abstract contract CommonYJ is Ownable {
    
    //--- Storage

    // address internal _HUB;    //Hub Contract
    IHub internal _HUB;    //Hub Contract
    

    //--- Functions

    constructor(address hub){
        //Set Protocol's Config Address
        _setHub(hub);
    }

    /// Inherit owner from Protocol's config
    function owner() public view override returns (address) {
        return _HUB.owner();
    }

    /// Set Hub Contract
    function _setHub(address config) internal {
        //Validate Contract's Designation
        require(keccak256(abi.encodePacked(IHub(config).role())) == keccak256(abi.encodePacked("YJHub")), "Invalid Hub Contract");
        //Set
        _HUB = IHub(config);
    }

    /// Set Hub Contract
    function _getHub() internal view returns(address) {
        return address(_HUB);
    }
    
}

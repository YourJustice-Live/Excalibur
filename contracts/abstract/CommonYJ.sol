//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ICommonYJ.sol";
import "../interfaces/IHub.sol";
import "../libraries/DataTypes.sol";

/**
 * Common Protocol Functions
 */
abstract contract CommonYJ is ICommonYJ, Ownable {
    
    //--- Storage

    // address internal _HUB;    //Hub Contract
    IHub internal _HUB;    //Hub Contract
    

    //--- Functions

    constructor(address hub){
        //Set Protocol's Config Address
        _setHub(hub);
    }

    /// Inherit owner from Protocol's config
    function owner() public view override (ICommonYJ, Ownable) returns (address) {
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

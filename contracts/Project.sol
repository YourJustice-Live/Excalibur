//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/contracts/proxy/Proxy.sol";
import "./abstract/Proxy.sol";


/**
 * @title Project Over Reaction
 * @dev 
 */
abstract contract Project is Proxy {


    address _implementationAddress;

    /// Set Implementation
    function _implementationSet(address implementation_) internal {
        _implementationAddress = implementation_;
    }

    /**
     * @dev This is a function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    // function _implementation() internal view returns (address);
    // function _implementation() internal view override returns (address){
    //     return _implementationAddress;
    // }



    //-- Test Functions
    
    function showImplementation() internal view returns (address){
        return _implementationAddress;
    }

    
}

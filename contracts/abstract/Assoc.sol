//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "../interfaces/IAssoc.sol";

/**
 * @title Generic Associations (to other contracts)
 * @dev To Extend or Be Used by other contracts
 * - Hold, Update & Serve Associations
 */
abstract contract Assoc is IAssoc {
    
    //--- Storage
    
    //Contract Associations
    mapping(string => address) internal _assoc;
    
    //--- Functions

    /// Get Contract Association
    function getAssoc(string memory key) public view override returns(address) {
        //Validate
        require(_assoc[key] != address(0) , string(abi.encodePacked("Assoc:Faild to Get Assoc: ", key)));
        return _assoc[key];
    }

    /// Set Association
    function _setAssoc(string memory key, address contractAddr) internal {
        _assoc[key] = contractAddr;
        //Association Changed Event
        emit Assoc(key, contractAddr);
    }

}

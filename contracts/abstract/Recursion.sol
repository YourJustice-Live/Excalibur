//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "../interfaces/IRecursion.sol";
import "../libraries/DataTypes.sol";
import "../libraries/AddressArray.sol";
// import "../interfaces/IAssoc.sol";
// import "../abstract/AssocExt.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


/**
 * @title Core Contract Recursion Functionality
 * @dev Designed To Be Used by Jurisdictions
 */
contract Recursion is IRecursion, Initializable {

    //-- Storage

    //Parent Addresses
    using AddressArray for address[];
    address[] _parentAddrs;

    /// Check if a Contract Address is a an Immediate Parent of Current Contract
    function isParent(address contractAddr) public view override returns (bool) {
        //Flat Check
        for (uint256 i = 0; i < _parentAddrs.length; ++i) {
            if(_parentAddrs[i] == contractAddr) return true;
        }
        //Failed
        return false;
    }
    
    /// Check if a Contract Address is a Parent of Current Contract (Recursive)
    function isParentRec(address contractAddr) public view override returns (bool) {
        //Flat Check
        if(isParent(contractAddr)) return true;
        //Deep Check
        for (uint256 i = 0; i < _parentAddrs.length; ++i) {
            if(IRecursion(_parentAddrs[i]).isParent(contractAddr)) return true;
        }
        //Failed
        return false;
    }

    /// Register Parent
    function _parentAdd(address contractAddr) internal {
        require(!isParent(contractAddr), "Recursion:ALREADY_A_PARENT");
        //Add Parent
        _parentAddrs.push(contractAddr);
        //Parent Added Event
        emit ParentAdded(contractAddr);
    }

    /// Un-Register Parent
    function _parentRemove(address contractAddr) internal {
        require(isParent(contractAddr), "Recursion:NOT_A_PARENT");
        
        //Find & Remove Address
        // _arrRemove(_arrFind(contractAddr));
        _parentAddrs.removeItem(contractAddr);

        //Parent Removed Event
        emit ParentRemoved(contractAddr);
    }

}

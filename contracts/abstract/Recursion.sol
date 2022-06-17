//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "../interfaces/IRecursion.sol";
import "../interfaces/IAssoc.sol";
import "../libraries/DataTypes.sol";
import "../libraries/AddressArray.sol";
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

    /* DEPRECATE - Get Directly from Hub 
    /// Initializer
    function __Recursion_init(address hub) internal onlyInitializing {
    //Fetch Repo From Hub
        address openRepo = IAssoc(hub).getAssoc("repo");
        //Set Repo
        _setRepo(openRepo);
    }
    */

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


/* MOVED TO AddressArray LIBRARY
    /// Remove Address From Array
    function _arrRemove(uint index) internal {
        require(index < _parentAddrs.length, "Recursion:INDEX_OUT_OF_BOUNDS");
        _parentAddrs[index] = _parentAddrs[_parentAddrs.length-1];
        _parentAddrs.pop();
    }

    /// Find Address Index in Array
    function _arrFind(address value) internal view returns (uint256) {
        for (uint256 i = 0; i < _parentAddrs.length; ++i) {
            if(_parentAddrs[i] != value) return i;
        }
        revert("Recursion:ITEM_NOT_IN_ARRAY");
    }
*/


}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/**
 * @dev Basic Array Functionality
 */
library StringArray {

    /// Remove Item From Array
    function removeItem(string[] storage array, string memory targetAddress) internal {
        removeIndex(array, findIndex(array, targetAddress));
    }
    
    /// Remove Item From Array
    function removeIndex(string[] storage array, uint256 index) internal {
        require(index < array.length, "StringArray:INDEX_OUT_OF_BOUNDS");
        array[index] = array[array.length-1];
        array.pop();
    }

    /// Find Item Index in Array
    function findIndex(string[] storage array, string memory value) internal view returns (uint256) {
        for (uint256 i = 0; i < array.length; ++i) {
            // if(array[i] == value) return i;
            //String Match
            if( keccak256(abi.encodePacked(array[i])) == keccak256(abi.encodePacked(value)) ) return i;
        }
        revert("StringArray:ITEM_NOT_IN_ARRAY");
    }

}
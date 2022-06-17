// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/**
 * @dev Basic Array Functionality
 */
library BoolArray {

    /// Remove Item From Array
    function removeItem(bool[] storage array, bool targetAddress) internal {
        removeIndex(array, findIndex(array, targetAddress));
    }
    
    /// Remove Item From Array
    function removeIndex(bool[] storage array, uint256 index) internal {
        require(index < array.length, "BoolArray:INDEX_OUT_OF_BOUNDS");
        array[index] = array[array.length-1];
        array.pop();
    }

    /// Find Item Index in Array
    function findIndex(bool[] storage array, bool value) internal view returns (uint256) {
        for (uint256 i = 0; i < array.length; ++i) {
            if(array[i] == value) return i;
        }
        revert("BoolArray:ITEM_NOT_IN_ARRAY");
    }

}
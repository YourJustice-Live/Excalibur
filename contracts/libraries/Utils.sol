// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/**
 * @dev General Utility Functions
 */
library Utils {

    /// Match Two Strings
    function stringMatch(string memory str1, string memory str2) internal pure returns(bool){
        return (keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2)));
    }

    /// Translate string Roles to GUID hashes
    // function _stringToBytes32(string memory str) public pure returns (bytes32){
    //     require(bytes(str).length <= 32, "String is too long. Max 32 chars");
    //     return keccak256(abi.encode(str));
    // }

}
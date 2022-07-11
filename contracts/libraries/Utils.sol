// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

/**
 * @dev General Utility Functions
 * TODO: Make functions public and attach library as an external contract
 */
library Utils {

    using AddressUpgradeable for address;

    /// Match Two Strings
    function stringMatch(string memory str1, string memory str2) internal pure returns(bool){
        return (keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2)));
    }

    /// Translate string Roles to GUID hashes
    // function _stringToBytes32(string memory str) public pure returns (bytes32){
    //     require(bytes(str).length <= 32, "String is too long. Max 32 chars");
    //     return keccak256(abi.encode(str));
    // }

    /// Contract Type Logic
    function getAddressType(address account) internal view returns(string memory){
        
        // console.log("** _getType() Return: ", response);

        if (account.isContract() && account != address(this)) {

            // console.log("THIS IS A Contract:", account);

            try IToken(account).symbol() returns (string memory response) {

                // console.log("* * * Contract Symbol:", account, response);

                //Contract's Symbol
                return response;
            } catch {
                //Unrecognized Contract
                return "CONTRACT";
            }
        }
        // console.log("THIS IS NOT A Contract:", account);
        //Not a contract
        return "";
    }

}

/// Generic Interface used to get Token's Symbol
interface IToken {
    /// Arbitrary contract symbol
    function symbol() external view returns (string memory);
}

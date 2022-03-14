// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IHub {
    /// Arbitrary contract designation signature
    function role() external view returns (string memory);
    /// Get Owner
    function owner() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract MultiCall {

    error MultiCallFailed(address target, bytes payload, uint etherAmount);

    /// Source: https://daltyboy11.github.io/batch-ethereum-queries-with-multicall/
    /// 
    /// @notice Perform multiple calls one after another. Call `i` is sent
    /// to address `targets[i]` with calldata `payloads[i]` and ether amount
    /// `etherAmounts[i]`. The transaction fails if any call reverts.
    /// 
    /// @param targets addresses to call
    /// @param payloads calldata for each call
    /// @param etherAmounts amount of ether to send with each call
    /// @return results array where `results[i]` is the result of call `i`
    function multiCall(
        address payable[] memory targets,
        bytes[] memory payloads,
        uint[] memory etherAmounts
    ) public payable returns (bytes[] memory results) {
        uint n = targets.length;
        require(payloads.length == n, "Input arrays must be the same length");
        require(etherAmounts.length == n, "Input arrays must be the same length");

        results = new bytes[](payloads.length);

        for (uint i; i < n; i++) {
            (bool ok, bytes memory res) = targets[i].call{value: etherAmounts[i]}(payloads[i]);
            if (!ok) {
                revert MultiCallFailed(targets[i], payloads[i], etherAmounts[i]);
            }
            results[i] = res;
        }
    }
}
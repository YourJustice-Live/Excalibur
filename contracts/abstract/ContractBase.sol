//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../interfaces/IContractBase.sol";

/**
 * @title Basic Contract Funtionality (For all contracts)
 * @dev To Extend by any other contract
 */
abstract contract ContractBase is IContractBase {
    
    //--- Storage

    //Contract URI
    string internal _contract_uri;

    //--- Functions

    /**
     * @dev Contract URI
     *  https://docs.opensea.io/docs/contract-level-metadata
     */
    function contractURI() public view override returns (string memory) {
        return _contract_uri;
    }
    
    /// Set Contract URI
    function _setContractURI(string calldata contract_uri) internal {
        //Set
        _contract_uri = contract_uri;
        //Contract URI Changed Event
        emit ContractURI(contract_uri);
    }

}
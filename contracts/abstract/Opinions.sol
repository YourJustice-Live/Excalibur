//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "../libraries/DataTypes.sol";
import "../interfaces/IOpinions.sol";

/**
 * @title Rating for Contracts & Tokens
 * @dev Designed To Be Used by Jurisdictions
 * - Hold & Update Multidimentional Rating Data about Other On-Chain Entities
 */
abstract contract Opinions is IOpinions {
    
    /// Opinion Tracking - Positive & Negative Opinion Tracking Per Domain (Environmantal, Personal, Community, Professional) For Tokens in Contracts
    /// [Chain][Contract][Token] => [Domain][Rating] => uint     //W/Crosschain Support
    mapping(uint256 => mapping(address => mapping(uint256 => mapping(string => mapping(bool => uint256))))) internal _rep;

    /// Fetch Opinion (Crosschain)
    function getRepForDomain(uint256 chainId, address contractAddr, uint256 tokenId, string calldata domain, bool rating) public view override returns (uint256){
        return _rep[chainId][contractAddr][tokenId][domain][rating];
    }

    /// Fetch Opinion (Current Chain)
    function getRepForDomain(address contractAddr, uint256 tokenId, string calldata domain, bool rating) public view override returns (uint256){
        return _rep[block.chainid][contractAddr][tokenId][domain][rating];
    }

    /// Fetch Opinion (Self)
    function getRepForDomain(uint256 tokenId, string calldata domain, bool rating) public view override returns (uint256){
        return _rep[block.chainid][address(this)][tokenId][domain][rating];
    }

    /// Add Opinion (Positive or Negative)
    function _repAdd(address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 score) internal {
        //Update Opinion
        _repAdd(block.chainid, contractAddr, tokenId, domain, rating, score);
    }

    /// Add Opinion (Positive or Negative)
    function _repAdd(uint256 chainId, address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 score) internal {
        //Update Opinion
        _rep[chainId][contractAddr][tokenId][domain][rating] += score;
        //Opinion Change Event
        emit OpinionChange(chainId, contractAddr, tokenId, domain, rating, score);
    }
}

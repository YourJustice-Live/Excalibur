//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "../interfaces/IAssocRepo.sol";

/**
 * @title Open Association Retention
 * @dev Association Repository -- Retains Association Data for Other Contracts
 * Version 1.0
 * - Save & Return Associations
 * - Owned by Requesting Address
 */
contract AssocRepo is IAssocRepo, Context, ERC165 {

    //--- Storage
    
    //Arbitrary Contract Name & Symbol 
    string public constant symbol = "ASSOC";
    string public constant name = "Open Association Repository";
    
    //Associations by Contract Address
    mapping(address => mapping(string => address)) internal _assoc;
    
    //--- Functions

    // constructor() { }

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAssocRepo).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /** 
     * Set Association
     * @dev Set association to another contract
     */
    function set(string memory key, address destinationContract) external override {
        _assoc[_msgSender()][key] = destinationContract;
        //Association Changed Event
        emit Assoc(_msgSender(), key, destinationContract);
    }

    /** 
     * Get Association
     * @dev Get association to another contract
     */
    function get(string memory key) external view override returns(address) {
        address originContract = _msgSender();
        //Validate
        // require(_assoc[originContract][key] != address(0) , string(abi.encodePacked("Assoc:Faild to Get Assoc: ", key)));
        return _assoc[originContract][key];
    }

    /** 
     * Set Contract Association 
     * @dev Set association of a specified contract to another contract
     */
    function getOf(address originContract, string memory key) external view override returns(address) {
        //Validate
        require(_assoc[originContract][key] != address(0) , string(abi.encodePacked("Faild to Find Assoc: ", key)));
        return _assoc[originContract][key];
    }

}
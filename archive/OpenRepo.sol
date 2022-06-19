//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./interfaces/IOpenRepo.sol";

/**
 * @title Generic Data Repository
 * @dev Retains Data for Other Contracts
 * Version 1.0
 * - Save & Return Associations
 * - Owned by Requesting Address
 * [TODO] Support Multiple Similar Relations
 */
contract OpenRepo is 
        IOpenRepo, 
        Context, 
        ERC165 {

    //--- Storage
    
    //Arbitrary Contract Name & Symbol 
    string public constant symbol = "OPENREPO";
    string public constant name = "Open Edge Repository";
    
    //Associations by Contract Address
    mapping(address => mapping(string => address)) internal _addresses;
    
    //--- Functions

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IOpenRepo).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /** 
     * Set Address
     */
    function setAddress(string memory key, address value) external override {
        _addresses[_msgSender()][key] = value;
        //Association Changed Event
        emit AddressSet(_msgSender(), key, value);
    }

    /** 
     * Get Address
     */
    function getAddress(string memory key) external view override returns(address) {
        address originContract = _msgSender();
        //Validate
        // require(_addresses[originContract][key] != address(0) , string(abi.encodePacked("Assoc:Faild to Get Assoc: ", key)));
        return _addresses[originContract][key];
    }

    /** 
     * Get Address By Origin Owner Node
     */
    function getAddressOf(address originContract, string memory key) external view override returns(address) {
        //Validate
        require(_addresses[originContract][key] != address(0) , string(abi.encodePacked("Faild to Find Address: ", key)));
        return _addresses[originContract][key];
    }


}
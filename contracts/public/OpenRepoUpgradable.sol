//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../interfaces/IOpenRepo.sol";
import "../abstract/ContractBase.sol";


/**
 * @title Generic Data Repository
 * @dev Retains Data for Other Contracts
 * Version 1.0.1
 * - Save & Return Associations
 * - Owned by Requesting Address
 * [TODO] Support Multiple Similar Relations
 */
contract OpenRepoUpgradable is 
        IOpenRepo, 
        Initializable,
        // Context, 
        OwnableUpgradeable,
        UUPSUpgradeable,
        ERC165,
        ContractBase {

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

    /// Initializer
    function initialize () public initializer {
        //Initializers
        __Ownable_init();
        //Set Contract URI
        // _setContractURI(uri_);
    }

    /// Upgrade Permissions
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override { }

    /// Set Address
    function setAddress(string memory key, address destinationContract) external override {
        //Validate
        require(_addresses[_msgSender()][key] != destinationContract , "No Change");
        //Set
        _addresses[_msgSender()][key] = destinationContract;
        //Association Changed Event
        emit AddressSet(_msgSender(), key, destinationContract);
    }

    /// Get Address
    function getAddress(string memory key) external view override returns(address) {
        address originContract = _msgSender();
        //Validate
        // require(_addresses[originContract][key] != address(0) , string(abi.encodePacked("Assoc:Faild to Get Assoc: ", key)));
        return _addresses[originContract][key];
    }

    /// Get Address By Origin Owner Node
    function getAddressOf(address originContract, string memory key) external view override returns(address) {
        //Validate
        require(_addresses[originContract][key] != address(0) , string(abi.encodePacked("Faild to Find Address: ", key)));
        return _addresses[originContract][key];
    }

}
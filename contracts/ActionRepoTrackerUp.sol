//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/IActionRepo.sol";
import "./abstract/ProtocolEntityUpgradable.sol";
import "./abstract/ERC1155GUIDTrackerUp.sol";


/**
 * @title History Retention
 * @dev Event Repository -- Retains Unique Events and Their Apperance Throught History
 * 2D - Compound GUID + Additional Data & URI
 * [TBD] 3D - Individual Instances of Action (Reactions) as NFTs + Event Details (Time, Reaction no.,  etc')
 */
contract ActionRepoTrackerUp is 
        IActionRepo, 
        Initializable,
        ProtocolEntityUpgradable, 
        UUPSUpgradeable,
        ERC1155GUIDTrackerUp {

    //--- Storage
    using AddressUpgradeable for address;

    //Arbitrary Contract Name & Symbol 
    string public constant override symbol = "HISTORY";
    string public constant name = "Semantic Action Repository";

    // Event Storage     (Unique Concepts)
    mapping(bytes32 => DataTypes.SVO) internal _actions; //Primary Data
    // Additional Action Metadata
    mapping(uint256 => string) internal _tokenURI;

    //--- Functions

    /// Initializer
    function initialize (address hub) public initializer override {
        //Initializers
        __UUPSUpgradeable_init();
        __ProtocolEntity_init(hub);
        __setTargetContract( repo().addressGetOf(address(_HUB), "SBT") );
        //Set Contract URI
        // _setContractURI(uri_);
    }

    /// Upgrade Permissions
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override { }

    /// ERC165 - Supported Interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IActionRepo).interfaceId 
            || super.supportsInterface(interfaceId);
    }

    /// TODO: Check if Action Exists
    // function actionHas() external returns (bool) {

    // }
    
    /// Generate a Unique Hash for Event
    function actionHash(DataTypes.SVO memory svo) public pure override returns (bytes32) {
        return bytes32(keccak256(abi.encode(svo.subject, svo.verb, svo.object, svo.tool)));
    }

    /// Register New Action
    function actionAdd(DataTypes.SVO memory svo, string memory uri) public override returns (bytes32) {
        //Validate (Maybe...)
        // require(!_msgSender().isContract(), "No-Bots");

        //Store Additional Details
        bytes32 guid = _actionAdd(svo);
        //Set Additional Data
        _actionSetURI(guid, uri);
        //return GUID
        return guid;
    }

    /// Register New Actions in a Batch
    function actionAddBatch(DataTypes.SVO[] memory svos, string[] memory uris) external override returns (bytes32[] memory) {
        require(svos.length == uris.length, "Length Mismatch");
        bytes32[] memory guids;
        for (uint256 i = 0; i < svos.length; ++i) {
            guids[i] = actionAdd(svos[i], uris[i]);
        }
        return guids;
    }

    /// Update URI for Action
    function actionSetURI(bytes32 guid, string memory uri) external override {
        _actionSetURI(guid, uri);
    }

    /// Set Action's Metadata URI
    function _actionSetURI(bytes32 guid, string memory uri) internal {
        _tokenURI[_GUIDToId(guid)] = uri;
        emit ActionURI(guid, uri);
    }
    
    /// Store New Action
    function _actionAdd(DataTypes.SVO memory svo) internal returns (bytes32) {
        //Unique Token GUID
        bytes32 guid = actionHash(svo);
        //Validate 
        require(_GUIDExists(guid) == false, "Action Already Exists");
        //Create Action
        uint256 id = _GUIDMake(guid);
        //Map Additional Data
        _actions[guid] = svo;
        //Event
        emit ActionAdded(id, guid, svo.subject, svo.verb, svo.object, svo.tool);
        //Return GUID
        return guid;
    }

    /// Get Action by GUID
    function actionGet(bytes32 guid) public view override returns (DataTypes.SVO memory){
        return _actionGet(guid);
    }

    /// Get Action by GUID
    function _actionGet(bytes32 guid) internal view GUIDExists(guid) returns (DataTypes.SVO memory){
        return _actions[guid];
    }

    /// Get Action's URI
    function actionGetURI(bytes32 guid) public view override returns (string memory){
        return _tokenURI[_GUIDToId(guid)];
    }

}
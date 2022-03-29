//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import {DataTypes} from './libraries/DataTypes.sol';
import "./interfaces/IActionRepo.sol";
import "./libraries/DataTypes.sol";
// import "./abstract/Rules.sol";
import "./abstract/CommonYJ.sol";
import "./abstract/ERC1155GUID.sol";


/**
 * @title History Retention
 * @dev Event Repository -- Reains Unique Events and Their Apperance Throught History
 * 2D - Compound GUID + Additional Data & URI
 * [TBD] 3D - Individual Instances of Action (Incidents) as NFTs + Event Details (Time, Case no.,  etc')
 */
contract ActionRepo is IActionRepo, CommonYJ, ERC1155GUID {

    //--- Storage
    //Arbitrary Contract Role 
    string public constant override symbol = "HISTORY";

    // Contract name
    string public name;
    // Contract symbol
    // string public symbol;
    //Jurisdiction
    address private _jurisdiction;
    //Rule(s)

    // Event Storage     (Unique Concepts)
    // mapping(bytes32 => Action) internal _actions;
    mapping(uint256 => DataTypes.Action) internal _actions;
    

    // mapping(uint256 => DataTypes.SVO) internal _actionsTest;
    mapping(bytes32 => DataTypes.SVO) public actionsTest;
    mapping(uint256 => DataTypes.RoleData) internal _RoleData;

    mapping(uint256 => string) internal _uri;



    //--- Functions

    constructor(address hub) CommonYJ(hub) ERC1155GUID(""){
        name = "YourJustice Event Repo";
        // symbol = "ACTIONS";
    }

    /// Generate a Unique Hash for Event
    function _actionHash(DataTypes.SVO memory svo) internal pure returns (bytes32) {
        return bytes32(keccak256(abi.encode(svo.subject, svo.verb, svo.object, svo.tool, svo.affected)));
    }

    /// Register New Action
    function actionAdd(DataTypes.SVO memory svo) external returns (bytes32) {
        //TODO: Validate

        console.log("actionAdd");

        //Store Additional Details
        return _actionAdd(svo);
    }

    /// Set Action's Metadata URI
    function actionSetURI(bytes32 guid, string memory uri) external override {
        _uri[_GUIDToId(guid)] = uri;
    }

    /// Set Action's Data
    function actionSetData(bytes32 guid, DataTypes.RoleData memory data) external override {
        _RoleData[_GUIDToId(guid)] = data;
    }

    /// Store New Action
    function _actionAdd(DataTypes.SVO memory svo) internal returns (bytes32) {
        console.log("_actionAdd");

        //Unique Token GUID
        bytes32 guid = _actionHash(svo);
        
        // bytes32ToString
        console.log("guid: ");
        console.logBytes32(guid);


        //TODO: Validate 
        require(_GUIDExists(guid) == false, "Action Already Exists");
        //Create Action
        uint256 id = _GUIDMake(guid);

        console.log("New Action id: ", id);

        console.log("New Action SVO: ", svo.subject);

        // //Map Additional Data
        actionsTest[guid] = svo;

        // //Event
        emit ActionAdded(guid, svo.subject, svo.verb, svo.object, svo.tool, svo.affected);

        // //Return GUID
        return guid;
    }

    /// Get Action by GUID
    function actionGet(bytes32 guid) public view override returns (DataTypes.SVO memory){
        return _actionGet(guid);
    }

    /// Get Action by GUID
    // function _actionGet(bytes32 guid) internal view GUIDExists(guid) returns (DataTypes.SVO memory){
    function _actionGet(bytes32 guid) internal view returns (DataTypes.SVO memory){
        // return actionsTest[_GUIDToId(guid)];
        return actionsTest[guid];
    }




    /* [TBD] - would need to track role IDs
    
    /// Create a new Role
    function roleCreate(string calldata role) public {
        
        _roleCreate(role);
    }
    */

    //-- Helpers
    /*
    function bytes32ToString(bytes32 source) internal pure returns (string memory result) {
        uint8 length = 0;
        while (source[length] != 0 && length < 32) {
            length++;
        }
        assembly {
            result := mload(0x40)
            // new "memory end" including padding (the string isn't larger than 32 bytes)
            mstore(0x40, add(result, 0x40))
            // store length in memory
            mstore(result, length)
            // write actual data
            mstore(add(result, 0x20), source)
        }
    }
    */
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }


    //-- Playground

    function ruleHashTest() public view returns ( bytes32){
        DataTypes.SVO memory testSVO;
        testSVO.subject = "xxx";

        //Unique Token GUID
        bytes32 unique = _actionHash(testSVO);



        // bytes32ToString
        console.log("unique");
        console.logBytes32(unique);

        // string memory uniqueSTR = bytes32ToString(unique);  //�♫����uho�Y����k%{o��¶�<K���↕i�&
        // string memory uniqueSTR = string(abi.encodePacked(unique));  //�♫����uho�Y����k%{o��¶�<K���↕i�&
        // console.log("uniqueSTR");
        // console.logString(uniqueSTR);
        // return uniqueSTR;

        // return unique;
        // return bytes(abi.encode(testSVO.subject, testSVO.verb, testSVO.object, testSVO.affected));
        return bytes32(keccak256(abi.encode(testSVO.subject, testSVO.verb, testSVO.object, testSVO.affected)));
        // return  bytes(abi.encode("aa","bb", "cc", "cc", "cc"));
        // return  bytes(abi.encodePacked("aa","bb", "cc", "cc", "cc"));

    }


    function testBytes(bytes memory foo) public view returns (bytes memory){
        console.log("Bytes:");
        console.logBytes(foo);
        return foo;
    }

    function name2() public view returns (string memory){
        return name;
    }



}
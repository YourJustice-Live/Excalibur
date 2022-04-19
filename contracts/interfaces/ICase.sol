// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface ICase {
    
    //-- Functions

    /// Initialize
    // function initialize(string memory name_, string memory symbol_, address hub) external ;
    // function initialize(string memory name_, string memory symbol_, address hub, DataTypes.RuleRef[] memory addRules) external ;
    function initialize(string memory name_, string memory symbol_, address hub, DataTypes.RuleRef[] memory addRules, DataTypes.InputRole[] memory assignRoles) external ;

    /// Contract URI
    function contractURI() external view returns (string memory);

    /// Assign Someone to a Role
    function roleAssign(address account, string calldata role) external;

    // RoleRequest()

    // RoleOffered()

    // RoleAccepted()

    // RoleAssigned()

    /// File the Case (Validate & Open Discussion)  --> Open
    function stageFile() external;

    /// Case Wait For Verdict  --> Pending
    function stageWaitForVerdict() external;

    /// Case Stage: Place Verdict  --> Closed
    function stageVerdict(string calldata uri) external;

    /// Add Post 
    // function post(string calldata entRole, string calldata postRole, string calldata uri) external;
    function post(string calldata entRole, string calldata uri) external;

    //--- Events

    /// Case Stage Change
    event Stage(DataTypes.CaseStage stage);

    /// Post Verdict
    event Verdict(string uri, address account);

    /// Case Cancelation Data
    event Cancelled(string uri, address account);

    /// General Post / Evidence, etc'
    // event Post(address indexed account, string entRole, string postRole, string uri);        //postRole Moved to uri
    event Post(address indexed account, string entRole, string uri);

    /// Rule Reference Added
    event RuleAdded(address jurisdiction, uint256 ruleId);

}

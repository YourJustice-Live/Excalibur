// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "../libraries/DataTypes.sol";

interface IJurisdiction {
    
    //--- Functions

    /// Set Contract URI
    function setContractURI(string calldata contract_uri) external;

    /// Initialize
    function initialize(address hub, string calldata name_, string calldata uri_) external;

    /// Symbol As Arbitrary contract designation signature
    function symbol() external view returns (string memory);

    /// Disable Case
    function caseDisable(address caseContract) external;

    /// Check if Case is Owned by This Contract (& Active)
    function caseHas(address caseContract) external view returns (bool);

    /// Join jurisdiction as member
    function join() external returns (uint256);

    /// Leave member role in current jurisdiction
    function leave() external returns (uint256);

    /// Assign Someone to a Role
    function roleAssign(address account, string calldata role) external;

    /// Assign Tethered Token to a Role
    function roleAssignToToken(uint256 toToken, string memory role) external;

    /// Remove Someone Else from a Role
    function roleRemove(address account, string calldata role) external;

    /// Remove Tethered Token from a Role
    function roleRemoveFromToken(uint256 ownerToken, string memory role) external;

    /// Change Role Wrapper (Add & Remove)
    function roleChange(address account, string memory roleOld, string memory roleNew) external;

    /// Create a new Role
    // function roleCreate(address account, string calldata role) external;

    /// Make a new Case
    // function caseMake(
    //     string calldata name_, 
    //     string calldata uri_, 
    //     DataTypes.RuleRef[] calldata addRules, 
    //     DataTypes.InputRoleToken[] calldata assignRoles, 
    //     PostInput[] calldata posts
    // ) external returns (address);
    // function caseMakeOpen(
    //     string calldata name_, 
    //     string calldata uri_, 
    //     DataTypes.RuleRef[] calldata addRules, 
    //     DataTypes.InputRoleToken[] calldata assignRoles, 
    //     PostInput[] calldata posts
    // ) external returns (address);
    
    /// Add Reputation (Positive or Negative)
    function repAdd(address contractAddr, uint256 tokenId, string calldata domain, bool rating, uint8 amount) external;

    //-- Rule Func.

    /// Create New Rule
    // function ruleAdd(DataTypes.Rule memory rule, DataTypes.Confirmation memory confirmation) external returns (uint256);
    function ruleAdd(DataTypes.Rule memory rule, DataTypes.Confirmation memory confirmation, DataTypes.Effect[] memory effects) external returns (uint256);

    /// Update Rule
    // function ruleUpdate(uint256 id, DataTypes.Rule memory rule) external;
    function ruleUpdate(uint256 id, DataTypes.Rule memory rule, DataTypes.Effect[] memory effects) external;
    
    /// Update Rule's Confirmation Data
    function ruleConfirmationUpdate(uint256 id, DataTypes.Confirmation memory confirmation) external;
        
    /// Set Metadata URI For Role
    function setRoleURI(string memory role, string memory _tokenURI) external;


    //--- Events

    /// New Case Created
    event CaseCreated(uint256 indexed id, address contractAddress);    
}

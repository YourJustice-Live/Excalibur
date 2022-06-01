// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// import "../ERC1155D.sol";
// import "../ERC1155Tracker.sol";
import "../CaseUpgradable.sol";
import "../libraries/DataTypes.sol";


/**
 * @title ERC1155Mock
 * This mock just publicizes internal functions for testing purposes
 */
contract CaseMock is CaseUpgradable {

    constructor(
        address hub,
        DataTypes.RuleRef[] memory addRules,
        DataTypes.InputRole[] memory assignRoles,
        address container
        ) {

        // _setTargetContract(targetContract);

        // initialize(
        //     hub, 
        //     "Mock Case", 
        //     "MOCKCASE_URI", 
        //     addRules,
        //     assignRoles,
        //     container
        // );
    }

    function mint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public {
        _mint(to, id, value, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public {
        _mintBatch(to, ids, values, data);
    }

    function burn(
        address owner,
        uint256 id,
        uint256 value
    ) public {
        _burn(owner, id, value);
    }

    function burnBatch(
        address owner,
        uint256[] memory ids,
        uint256[] memory values
    ) public {
        _burnBatch(owner, ids, values);
    }
}

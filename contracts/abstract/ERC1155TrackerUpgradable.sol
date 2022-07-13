// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../interfaces/IERC1155Tracker.sol";
import "../interfaces/ISoul.sol";
import "../libraries/AddressArray.sol";
import "../libraries/UintArray.sol";

/**
 * @title ERC1155 Tracker Upgradable
 * @dev This contract is to be attached to an ERC721 (SoulBoundToken)  contract and mapped to its tokens
 */
abstract contract ERC1155TrackerUpgradable is 
        Initializable, 
        ContextUpgradeable, 
        ERC165Upgradeable, 
        IERC1155Tracker {

    using AddressUpgradeable for address;
    using AddressArray for address[];
    using UintArray for uint256[];
    
    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Manage Balances by External Token ID
    mapping(uint256 => mapping(uint256 => uint256)) private _balances;

    //Index Unique Members for each TokenId
    mapping(uint256 => uint256[]) internal _uniqueMemberTokens;

    // Target Contract (External Source)
    address _targetContract;

    /// Get Target Contract
    function getTargetContract() public view virtual override returns (address) {
        return _targetContract;
    }

    /// Set Target Contract
    function __setTargetContract(address targetContract) internal virtual {
        //Validate IERC721
        // require(IERC165(targetContract).supportsInterface(type(IERC721).interfaceId), "Target Expected to Support IERC721");
        require(IERC165(targetContract).supportsInterface(type(ISoul).interfaceId), "Target contract expected to support ISoul");
        _targetContract = targetContract;
        // _targetContract = IERC721(targetContract);
    }

    /// Get a Token ID Based on account address (Throws)
    function getExtTokenId(address account) public view returns(uint256) {
        //Validate Input
        require(account != _targetContract, "ERC1155Tracker: source contract address is not a valid account");
        //Get
        uint256 ownerToken = _getExtTokenId(account);
        //Validate Output
        require(ownerToken != 0, "ERC1155Tracker: requested account not found on source contract");
        //Return
        return ownerToken;
    }

    /// Get a Token ID Based on account address
    function _getExtTokenId(address account) internal view returns (uint256) {
        // require(account != address(0), "ERC1155Tracker: address zero is not a valid account");       //Redundant 
        require(account != _targetContract, "ERC1155Tracker: source contract address is not a valid account");
        //Run function on destination contract
        // return ISoul(_targetContract).tokenByAddress(account);
        uint256 ownerToken = ISoul(_targetContract).tokenByAddress(account);
        //Validate
        // require(ownerToken != 0, "ERC1155Tracker: account not found on source contract");
        //Return
        return ownerToken;
    }

    /// Unique Members Count (w/Token)
    function uniqueMembers(uint256 id) public view override returns (uint256[] memory) {
        return _uniqueMemberTokens[id];
    }

    /// Unique Members Count (w/Token)
    function uniqueMembersCount(uint256 id) public view override returns (uint256) {
        return uniqueMembers(id).length;
    }

    /// Get Owner Account By Owner Token
    function _getAccount(uint256 extTokenId) internal view returns (address) {
        return IERC721(_targetContract).ownerOf(extTokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            // interfaceId == type(IERC1155Upgradeable).interfaceId ||
            // interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
     /* REMOVED - Unecessary
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }
    */

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        // return _balances[id][account];
        // return _balances[id][getExtTokenId(account)];
        return balanceOfToken(getExtTokenId(account), id);
    }

    /**
     * Check balance by External Token ID
     */
    function balanceOfToken(uint256 extTokenId, uint256 id) public view override returns (uint256) {
        return _balances[id][extTokenId];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     * /
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     * /
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     * /
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 ownerFrom = _getExtTokenId(from);
        uint256 ownerTo = _getExtTokenId(to);

        // uint256 fromBalance = _balances[id][from];
        uint256 fromBalance = _balances[id][ownerFrom];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            // _balances[id][from] = fromBalance - amount;
            _balances[id][ownerFrom] = fromBalance - amount;
        }
        // _balances[id][to] += amount;
        _balances[id][ownerTo] += amount;

        emit TransferSingle(operator, from, to, id, amount);
        emit TransferByToken(operator, ownerFrom, ownerTo, id, amount);

        // _afterTokenTransfer(operator, from, to, ids, amounts, data);

        // _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     * /
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 ownerFrom = _getExtTokenId(from);
        uint256 ownerTo = _getExtTokenId(to);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            // uint256 fromBalance = _balances[id][from];
            uint256 fromBalance = _balances[id][ownerFrom];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                // _balances[id][from] = fromBalance - amount;
                _balances[id][ownerFrom] = fromBalance - amount;
            }
            // _balances[id][to] += amount;
            _balances[id][ownerTo] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);
        emit TransferBatchByToken(operator, ownerFrom, ownerTo, ids, amounts);

        // _afterTokenTransfer(operator, from, to, ids, amounts, data);

        // _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
     /* REMOVED - Unecessary
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }
    */

    /// Mint for Address Owner
    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        _mintActual(to, getExtTokenId(to), id, amount, data);
    }
    
    /// Mint for External Token Owner
    function _mintForToken(uint256 toToken, uint256 id, uint256 amount, bytes memory data) internal virtual {
        _mintActual(_getAccount(toToken), toToken, id, amount, data);
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mintActual(
        address to,
        uint256 toToken,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);
        _beforeTokenTransferTracker(operator, 0, toToken, ids, amounts, data);

        // _balances[id][to] += amount;
        _balances[id][toToken] += amount;
        
        emit TransferSingle(operator, address(0), to, id, amount);
        emit TransferByToken(operator, 0, toToken, id, amount);

        // _afterTokenTransfer(operator, address(0), to, ids, amounts, data);
        _afterTokenTransferTracker(operator, 0, toToken, ids, amounts, data);

        // _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();
        uint256 toToken = getExtTokenId(to);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);
        _beforeTokenTransferTracker(operator, 0, toToken, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            // _balances[ids[i]][to] += amounts[i];
            _balances[ids[i]][toToken] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);
        emit TransferBatchByToken(operator, 0, toToken, ids, amounts);

        // _afterTokenTransfer(operator, address(0), to, ids, amounts, data);
        _afterTokenTransferTracker(operator, 0, toToken, ids, amounts, data);

        // _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /// Burn Token for Account
    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        _burnActual(from, getExtTokenId(from), id, amount);
    }

    /// Burn Token by External Token Owner
    function _burnForToken(uint256 fromToken, uint256 id, uint256 amount) internal virtual {
        _burnActual(_getAccount(fromToken), fromToken, id, amount);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burnActual(
        address from,
        uint256 fromToken,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");
        _beforeTokenTransferTracker(operator, fromToken, 0, ids, amounts, "");

        // uint256 fromBalance = _balances[id][from];
        uint256 fromBalance = _balances[id][fromToken];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            // _balances[id][from] = fromBalance - amount;
            _balances[id][fromToken] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
        emit TransferByToken(operator, fromToken, 0, id, amount);

        // _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
        _afterTokenTransferTracker(operator, fromToken, 0, ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();
        uint256 fromToken = getExtTokenId(from);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");
        _beforeTokenTransferTracker(operator, fromToken, 0, ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            // uint256 fromBalance = _balances[id][from];
            uint256 fromBalance = _balances[id][fromToken];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                // _balances[id][from] = fromBalance - amount;
                _balances[id][fromToken] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
        emit TransferBatchByToken(operator, fromToken, 0, ids, amounts);

        // _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
        _afterTokenTransferTracker(operator, fromToken, 0, ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /// An 'onwer' Address (Not Address 0 and not Target Contract)
    function _isOwnerAddress(address addr) internal view returns(bool){
        return (addr != address(0) && addr != _targetContract);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}
    
    /// @dev Hook that is called before any token transfer
    function _beforeTokenTransferTracker(
        address operator,
        uint256 fromToken,
        uint256 toToken,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        if(toToken != 0){
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                //If New Owner 
                if(_balances[id][toToken] == 0){
                    //Register New Owner
                    _uniqueMemberTokens[id].push(toToken);
                }
            }
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /// @dev Hook that is called after any token transfer
    function _afterTokenTransferTracker(
        address operator,
        uint256 fromToken,
        uint256 toToken,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        if(fromToken != 0){
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                //If Owner Ran Out of Tokens
                if(_balances[id][fromToken] == 0){
                    //Remvoed Owner
                    _uniqueMemberTokens[id].removeItem(fromToken);
                }
            }
        }
    }

    /* Unecessary, because token's aren't really controlled by the account anymore
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }
    */

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}
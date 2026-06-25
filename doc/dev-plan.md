# Development Plan

## Open Tasks

### EXC-0002: Fix `HubUpgradable` initializer validation failures in tests

Status: open

`npx hardhat test` currently fails because OpenZeppelin upgrades validation reports `contracts/HubUpgradable.sol:HubUpgradable` is missing an initializer call for `OwnableUpgradeable`. The first deployment failure cascades into undefined contract references in later tests.

Acceptance criteria:

- `HubUpgradable` initializes every required upgradeable parent contract exactly once.
- Proxy deployment tests no longer fail OpenZeppelin upgrade-safety validation.
- `npx hardhat test` passes, or any remaining failures are tracked as separate tasks with exact failing tests and root causes.

### EXC-0001: Migrate legacy Hardhat test tooling to clear remaining audit findings

Status: open

The compatible dependency refresh leaves known vulnerabilities in legacy tooling chains that cannot be resolved safely without migration work. Plan and execute a dedicated tooling migration that removes or replaces `ethereum-waffle`, `ganache-core`, `@openzeppelin/test-helpers`, the legacy `@nomiclabs/*` Hardhat plugins, and the old `solidity-coverage` dependency chain.

Acceptance criteria:

- Hardhat, ethers, OpenZeppelin upgrades tooling, TypeChain, and coverage tooling are on supported non-vulnerable versions.
- Contract compile and the full test suite pass after migration.
- `npm audit` has no remaining actionable findings, or each remaining finding is documented with the exact non-runtime scope and mitigation.
- Any contract or deployment API changes from the migration are explicitly documented before merging.

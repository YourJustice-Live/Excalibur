# Development Plan

## Open Tasks

### EXC-0002: Fix `HubUpgradable` initializer validation failures in tests

Status: complete

`npx hardhat test` currently fails because OpenZeppelin upgrades validation reports `contracts/HubUpgradable.sol:HubUpgradable` is missing an initializer call for `OwnableUpgradeable`. The first deployment failure cascades into undefined contract references in later tests.

Acceptance criteria:

- `HubUpgradable` initializes every required upgradeable parent contract exactly once.
- Proxy deployment tests no longer fail OpenZeppelin upgrade-safety validation.
- `npx hardhat test` passes, or any remaining failures are tracked as separate tasks with exact failing tests and root causes.

Resolution:

- Added missing upgradeable parent initializer calls for Hub and shared protocol entities.
- Added an internal ERC1155 tracker initializer and routed concrete protocol initializers through it.
- Verified with `npx hardhat test` on 2026-06-25: 61 passing.

### EXC-0001: Migrate legacy Hardhat test tooling to clear remaining audit findings

Status: in progress

The compatible dependency refresh leaves known vulnerabilities in legacy tooling chains that cannot be resolved safely without migration work. Plan and execute a dedicated tooling migration that removes or replaces `ethereum-waffle`, `ganache-core`, `@openzeppelin/test-helpers`, the legacy `@nomiclabs/*` Hardhat plugins, and the old `solidity-coverage` dependency chain.

Acceptance criteria:

- Hardhat, ethers, OpenZeppelin upgrades tooling, TypeChain, and coverage tooling are on supported non-vulnerable versions.
- Contract compile and the full test suite pass after migration.
- `npm audit` has no remaining actionable findings, or each remaining finding is documented with the exact non-runtime scope and mitigation.
- Any contract or deployment API changes from the migration are explicitly documented before merging.

Progress:

- Replaced deprecated `@nomiclabs/hardhat-waffle` / `ethereum-waffle` usage with `@nomicfoundation/hardhat-chai-matchers`.
- Removed unused `@openzeppelin/test-helpers`.
- Replaced deprecated `@nomiclabs/hardhat-etherscan` with `@nomicfoundation/hardhat-verify`.
- Upgraded `solidity-coverage` to the current Hardhat 2 compatible line.
- Verified with `npx hardhat test` on 2026-06-25: 61 passing.
- `npm audit --json` on 2026-06-25 reports 0 critical findings, down from 7 critical findings after the initial `ws` fix.

Remaining work:

- Plan and execute the breaking Hardhat 3 / ethers 6 migration, including replacement of `@nomiclabs/hardhat-ethers`, ethers v5 TypeChain packages, and compatibility updates for `@openzeppelin/hardhat-upgrades`.
- Re-run contract tests, deployment scripts, verification scripts, coverage, and contract-size checks after the major migration.

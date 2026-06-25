# Development Plan

## Open Tasks

### EXC-0001: Migrate legacy Hardhat test tooling to clear remaining audit findings

Status: open

The compatible dependency refresh leaves known vulnerabilities in legacy tooling chains that cannot be resolved safely without migration work. Plan and execute a dedicated tooling migration that removes or replaces `ethereum-waffle`, `ganache-core`, `@openzeppelin/test-helpers`, the legacy `@nomiclabs/*` Hardhat plugins, and the old `solidity-coverage` dependency chain.

Acceptance criteria:

- Hardhat, ethers, OpenZeppelin upgrades tooling, TypeChain, and coverage tooling are on supported non-vulnerable versions.
- Contract compile and the full test suite pass after migration.
- `npm audit` has no remaining actionable findings, or each remaining finding is documented with the exact non-runtime scope and mitigation.
- Any contract or deployment API changes from the migration are explicitly documented before merging.

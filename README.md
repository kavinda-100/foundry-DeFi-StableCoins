# Decentralized Stable Coin (DSC) Project

This project implements a decentralized, over-collateralized stablecoin system called **DSC** (Decentralized Stable Coin), inspired by MakerDAO's DAI but fully algorithmic and without governance. The system is built using [Foundry](https://book.getfoundry.sh/) for development, testing, and deployment.

## Project Overview

- **DSC** is a decentralized stablecoin pegged to USD, backed by exogenous collateral (e.g., ETH, WBTC).
- The protocol ensures that all DSC in circulation is always over-collateralized.
- Users can deposit supported collateral, mint DSC, burn DSC to unlock collateral, and participate in liquidations.

## Key Contracts

- [`src/DecentralizedStableCoin.sol`](src/DecentralizedStableCoin.sol): ERC20 implementation of the DSC token.
- [`src/DSCEngine.sol`](src/DSCEngine.sol): Core protocol logic for collateral management, minting, burning, and liquidation.
- [`test/unit/DSCEngine.t.sol`](test/unit/DSCEngine.t.sol): Unit tests for protocol logic.
- [`test/mocks/MockV3Aggregator.sol`](test/mocks/MockV3Aggregator.sol): Mock price feeds for local testing.
- [`script/DeployDSC.s.sol`](script/DeployDSC.s.sol): Deployment script.
- [`script/HelperConfig.s.sol`](script/HelperConfig.s.sol): Network configuration and mock deployment helpers.

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (Forge, Cast, Anvil)
- Node.js (for some scripts and tooling)
- RPC endpoints for testnets (e.g., Sepolia) if deploying off local

### Installation

```sh
git clone https://github.com/kavinda-100/foundry-DeFi-StableCoins.git
cd foundry-DeFi-StableCoins
forge install
```

## Usage

### Build Contracts

```sh
forge build
```

### Run Tests

```sh
forge test
```

### Format Code

```sh
forge fmt
```

### Gas Snapshots

```sh
forge snapshot
```

### Local Node (Anvil)

```sh
anvil
```

### Deploy Contracts

```sh
forge script script/DeployDSC.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### Cast Commands

```sh
cast <subcommand>
```

## Documentation

- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Chainlink Feeds](https://docs.chain.link/data-feeds/)

## Project Structure

```
src/
  DecentralizedStableCoin.sol
  DSCEngine.sol
test/
  unit/
    DSCEngine.t.sol
  mocks/
    MockV3Aggregator.sol
script/
  DeployDSC.s.sol
  HelperConfig.s.sol
lib/
  openzeppelin-contracts/
  chainlink-brownie-contracts/
  forge-std/
```

## License

This project is licensed under the MIT License.

---

**Author:** Kavinda Rathnayake  
**Inspired by:** MakerDAO DAI, OpenZeppelin, Chainlink

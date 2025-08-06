# FundMe - Crowdfunding Smart Contract

**A crowdfunding smart contract built with Solidity and Foundry, using Chainlink Price Feeds for ETH/USD conversion.**

## 📋 About the Project

FundMe is a decentralized crowdfunding contract that allows:

- **ETH Donations**: Users can contribute ETH to the project
- **Minimum Value**: Sets a minimum value of $5 USD (automatically converted from ETH)
- **Price Conversion**: Uses Chainlink Price Feeds to get current ETH/USD price
- **Owner Withdrawal**: Only the contract owner can withdraw funds
- **Multi-Network Support**: Works on Mainnet, Sepolia, and local network (Anvil)

## 🏗️ Architecture

### Main Contracts

- **`FundMe.sol`**: Main crowdfunding contract
- **`PriceConverter.sol`**: Library for ETH/USD conversion using Chainlink
- **`MockV3Aggregator.sol`**: Chainlink mock for local testing

### Deploy Scripts

- **`DeployFundMe.s.sol`**: Main deployment script
- **`HelperConfig.s.sol`**: Multi-network configuration with Price Feed addresses

## 🚀 Setup and Installation

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/downloads)

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/web11-ateves/foundry-fund-me
cd foundry-fund-me-cu
```

2. **Install dependencies:**

```bash
forge install
```

3. **Configure environment variables:**

```bash
cp .env.example .env
# Edit .env with your private keys and RPC URLs
source .env
```

### Dependencies

- **forge-std**: Foundry testing framework
- **chainlink-brownie-contracts**: Chainlink contracts and interfaces
- **Cyfrin/foundry-devops**: Foundry devops tools

## 🧪 Testing

### Run all tests

```bash
forge test
```

### Run specific test

```bash
forge test --match-test testWithDrawWithMultipleFunders
```

### Test coverage

```bash
forge coverage
```

### Fork testing (Sepolia)

```bash
forge test --fork-url $SEPOLIA_RPC_URL
```

## 📦 Deployment

### Local deployment (Anvil)

```bash
# Terminal 1: Start Anvil
anvil

# Terminal 2: Deploy contract
forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url http://127.0.0.1:8545 --private-key <anvil-private-key> --broadcast
```

### Sepolia deployment

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Mainnet deployment

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $MAINNET_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

## 💡 How to Use

### Fund the contract

```bash
cast send <CONTRACT_ADDRESS> "fund()" --value 0.1ether --private-key <PRIVATE_KEY> --rpc-url <RPC_URL>
```

### Check funded amount by address

```bash
cast call <CONTRACT_ADDRESS> "getAddressToAmountFunded(address)" <USER_ADDRESS> --rpc-url <RPC_URL>
```

### Withdraw funds (owner only)

```bash
cast send <CONTRACT_ADDRESS> "withdraw()" --private-key <OWNER_PRIVATE_KEY> --rpc-url <RPC_URL>
```

## 🔧 Network Configuration

The project supports the following networks:

| Network | Chain ID | ETH/USD Price Feed |
|---------|----------|-------------------|
| Mainnet | 1 | 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 |
| Sepolia | 11155111 | 0x694AA1769357215DE4FAC081bf1f309aDC325306 |
| Anvil (local) | 31337 | Mock Aggregator |

## 📊 Gas Optimization

The contract includes two versions of the withdrawal function:

- **`withdraw()`**: Standard implementation
- **`cheaperWithdraw()`**: Optimized version (~900 gas cheaper)

### Gas analysis

```bash
forge snapshot
forge snapshot --match-test testWithDrawWithMultipleFunders -vvv
```

## 🧰 Foundry Tools

### Build

```bash
forge build
```

### Format code

```bash
forge fmt
```

### Storage analysis

```bash
forge inspect FundMe storageLayout
```

### Interact with storage

```bash
cast storage <contract_address> <slot>
```

### Solidity REPL

```bash
chisel
```

## 📁 Project Structure

```
├── src/
│   ├── FundMe.sol              # Main contract
│   ├── PriceConverter.sol      # Price conversion library
│   └── exampleContracts/       # Example contracts
├── script/
│   ├── DeployFundMe.s.sol      # Deployment script
│   └── HelperConfig.s.sol      # Multi-network configuration
├── test/
│   ├── FundMeTest.t.sol        # Main tests
│   └── mock/
│       └── MockV3Aggregator.sol # Mock for testing
├── lib/                        # Dependencies
└── foundry.toml               # Foundry configuration
```

## 🔒 Security

- ✅ `onlyOwner` modifier for critical function protection
- ✅ Custom `revert` usage for gas savings
- ✅ Minimum USD value validation
- ✅ Reentrancy protection through CEI (Checks-Effects-Interactions) pattern

## 📚 Educational Resources

This project is part of the Cyfrin Updraft course and demonstrates:

- Chainlink Price Feeds integration
- Multi-network deployment with dynamic configuration
- Unit and integration testing with Foundry
- Gas optimization in Solidity
- Mocking for local testing

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📖 Foundry Documentation

For more information about Foundry: <https://book.getfoundry.sh/>

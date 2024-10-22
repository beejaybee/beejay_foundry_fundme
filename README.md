# FOUNDRY FUNDME PROJECT

## DESCRIPTION
### The project allows you to create a Crypto fund me Application


***

## Getting started
***

### Requirement

***

- [git](https://git-scm.com/downloads)
    - You'll know you did it right if you can run git --version and you see a response like git version x.x.x

- [foundry](https://getfoundry.sh/)
    - You'll know you did it right if you can run forge --version and you see a response like forge 0.2.0

***

### QUICKSTART

***
```
git clone https://github.com/beejaybee/beejay_foundry_fundme
cd beejay_foundry_fundme
forge build
or
make

```

***

## USAGE
***
### Deploy
***
``` forge script script/DeployFundMe.s.sol ```

### Test
***

```forge test```

or

``` forge test --mt functionName```

or

``` forge test ---fork-url Sepolia_RPC_URL```

### Test Coverage
***

``` forge coverage ```

# Deploy to A mainnet or testnet
***

```forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY```

You will need to setup your SEPOLIA_RPC_URL and PRIVATE_KEY in .env file to run the above command








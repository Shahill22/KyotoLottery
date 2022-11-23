import type { HardhatUserConfig } from "hardhat/types";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-truffle5";
import "solidity-coverage";
import "dotenv/config";
import "@typechain/hardhat";
import chai from "chai";
import { solidity } from "ethereum-waffle";

chai.use(solidity);

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      gas: 120000000,
      blockGasLimit: 0x1fffffffffffff,
    },
    AVAX: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      accounts: [
        process.env.PRIVATE_KEY1 as string,
        process.env.PRIVATE_KEY2 as string,
      ],
    },
    BNB: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: [
        process.env.PRIVATE_KEY1 as string,
        process.env.PRIVATE_KEY2 as string,
      ],
    },
    goerli: {
      url: `https://goerli.infura.io/v3/7229ac1b66204b8aa3805603e8e460e3`,
      accounts: [
        process.env.PRIVATE_KEY1 as string,
        process.env.PRIVATE_KEY2 as string,
      ],
    },
    testnetethereum: {
      url: `https://goerli.infura.io/v3/e927af90fbad4600b7ebda64912dc345`,
      accounts: [
        process.env.PRIVATE_KEY1 as string,
        process.env.PRIVATE_KEY2 as string,
      ],
    },
    testnet: {
      url: `https://data-seed-prebsc-1-s3.binance.org:8545/`,
      accounts: [
        process.env.PRIVATE_KEY1 as string,
        process.env.PRIVATE_KEY2 as string,
        process.env.PRIVATE_KEY3 as string,
        process.env.PRIVATE_KEY4 as string,
        process.env.PRIVATE_KEY5 as string,
        process.env.PRIVATE_KEY6 as string,
        process.env.PRIVATE_KEY7 as string,
        process.env.PRIVATE_KEY8 as string,
      ],
    },
  },
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 99999,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};

export default config;

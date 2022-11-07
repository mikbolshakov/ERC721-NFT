import { HardhatUserConfig } from "hardhat/types";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "@nomiclabs/hardhat-waffle";
import '@typechain/hardhat';

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  namedAccounts: {
    deployer: 0,
    user: 1
  },
  networks: {
    hardhat: {
      chainId: 1337
    }
  }
};

export default config;